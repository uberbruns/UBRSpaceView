//
//  UBRSpaceGeometry.h
//  Space View
//
//  Created by Karsten Bruns on 29/06/14.
//  Copyright (c) 2014 Karsten Bruns. All rights reserved.
//



CG_INLINE CGFloat
UBRDistance(CGPoint point1, CGPoint point2)
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
    
}


CG_INLINE CGFloat
UBRAngleBetweenPoints(CGPoint a, CGPoint b)
{
    CGFloat dx = b.x - a.x;
    CGFloat dy = b.y - a.y;
    return atan2(-dx,dy);
}

CG_INLINE CGPoint
UBRCenterForRect(CGRect rect)
{
    CGFloat x = (CGRectGetMaxX(rect) + CGRectGetMinX(rect)) / 2;
    CGFloat y = (CGRectGetMaxY(rect) + CGRectGetMinY(rect)) / 2;
    return CGPointMake(x, y);
}


CG_INLINE CGRect
UBRRoundRect(CGRect rect)
{
    rect.origin.x = rect.origin.x;
    rect.origin.y = rect.origin.y;
    rect.size.width = roundf(rect.size.width);
    rect.size.height = roundf(rect.size.height);
    return rect;
}


CG_INLINE CGRect
UBRScaleRect(CGRect minRect, CGRect maxRect, CGFloat f)
{
    CGRect result = CGRectZero;
    result.origin.x = minRect.origin.x + (maxRect.origin.x - minRect.origin.x) * f;
    result.origin.y = minRect.origin.y + (maxRect.origin.y - minRect.origin.y) * f;
    result.size.width = minRect.size.width + (maxRect.size.width - minRect.size.width) * f;
    result.size.height = minRect.size.height + (maxRect.size.height - minRect.size.height) * f;
    return result;
}


CG_INLINE CGPoint
UBRIntermediatePoint(CGPoint startPoint, CGPoint endPoint, CGPoint nearPoint)
{
    CGFloat x;
    CGFloat y;
    
    if (startPoint.x == endPoint.x) {
        x = startPoint.x;
        y = nearPoint.y;
    } else if (startPoint.y == endPoint.y) {
        x = nearPoint.x;
        y = startPoint.y;
    } else {
        CGFloat m1 = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
        CGFloat m2 = -1.0 / m1;
        CGFloat c1 = startPoint.y - (m1 * startPoint.x);
        CGFloat c2 = nearPoint.y - (m2 * nearPoint.x);
        x = (c1 - c2) / (m2 - m1);
        y = m2 * x + c2;
    }
    
    return CGPointMake(x, y);
}


CG_INLINE CGFloat
UBRProgressBetweenRects(CGRect startRect, CGRect endRect, CGPoint position)
{
    CGPoint startPoint = UBRCenterForRect(startRect);
    CGPoint endPoint = UBRCenterForRect(endRect);
    CGPoint intermediatePoint = UBRIntermediatePoint(startPoint, endPoint, position);
    
    CGFloat distanceStartToEnd = UBRDistance(startPoint, endPoint);
    CGFloat distanceStartToIntermediatePoint = UBRDistance(startPoint, intermediatePoint);
    CGFloat distanceEndToIntermediatePoint = UBRDistance(endPoint, intermediatePoint);
    
    CGFloat progress;
    if (distanceEndToIntermediatePoint > distanceStartToEnd) {
        progress = distanceStartToIntermediatePoint/-distanceStartToEnd;
    } else {
        progress = distanceStartToIntermediatePoint/distanceStartToEnd;
    }
    
    return fmaxf(fminf(progress, 1), 0);
}