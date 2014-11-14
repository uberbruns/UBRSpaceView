//
//  UIView+SpaceViewExtension.m
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import "UIView+SpaceView.h"
#import <objc/runtime.h>



@implementation UIView (UBRSpaceView)

@dynamic svInfo;

- (id)svInfo
{
    return objc_getAssociatedObject(self, @selector(svInfo));
}


- (void)setSvInfo:(id)object
{
    objc_setAssociatedObject(self, @selector(svInfo), object, OBJC_ASSOCIATION_RETAIN);
}

@end


@implementation UBRSpaceViewInfo

- (void)setProgress:(CGFloat)value
{
    if (fabsf(value - _progress) > 0.01) {
        if (value < _progress) {
            _positionByProgressChange = UBRSpaceViewPositionStart;
        } else {
            _positionByProgressChange = UBRSpaceViewPositionEnd;
        }
    }
    _progress = value;
}

@end
