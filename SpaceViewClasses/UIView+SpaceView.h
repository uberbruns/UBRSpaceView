//
//  UIView+SpaceViewExtension.h
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBRSpaceViewInfo;

typedef NS_ENUM(NSUInteger, UBRSpaceViewPosition) {
    UBRSpaceViewPositionStart,
    UBRSpaceViewPositionEnd
};

typedef NS_OPTIONS(NSUInteger, UBRSpaceViewDirection) {
    UBRSpaceViewDirectionnUnknown      = 1 << 0,
    UBRSpaceViewDirectionTopHalf       = 1 << 1,
    UBRSpaceViewDirectionBottomHalf    = 1 << 2,
    UBRSpaceViewDirectionLeftHalf      = 1 << 3,
    UBRSpaceViewDirectionRightHalf     = 1 << 4,
    UBRSpaceViewDirectionTopQuarter    = 1 << 5,
    UBRSpaceViewDirectionBottomQuarter = 1 << 6,
    UBRSpaceViewDirectionLeftQuarter   = 1 << 7,
    UBRSpaceViewDirectionRightQuarter  = 1 << 8
};

@interface UIView (UBRSpaceView)

@property (nonatomic, strong) UBRSpaceViewInfo * svInfo;

@end


@interface UBRSpaceViewInfo : NSObject

@property (nonatomic, assign) UIPanGestureRecognizer * activeGesture;
@property (nonatomic, assign) UBRSpaceViewPosition fromPosition;
@property (nonatomic, assign) UBRSpaceViewDirection direction;
@property (nonatomic, assign) CGPoint offsetTouchLocationToCenter;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGFloat progress;
@property (readonly) UBRSpaceViewPosition positionByProgressChange;

@end

