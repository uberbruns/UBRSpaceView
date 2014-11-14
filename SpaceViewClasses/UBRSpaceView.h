//
//  AnimatedSpace.h
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBRSpaceGeometry.h"
#import "UIView+SpaceView.h"


@protocol UBRSpaceViewDelegate;

typedef NS_OPTIONS(NSUInteger, UBRSpaceViewOptions) {
    UBRSpaceViewOptionsDraggable = 1 << 0,
};



@interface UBRSpaceView : UIView

- (void)controlSubview:(UIView *)subview options:(UBRSpaceViewOptions)options;
- (void)setSubviewPosition:(UIView *)subview position:(UBRSpaceViewPosition)position animated:(BOOL)animated;

@property (nonatomic, weak) id <UBRSpaceViewDelegate> delegate;
@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGFloat duration;

@end



@protocol UBRSpaceViewDelegate <NSObject>

- (CGRect)spaceView:(UBRSpaceView*)spaceView startFrameForSubview:(UIView *)subview;
- (CGRect)spaceView:(UBRSpaceView*)spaceView endFrameForSubview:(UIView *)subview direction:(UBRSpaceViewDirection)direction;

@optional

- (void)spaceView:(UBRSpaceView*)spaceView adjustSubview:(UIView *)subview progress:(CGFloat)progress direction:(UBRSpaceViewDirection)direction;
- (void)spaceView:(UBRSpaceView*)spaceView subview:(UIView *)subview didTransitToPosition:(UBRSpaceViewPosition)position direction:(UBRSpaceViewDirection)direction;
- (void)spaceView:(UBRSpaceView*)spaceView subview:(UIView *)subview willTransitFromPosition:(UBRSpaceViewPosition)position direction:(UBRSpaceViewDirection)direction;

@end

