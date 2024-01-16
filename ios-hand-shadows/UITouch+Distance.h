//
//  UITouch+Distance.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/15/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

CGFloat distance(CGPoint p1, CGPoint p2);

@interface UITouch (Distance)

-(CGFloat) distanceToTouch:(UITouch*)otherTouch;


@end
