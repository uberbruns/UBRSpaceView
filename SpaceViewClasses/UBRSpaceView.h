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
- (void)toggleSubviewPosition:(UIView *)subview animated:(BOOL)animated;
- (void)setSubviewPosition:(UIView *)subview position:(UBRSpaceViewPosition)position animated:(BOOL)animated;

@property (nonatomic, weak) id <UBRSpaceViewDelegate> delegate;
@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGFloat duration;

@end



@protocol UBRSpaceViewDelegate <NSObject>

- (CGRect)spaceView:(UBRSpaceView*)spaceView endFrameForSubview:(UIView *)subview;
- (CGRect)spaceView:(UBRSpaceView*)spaceView startFrameForSubview:(UIView *)subview;

@optional

- (void)spaceView:(UBRSpaceView*)spaceView adjustSubview:(UIView *)subview progress:(CGFloat)progress;
- (void)spaceView:(UBRSpaceView*)spaceView subview:(UIView *)subview didTransitToPosition:(UBRSpaceViewPosition)position;
- (void)spaceView:(UBRSpaceView*)spaceView subview:(UIView *)subview willTransitFromPosition:(UBRSpaceViewPosition)position;

@end

