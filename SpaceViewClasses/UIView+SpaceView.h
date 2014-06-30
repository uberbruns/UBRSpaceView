//
//  UIView+SpaceViewExtension.h
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBRSpaceViewInfo;

typedef NS_ENUM(NSInteger, UBRSpaceViewPosition) {
    UBRSpaceViewPositionStart,
    UBRSpaceViewPositionEnd
};

@interface UIView (UBRSpaceView)

@property (nonatomic, strong) UBRSpaceViewInfo * svInfo;

@end


@interface UBRSpaceViewInfo : NSObject

@property (nonatomic, assign) UIPanGestureRecognizer * activeGesture;
@property (nonatomic, assign) UBRSpaceViewPosition direction;
@property (nonatomic, assign) CGPoint offsetTouchLocationToCenter;
@property (nonatomic, assign) CGFloat progress;
@property (readonly) UBRSpaceViewPosition progressDirection;

@end

