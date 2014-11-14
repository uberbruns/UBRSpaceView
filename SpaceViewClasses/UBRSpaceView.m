//
//  AnimatedSpace.m
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)



#import "UBRSpaceView.h"
#import "UIGestureRecognizer+SpaceView.h"
#import <QuartzCore/QuartzCore.h>


@interface UBRSpaceView () <UIGestureRecognizerDelegate>

@end



@implementation UBRSpaceView


#pragma mark - Life Cycle -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.damping = 3;
        self.velocity = 12;
        self.duration = 0.4;
    }
    return self;
}


- (void)willRemoveSubview:(UIView *)subview
{
    UIGestureRecognizer *removeMe;
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        if (gestureRecognizer.associatedView == subview) {
            removeMe = gestureRecognizer;
            break;
        }
    }
    
    if (removeMe) {
        [self removeGestureRecognizer:removeMe];
    }
}


#pragma mark - API -

- (void)controlSubview:(UIView *)subview options:(UBRSpaceViewOptions)options
{
    if (options & UBRSpaceViewOptionsDraggable) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        panGesture.delegate = self;
        panGesture.associatedView = subview;
        [self addGestureRecognizer:panGesture];
    }
    
    subview.svInfo = [[UBRSpaceViewInfo alloc] init];
    subview.svInfo.thePosition = UBRSpaceViewPositionStart;
    [self updateSubview:subview animated:false];
}


- (void)setSubviewPosition:(UIView *)subview position:(UBRSpaceViewPosition)position animated:(BOOL)animated
{
    if (position != subview.svInfo.thePosition) {

        // Call Delegate
        if ([self.delegate respondsToSelector:@selector(spaceView:subviewWillMove:)]) {
            [self.delegate spaceView:self subviewWillMove:subview];
        }

        // Set And Update
        subview.svInfo.thePosition = position;
        [self updateSubview:subview animated:animated];
    }
}


#pragma mark - Subviews -
#pragma mark Update

- (void)updateSubview:(UIView *)subview
{
    CGRect nextFrame;
    CGFloat progress = 0;
    
    if (subview.svInfo.thePosition == UBRSpaceViewPositionStart) {
        nextFrame = [self.delegate spaceView:self startFrameForSubview:subview];
    } else {
        nextFrame = [self.delegate spaceView:self endFrameForSubview:subview direction:subview.svInfo.direction];
        progress = 1;
    }

    if ([self.delegate respondsToSelector:@selector(spaceView:subviewIsMoving:progress:direction:)]) {
        [self.delegate spaceView:self subviewIsMoving:subview progress:progress direction:subview.svInfo.direction];
    }
    
    subview.frame = nextFrame;
}


- (void)updateSubview:(UIView *)subview animated:(BOOL)animated
{
    // Not Animated?
    if (!animated) {
        [self updateSubview:subview];
        if ([self.delegate respondsToSelector:@selector(spaceView:subviewDidMove:toPosition:direction:)]) {
            [self.delegate spaceView:self subviewDidMove:subview toPosition:subview.svInfo.thePosition direction:subview.svInfo.direction];
        }
        return;
    }
    
    // Animation Setup
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent;
    CGFloat damping = self.damping;
    CGFloat velocity = self.velocity;
    CGFloat duration = self.duration;
    CGFloat durationFactor = 1;

    CGRect startFrame, endFrame, nextFrame;
    startFrame = [self.delegate spaceView:self startFrameForSubview:subview];
    endFrame = [self.delegate spaceView:self endFrameForSubview:subview direction:subview.svInfo.direction];
    
    // iOS7 Backward Compability
    if SYSTEM_VERSION_LESS_THAN(@"8.0") {
        options |= UIViewAnimationOptionBeginFromCurrentState;
    }

    // Consider Gesture Velocity
    if (subview.svInfo.activeGesture) {
        
        CGFloat distance = 1.0;
        durationFactor = [self progressForSubview:subview];
        durationFactor = fmaxf(durationFactor, 0.5);

        if (subview.svInfo.thePosition == UBRSpaceViewPositionStart) {
            nextFrame = startFrame;
        } else {
            durationFactor = 1 - durationFactor;
            nextFrame = endFrame;
        }
        
        distance = UBRDistance(UBRCenterForRect(nextFrame), [subview.layer.presentationLayer position]);
        velocity = [subview.svInfo.activeGesture velocityInView:subview.superview].y / distance;

        if (velocity > 15 || velocity < 0) {
            velocity = self.velocity;
        }
        
        velocity *= durationFactor;
        
    }
    
//    NSLog(@"velocity: %f", velocity);
//    NSLog(@"duration: %f", duration);
//    NSLog(@"durationFactor: %f", durationFactor);
//    NSLog(@"damping: %f", damping);
//    NSLog(@" ");
    
    duration *= durationFactor;

    // Perform Animation
    [UIView animateWithDuration: duration
                          delay: 0
         usingSpringWithDamping: damping
          initialSpringVelocity: velocity
                        options: options
                     animations:^{
                         [self updateSubview:subview];
                     } completion:^(BOOL finished) {
                         if (finished && [self.delegate respondsToSelector:@selector(spaceView:subviewDidMove:toPosition:direction:)]) {
                             CGRect currentFrame = [subview.layer.presentationLayer frame];
                             if (CGRectEqualToRect(currentFrame, startFrame)) {
                                 [self.delegate spaceView:self subviewDidMove:subview toPosition:UBRSpaceViewPositionStart direction:subview.svInfo.direction];
                                 subview.svInfo.inTransition = false;
                             } else if (CGRectEqualToRect(currentFrame, endFrame)) {
                                 subview.svInfo.inTransition = false;
                                 [self.delegate spaceView:self subviewDidMove:subview toPosition:UBRSpaceViewPositionEnd direction:subview.svInfo.direction];
                             }
                         }
                     }];
}


#pragma mark Update / Progress

- (CGFloat)progressForSubview:(UIView *)subview
{
    CGRect minRect = [self.delegate spaceView:self startFrameForSubview:subview];
    CGRect maxRect = [self.delegate spaceView:self endFrameForSubview:subview direction:subview.svInfo.direction];
    CGPoint currentPosition = [subview.layer.presentationLayer position];
    return UBRProgressBetweenRects(minRect, maxRect, currentPosition);;
}


#pragma mark - Gesture Handling -
#pragma mark Pan Gesture

- (void)panGestureHandler:(UIPanGestureRecognizer *)panGesture
{
    UIView *subview = panGesture.associatedView;

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        // Call Delegate
        if ([self.delegate respondsToSelector:@selector(spaceView:subviewWillMove:)]) {
            [self.delegate spaceView:self subviewWillMove:subview];
        }

        // Based upon the frame in the superview and the presentation layer,
        // we can calculate the inner offset at the beginning and save
        // it as relative value to the current subview size
        CGRect frame = [subview.layer.presentationLayer frame];
        CGPoint subviewLocation = UBRCenterForRect(frame);
        CGPoint innerTouchLocationRelativeToCenter = [panGesture locationInView:self];
        innerTouchLocationRelativeToCenter.x -= subviewLocation.x;
        innerTouchLocationRelativeToCenter.y -= subviewLocation.y;
        innerTouchLocationRelativeToCenter.x /= frame.size.width; // Make value realtive to size
        innerTouchLocationRelativeToCenter.y /= frame.size.height;
        subview.svInfo.innerTouchLocationRelativeToCenter = innerTouchLocationRelativeToCenter;
        
        // Start Location
        if (!subview.svInfo.inTransition) {
            subview.svInfo.startLocation = [panGesture locationInView:self];
        }

        // Touching the layer gives all control to the user
        [subview.layer removeAllAnimations];
        subview.frame = [subview.layer.presentationLayer frame];
        subview.svInfo.activeGesture = panGesture;
        subview.svInfo.inTransition = true;
        

    } else if (panGesture.state == UIGestureRecognizerStateEnded) {

        CGPoint velocity = [panGesture velocityInView:self];
        BOOL isDragging = (fabs(velocity.x) > 512 || fabs(velocity.y) > 512);
        
        if (isDragging) {
            subview.svInfo.thePosition = subview.svInfo.positionByProgressChange;
        } else {
            if (subview.svInfo.progress < 0.5) {
                subview.svInfo.thePosition = UBRSpaceViewPositionStart;
            } else {
                subview.svInfo.thePosition = UBRSpaceViewPositionEnd;
            }
        }
        [self updateSubview:subview animated:true];
        subview.svInfo.direction = UBRSpaceViewDirectionUnknown;
        subview.svInfo.activeGesture = nil;

    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint startingTouchLocation = subview.svInfo.startLocation;
        CGPoint currentTouchLocation = [panGesture locationInView:subview.superview];
        CGFloat angle = UBRAngleBetweenPoints(startingTouchLocation, currentTouchLocation);
        UBRSpaceViewDirection direction = UBRSpaceViewDirectionUnknown;

        if (angle >= -4*M_PI_4 && angle < -3*M_PI_4) {
            direction = UBRSpaceViewDirectionRightHalf | UBRSpaceViewDirectionTopHalf | UBRSpaceViewDirectionTopQuarter;
        } else if (angle >= -3*M_PI_4 && angle < -2*M_PI_4) {
            direction = UBRSpaceViewDirectionRightHalf | UBRSpaceViewDirectionTopHalf | UBRSpaceViewDirectionRightQuarter;
        } else if (angle >= -2*M_PI_4 && angle < -1*M_PI_4) {
            direction = UBRSpaceViewDirectionRightHalf | UBRSpaceViewDirectionBottomHalf | UBRSpaceViewDirectionRightQuarter;
        } else if (angle >= -1*M_PI_4 && angle < 0) {
            direction = UBRSpaceViewDirectionRightHalf | UBRSpaceViewDirectionBottomHalf | UBRSpaceViewDirectionBottomQuarter;
        } else if (angle >= 0 && angle < 1*M_PI_4) {
            direction = UBRSpaceViewDirectionLeftHalf | UBRSpaceViewDirectionBottomHalf | UBRSpaceViewDirectionBottomQuarter;
        } else if (angle >= 1*M_PI_4 && angle < 2*M_PI_4) {
            direction = UBRSpaceViewDirectionLeftHalf | UBRSpaceViewDirectionBottomHalf | UBRSpaceViewDirectionRightQuarter;
        } else if (angle >= 2*M_PI_4 && angle < 3*M_PI_4) {
            direction = UBRSpaceViewDirectionLeftHalf | UBRSpaceViewDirectionTopHalf | UBRSpaceViewDirectionRightQuarter;
        } else {
            direction = UBRSpaceViewDirectionLeftHalf | UBRSpaceViewDirectionTopHalf | UBRSpaceViewDirectionTopQuarter;
        }

        CGRect frame = [subview.layer.presentationLayer frame];
        CGPoint innerTouchLocationRelativeToCenter = subview.svInfo.innerTouchLocationRelativeToCenter;
        currentTouchLocation.x -= (innerTouchLocationRelativeToCenter.x * frame.size.width);
        currentTouchLocation.y -= (innerTouchLocationRelativeToCenter.y * frame.size.height);
        
        CGRect  startRect = [self.delegate spaceView:self startFrameForSubview:subview];
        CGRect  endRect   = [self.delegate spaceView:self endFrameForSubview:subview direction:direction];
        CGFloat progress  = UBRProgressBetweenRects(startRect, endRect, currentTouchLocation);
        subview.svInfo.progress = progress;
        subview.svInfo.direction = direction;
        
        [UIView animateWithDuration:(1.0 / 60.0) * 4.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            subview.layer.frame = UBRScaleRect(startRect, endRect, progress);
            if ([self.delegate respondsToSelector:@selector(spaceView:subviewIsMoving:progress:direction:)]) {
                [self.delegate spaceView:self subviewIsMoving:subview progress:progress direction:subview.svInfo.direction];
            }
        } completion:nil];
        
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *topView;
    for (UIView *aView in self.subviews.reverseObjectEnumerator) {
        if (CGRectContainsPoint(aView.frame, [touch locationInView:self])) {
            topView = aView;
            break;
        }
    }
    
    if (gestureRecognizer.associatedView && gestureRecognizer.associatedView == topView) {
        UIView *view = gestureRecognizer.associatedView;
        CALayer *hitLayer = [view.layer.presentationLayer hitTest:[touch locationInView: self]];
        return (hitLayer != nil);
    }
    
    return false;
}



@end