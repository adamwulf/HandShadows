//
//  MMHandPathHelper.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
@import PerformanceBezier;

@interface MMDrawingGestureShadow : NSObject{
    CGRect boundingBox;
    UIBezierPath* pointerFingerPath;
    UIBezierPath* indexFingerTipPath;
}

@property (readonly) UIBezierPath* pointerFingerPath;

- (instancetype)init NS_UNAVAILABLE;
-(id) initForRightHand:(BOOL)isRight;

-(UIBezierPath*) path;
-(CGPoint) locationOfIndexFingerInPathBounds;

@end
