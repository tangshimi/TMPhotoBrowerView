//
//  TMPhotoProgressView.m
//  
//
//  Created by tangshimi on 6/20/16.
//  Copyright © 2016 medtree. All rights reserved.
//

#import "TMPhotoProgressView.h"

#define kDegreeToRadian(x) (M_PI/180.0 * (x))

@implementation TMPhotoProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(40, 40);
}

- (void)drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(rect.size.height / 2, rect.size.width / 2);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2;
    
    CGFloat pathWidth = radius * 0.3f;
    
    CGFloat radians = kDegreeToRadian((self.progress*359.9)-90);
    CGFloat xOffset = radius*(1 + 0.85*cosf(radians));
    CGFloat yOffset = radius*(1 + 0.85*sinf(radians));
    CGPoint endPoint = CGPointMake(xOffset, yOffset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.3f] setFill];
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, kDegreeToRadian(270), kDegreeToRadian(-90), NO);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    [[UIColor whiteColor] setFill];
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, kDegreeToRadian(270), radians, NO);
    CGPathCloseSubpath(progressPath);
    CGContextAddPath(context, progressPath);
    CGContextFillPath(context);
    CGPathRelease(progressPath);
    
    CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth/2, 0, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth/2, endPoint.y - pathWidth/2, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);;
    CGFloat innerRadius = radius * 0.7;
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2));
    CGContextFillPath(context);
}

#pragma mark -
#pragma mark - setter and getter -

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
