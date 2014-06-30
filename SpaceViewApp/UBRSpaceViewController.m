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

@interface UBRSpaceViewController() <UBRSpaceViewDelegate>

@property (nonatomic, strong) UBRSpaceView * spaceView;

@end



@implementation UBRSpaceViewController



#pragma mark - Life Cycle -

- (void)viewDidLoad {

    [super viewDidLoad];
    
    // Layout and Setup Space View
    UBRSpaceView * spaceView = [[UBRSpaceView alloc] initWithFrame:self.view.bounds];
    spaceView.backgroundColor = [UIColor blackColor];
    spaceView.delegate = self;
    spaceView.duration = 0.6;
    spaceView.damping = 3;
    spaceView.velocity = 6;
    [self.view addSubview:spaceView];

    // Layout Rectangles and Placeholder Views
    NSArray * colors = @[[UIColor alizarinColor], [UIColor sunFlowerColor], [UIColor emeraldColor], [UIColor peterRiverColor]];

    for (NSInteger i = 0; i < kNumberOfRectangles; i++) {

        // Layout Rectangle
        UIView * rectangleView = [[UIView alloc] init];
        rectangleView.tag = i;
        rectangleView.backgroundColor = [colors[i] colorWithAlphaComponent:0.85];
        rectangleView.layer.borderColor = [colors[i] CGColor];
        rectangleView.layer.borderWidth = 1;
        [spaceView addSubview:rectangleView];
        [spaceView controlSubview:rectangleView options:UBRSpaceViewOptionsDraggable];

        UITapGestureRecognizer * rectangleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        rectangleTap.associatedView = rectangleView;
        [rectangleView addGestureRecognizer:rectangleTap];

        // Layout Placeholder
        UIView * placeholderView = [[UIView alloc] init];
        placeholderView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        placeholderView.layer.cornerRadius = kRectangleCornerRadius;
        placeholderView.frame = [self spaceView:nil startFrameForSubview:rectangleView];
        [spaceView insertSubview:placeholderView atIndex:0];

        UITapGestureRecognizer * placeholderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        placeholderTap.associatedView = rectangleView;
        [placeholderView addGestureRecognizer:placeholderTap];
        
    }
    
    self.spaceView = spaceView;

}



- (BOOL)prefersStatusBarHidden {
    
    return true;
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}




#pragma mark - Gesture Handling -

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGesture {

    [self.spaceView toggleSubviewPosition:tapGesture.associatedView animated:true];
    
}




#pragma mark - Space View Delegate -

- (CGRect)spaceView:(UBRSpaceView *)spaceView endFrameForSubview:(UIView *)view {
    
    CGRect bounds = self.view.bounds;
    
    CGRect rect = CGRectZero;
    rect.origin.y = kRectangleSpacing;
    rect.origin.x = kRectangleSpacing;
    rect.size.width = bounds.size.width - 2 * kRectangleSpacing;
    rect.size.height = bounds.size.height - 3 * kRectangleSpacing - kRectangleSideLength * 2;
    return rect;

}



- (CGRect)spaceView:(UBRSpaceView *)spaceView startFrameForSubview:(UIView *)view {
    
    CGFloat spacing = 10;
    CGRect  bounds = self.view.bounds;
    CGSize  size = CGSizeMake(kRectangleSideLength * 2, kRectangleSideLength * 2);
    CGFloat distance = (bounds.size.width - 2 * spacing - 2 * kRectangleSideLength) / (kNumberOfRectangles-1);
    
    CGRect rect = CGRectZero;
    rect.origin.y = bounds.size.height - size.height - spacing;
    rect.origin.x = spacing;
    rect.origin.x += distance * view.tag;
    rect.size = size;
    
    return UBRRoundRect(rect);
    
}



- (void)spaceView:(UBRSpaceView *)spaceView adjustSubview:(UIView *)view progress:(CGFloat)progress {
    
    CGFloat factor = fabsf(progress-1);
    view.layer.cornerRadius = factor * kRectangleCornerRadius;
    
}



- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview willTransitFromPosition:(UBRSpaceViewPosition)position {

    if (position == UBRSpaceViewPositionStart) {
        [spaceView bringSubviewToFront:subview];
    }
    
}



- (void)spaceView:(UBRSpaceView *)spaceView subview:(UIView *)subview didTransitToPosition:(UBRSpaceViewPosition)position {
    
    
}


@end
