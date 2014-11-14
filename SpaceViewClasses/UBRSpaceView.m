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


#pragma mark - Interface -

- (void)controlSubview:(UIView *)subview options:(UBRSpaceViewOptions)options
{
    if (options & UBRSpaceViewOptionsDraggable) {
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        panGesture.delegate = self;
        panGesture.associatedView = subview;
        [self addGestureRecognizer:panGesture];
    }
    
    subview.svInfo = [[UBRSpaceViewInfo alloc] init];
    subview.svInfo.fromPosition = UBRSpaceViewPositionStart;
    [self updateSubview:subview animated:false];
}


- (void)toggleSubviewPosition:(UIView *)subview animated:(BOOL)animated
{
    UBRSpaceViewPosition nextPosition;
    if (subview.svInfo.fromPosition == UBRSpaceViewPositionStart) {
        nextPosition = UBRSpaceViewPositionEnd;
    } else {
        nextPosition = UBRSpaceViewPositionStart;
    }
    
    [self setSubviewPosition:subview position:nextPosition animated:animated];
}


- (void)setSubviewPosition:(UIView *)subview position:(UBRSpaceViewPosition)position animated:(BOOL)animated
{
    if (position != subview.svInfo.fromPosition) {

        // Call Delegate
        if ([self.delegate respondsToSelector:@selector(spaceView:subview:willTransitFromPosition:)]) {
            [self.delegate spaceView:self subview:subview willTransitFromPosition:subview.svInfo.fromPosition];
        }

        // Set And Update
        subview.svInfo.fromPosition = position;
        [self updateSubview:subview animated:animated];
    }
}


#pragma mark - Subview Handling -

- (void)updateSubview:(UIView *)subview
{
    CGRect nextFrame;
    CGFloat progress = 0;
    
    if (subview.svInfo.fromPosition == UBRSpaceViewPositionStart) {
        nextFrame = [self.delegate spaceView:self startFrameForSubview:subview];
    } else {
        nextFrame = [self.delegate spaceView:self endFrameForSubview:subview inDirection:subview.svInfo.direction];
        progress = 1;
    }

    if ([self.delegate respondsToSelector:@selector(spaceView:adjustSubview:progress:)]) {
        [self.delegate spaceView:self adjustSubview:subview progress:progress];
    }
    
    subview.frame = nextFrame;
}


- (void)updateSubview:(UIView *)subview animated:(BOOL)animated
{
    // Not Animated?
    if (!animated) {
        [self updateSubview:subview];
        if ([self.delegate respondsToSelector:@selector(spaceView:subview:didTransitToPosition:)]) {
            [self.delegate spaceView:self subview:subview didTransitToPosition:subview.svInfo.fromPosition];
        }
        return;
    }
    
    // Animation Setup
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
    CGFloat damping = self.damping;
    CGFloat velocity = self.velocity;
    CGFloat duration = self.duration;
    CGFloat durationFactor = 1;

    CGRect startFrame, endFrame, nextFrame;
    startFrame = [self.delegate spaceView:self startFrameForSubview:subview];
    endFrame = [self.delegate spaceView:self endFrameForSubview:subview inDirection:subview.svInfo.direction];
    
    // iOS7 Backward Compability
    if SYSTEM_VERSION_LESS_THAN(@"8.0") {
        options |= UIViewAnimationOptionBeginFromCurrentState;
    }

    // Consider Gesture Velocity
    if (subview.svInfo.activeGesture) {
        
        CGFloat distance;
        durationFactor = [self progressForSubview:subview];
        
        if (subview.svInfo.fromPosition == UBRSpaceViewPositionStart) {
            nextFrame = startFrame;
        } else {
            durationFactor = 1 - durationFactor;
            nextFrame = endFrame;
        }
        
        distance = UBRDistance(UBRCenterForRect(nextFrame), [subview.layer.presentationLayer position]);
        velocity = [subview.svInfo.activeGesture velocityInView:subview.superview].y / distance;
        velocity = fmin(16, fmax(0, velocity));
        velocity *= durationFactor;
        
    }
    
    duration *= durationFactor;

    // Perform Animation
    [UIView animateWithDuration: fmax(duration, self.duration/2)
                          delay: 0
         usingSpringWithDamping: damping
          initialSpringVelocity: velocity
                        options: options
                     animations:^{
                         [self updateSubview:subview];
                     } completion:^(BOOL finished) {
                         if (finished && [self.delegate respondsToSelector:@selector(spaceView:subview:didTransitToPosition:)]) {
                             CGRect currentFrame = [subview.layer.presentationLayer frame];
                             if (CGRectEqualToRect(currentFrame, startFrame)) {
                                 [self.delegate spaceView:self subview:subview didTransitToPosition:UBRSpaceViewPositionStart];
                             } else if (CGRectEqualToRect(currentFrame, endFrame)) {
                                 [self.delegate spaceView:self subview:subview didTransitToPosition:UBRSpaceViewPositionEnd];
                             }
                         }
                     }];
}



#pragma mark - Gesture Handling -
#pragma mark Pan Gesture

- (void)panGestureHandler:(UIPanGestureRecognizer *)panGesture
{
    UIView * subview = panGesture.associatedView;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        // Call Delegate
        if ([self.delegate respondsToSelector:@selector(spaceView:subview:willTransitFromPosition:)]) {
            [self.delegate spaceView:self subview:subview willTransitFromPosition:subview.svInfo.fromPosition];
        }

        // Based upon the frame in the superview and the presentation layer,
        // we can calculate the inner offset at the beginning and save
        // it as relative value to the current subview size
        CGRect frame = [subview.layer.presentationLayer frame];
        CGPoint offsetTouchLocationToCenter = [panGesture locationInView:self];
        CGPoint subviewLocation = UBRCenterForRect(frame);
        offsetTouchLocationToCenter.x -= subviewLocation.x;
        offsetTouchLocationToCenter.y -= subviewLocation.y;
        offsetTouchLocationToCenter.x /= frame.size.width;
        offsetTouchLocationToCenter.y /= frame.size.height;
        subview.svInfo.offsetTouchLocationToCenter = offsetTouchLocationToCenter;
        
        // Start Location
        subview.svInfo.startLocation = [panGesture locationInView:self];

        // Touching the layer gives all control to the user
        [subview.layer removeAllAnimations];
        subview.frame = [subview.layer.presentationLayer frame];
        subview.svInfo.activeGesture = panGesture;
        

    } else if (panGesture.state == UIGestureRecognizerStateEnded) {

        CGPoint velocity = [panGesture velocityInView:self];
        BOOL isDragging = (fabs(velocity.x) > 512 || fabs(velocity.y) > 512);
        
        if (isDragging) {
            subview.svInfo.fromPosition = subview.svInfo.positionByProgressChange;
        } else {
            if (subview.svInfo.progress < 0.5) {
                subview.svInfo.fromPosition = UBRSpaceViewPositionStart;
            } else {
                subview.svInfo.fromPosition = UBRSpaceViewPositionEnd;
            }
        }
        
        [self updateSubview:subview animated:true];
        subview.svInfo.direction = UBRSpaceViewDirectionnUnknown;
        subview.svInfo.activeGesture = nil;

    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint startPosition = subview.svInfo.startLocation;
        CGPoint position = [panGesture locationInView:subview.superview];
        CGFloat angle = UBRAngleBetweenPoints(startPosition, position);
        UBRSpaceViewDirection direction = UBRSpaceViewDirectionnUnknown;

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
        CGPoint offsetTouchLocationToCenter = subview.svInfo.offsetTouchLocationToCenter;
        position.x -= (offsetTouchLocationToCenter.x * frame.size.width);
        position.y -= (offsetTouchLocationToCenter.y * frame.size.height);
        
        CGRect  startRect = [self.delegate spaceView:self startFrameForSubview:subview];
        CGRect  endRect   = [self.delegate spaceView:self endFrameForSubview:subview inDirection:direction];
        CGFloat progress  = UBRProgressBetweenRects(startRect, endRect, position);
        subview.svInfo.progress = progress;
        subview.svInfo.direction = direction;
        
        subview.frame = UBRScaleRect(startRect, endRect, progress);
        if ([self.delegate respondsToSelector:@selector(spaceView:adjustSubview:progress:)]) {
            [self.delegate spaceView:self adjustSubview:subview progress:progress];
        }
        
    }
}


#pragma mark Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView * topView;
    for (UIView * aView in self.subviews.reverseObjectEnumerator) {
        if (CGRectContainsPoint(aView.frame, [touch locationInView:self])) {
            topView = aView;
            break;
        }
    }
    
    if (gestureRecognizer.associatedView && gestureRecognizer.associatedView == topView) {
        UIView * view = gestureRecognizer.associatedView;
        CALayer * hitLayer = [view.layer.presentationLayer hitTest:[touch locationInView: self]];
        return (hitLayer != nil);
    }
    
    return false;
}


#pragma mark - Helper -
#pragma mark Progress

- (CGFloat)progressForSubview:(UIView *)subview
{
    CGRect minRect = [self.delegate spaceView:self startFrameForSubview:subview];
    CGRect maxRect = [self.delegate spaceView:self endFrameForSubview:subview inDirection:subview.svInfo.direction];
    CGPoint currentPosition = [subview.layer.presentationLayer position];
    return UBRProgressBetweenRects(minRect, maxRect, currentPosition);;
}


@end