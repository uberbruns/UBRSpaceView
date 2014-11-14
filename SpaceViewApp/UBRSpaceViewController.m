//
//  ViewController.m
//  Space View
//
//  Created by Karsten Bruns on 15/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UBRSpaceViewController.h"
#import "UIColor+FlatColors.h"
#import "UIGestureRecognizer+SpaceView.h"
#import "UBRSpaceView.h"


NSInteger const kNumberOfRectangles    = 4;
CGFloat   const kRectangleSideLength   = 33;
CGFloat   const kRectangleSpacing      = 10;
CGFloat   const kRectangleCornerRadius = 10;


@interface UBRMovableView : UIView

@property (nonatomic, assign) NSUInteger position;

@end


@interface UBRSpaceViewController() <UBRSpaceViewDelegate>

@property (nonatomic, strong) UBRSpaceView *spaceView;
@property (nonatomic, readonly) NSMutableArray *topViews;
@property (nonatomic, readonly) NSMutableArray *bottomViews;

@end



@implementation UBRSpaceViewController


#pragma mark - View Controller -

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _topViews = [[NSMutableArray alloc] initWithCapacity:32];
        _bottomViews = [[NSMutableArray alloc] initWithCapacity:32];
    }
    return self;
}


- (BOOL)prefersStatusBarHidden
{
    return true;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View -
#pragma mark Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSpaceView];
}


- (void)addSpaceView
{
    // Layout and Setup Space View
    UBRSpaceView *spaceView = [[UBRSpaceView alloc] initWithFrame:self.view.bounds];
    spaceView.backgroundColor = [UIColor blackColor];
    spaceView.delegate = self;
    spaceView.duration = 0.6;
    spaceView.damping = 3;
    spaceView.velocity = 6;
    [self.view addSubview:spaceView];
    
    // Layout Rectangles and Placeholder Views
    NSArray *colors = @[[UIColor alizarinColor], [UIColor sunFlowerColor], [UIColor emeraldColor], [UIColor peterRiverColor]];
    
    for (NSInteger i = 0; i < kNumberOfRectangles; i++) {
        
        // Layout Rectangle
        UBRMovableView *movableView = [[UBRMovableView alloc] init];
        movableView.position = i;
        movableView.backgroundColor = [colors[i] colorWithAlphaComponent:0.85];
        movableView.layer.borderColor = [colors[i] CGColor];
        movableView.layer.borderWidth = 1;
        [self.bottomViews addObject:movableView];
        [spaceView addSubview:movableView];
        [spaceView controlSubview:movableView options:UBRSpaceViewOptionsDraggable];
        
        UITapGestureRecognizer *rectangleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        rectangleTap.associatedView = movableView;
        [movableView addGestureRecognizer:rectangleTap];
        
        // Layout Placeholder
        UIView *placeholderView = [[UIView alloc] init];
        placeholderView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        placeholderView.layer.cornerRadius = kRectangleCornerRadius;
        placeholderView.frame = [self bottomFrameForView:movableView];
        [spaceView insertSubview:placeholderView atIndex:0];
        
        UITapGestureRecognizer *placeholderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        placeholderTap.associatedView = movableView;
        [placeholderView addGestureRecognizer:placeholderTap];
        
    }
    
    self.spaceView = spaceView;
}


#pragma mark Positionig

- (BOOL)viewIsTopView:(UBRMovableView *)movableView
{
    return ([self.topViews indexOfObject:movableView] != NSNotFound);
}


- (BOOL)viewIsBottomView:(UBRMovableView *)movableView
{
    return ([self.bottomViews indexOfObject:movableView] != NSNotFound);
}


- (CGRect)topFrameForView:(UBRMovableView *)movableView
{
    CGRect bounds = self.view.bounds;
    
    CGRect rect = CGRectZero;
    rect.origin.y = kRectangleSpacing;
    rect.origin.x = kRectangleSpacing;
    rect.size.width = bounds.size.width - 2 *kRectangleSpacing;
    rect.size.height = bounds.size.height - 3 *kRectangleSpacing - kRectangleSideLength *2;
    return rect;
}


- (CGRect)bottomFrameForView:(UBRMovableView *)movableView
{
    CGFloat spacing = 10;
    CGRect  bounds = self.view.bounds;
    CGSize  size = CGSizeMake(kRectangleSideLength *2, kRectangleSideLength *2);
    CGFloat distance = (bounds.size.width - 2 *spacing - 2 *kRectangleSideLength) / (kNumberOfRectangles-1);
    
    CGRect rect = CGRectZero;
    rect.origin.y = bounds.size.height - size.height - spacing;
    rect.origin.x = spacing;
    rect.origin.x += distance * movableView.position;
    rect.size = size;
    
    return UBRRoundRect(rect);
}


- (CGRect)topOutsideFrameForView:(UBRMovableView *)movableView
{
    CGRect rect = [self topFrameForView:movableView];
    rect.origin.y = -rect.size.height;
    return UBRRoundRect(rect);
}

#pragma mark - Gesture Handling -

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture
{
    [self.spaceView toggleSubviewPosition:tapGesture.associatedView animated:true];
}


#pragma mark - Protocols -
#pragma mark Space View Delegate

- (CGRect)spaceView:(UBRSpaceView *)spaceView startFrameForSubview:(UIView *)view
{
    UBRMovableView *movableView = (id)view;
    if ([self viewIsTopView:movableView]) {
        return [self topFrameForView:movableView];
    } else {
        return [self bottomFrameForView:movableView];
    }
}


- (CGRect)spaceView:(UBRSpaceView *)spaceView endFrameForSubview:(UIView *)view inDirection:(UBRSpaceViewDirection)direction
{
    UBRMovableView *movableView = (id)view;
    if ([self viewIsTopView:movableView]) {
        if (direction & UBRSpaceViewDirectionTopHalf) {
            return [self topOutsideFrameForView:movableView];
        } else {
            return [self bottomFrameForView:movableView];
        }
    } else {
        return [self topFrameForView:movableView];
    }
}


- (void)spaceView:(UBRSpaceView *)spaceView adjustSubview:(UIView *)view progress:(CGFloat)progress
{
    UBRMovableView *movableView = (id)view;
    CGFloat factor = fabsf(progress-1);
    
    if ([self viewIsTopView:movableView]) {
        factor = 1 - factor;
    }
    
    view.layer.cornerRadius = factor *kRectangleCornerRadius;
}


- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview willTransitFromPosition:(UBRSpaceViewPosition)position
{
    if (position == UBRSpaceViewPositionStart) {
        [spaceView bringSubviewToFront:subview];
    }
}


- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview didTransitToPosition:(UBRSpaceViewPosition)position
{
    if (position == UBRSpaceViewPositionEnd) {
        
        UBRMovableView *movableView = (id)subview;

        if ([self viewIsBottomView:movableView]) {
            [self.bottomViews removeObject:movableView];
            [self.topViews addObject:movableView];
        } else if ([self viewIsTopView:movableView]) {
            [self.topViews removeObject:movableView];
            [self.bottomViews addObject:movableView];
        }
    }
}


@end



@implementation UBRMovableView



@end

