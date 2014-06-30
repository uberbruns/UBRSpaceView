//
//  UIGestureRecognizer+SpaceView.m
//  Space View
//
//  Created by Karsten Bruns on 22/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//

#import "UIGestureRecognizer+SpaceView.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (UBRSpaceView)
@dynamic associatedView;

- (void)setAssociatedView:(id)object {
    objc_setAssociatedObject(self, @selector(associatedView), object, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedView {
    return objc_getAssociatedObject(self, @selector(associatedView));
}


@end
