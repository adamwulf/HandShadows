//
//  MMShadowHand.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/19/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMShadowHand.h"
#import "MMVector.h"
#import "UITouch+Distance.h"
#import "MMDrawingGestureShadow.h"
#import "MMTwoFingerPanShadow.h"
#import "MMDrawingGestureShadow.h"
#import "MMThumbAndIndexShadow.h"

@implementation MMShadowHand{
    UIView* relativeView;
    
    BOOL isRight;
    CAShapeLayer* layer;
    MMVector* initialVector;
    
    MMDrawingGestureShadow* pointerFingerHelper;
    MMTwoFingerPanShadow* twoFingerHelper;
    MMThumbAndIndexShadow* thumbAndIndexHelper;

    id heldObject;
    NSSet* activeTouches;
    BOOL isBezeling;
    BOOL isPinching;
    BOOL isPanning;
    BOOL isDrawing;
    CGFloat recentTheta;
}

@synthesize layer;
@synthesize heldObject;


-(id) initForRightHand:(BOOL)_isRight forView:(UIView*)_relativeView{
    if(self = [super init]){
        // properties
        isRight = _isRight;
        relativeView = _relativeView;
        
        // the layer that we'll use to show the hand
        layer = [CAShapeLayer layer];
        layer.opacity = .5;
        layer.anchorPoint = CGPointZero;
        layer.position = CGPointZero;
        layer.backgroundColor = [UIColor blackColor].CGColor;

        // path helpers
        pointerFingerHelper = [[MMDrawingGestureShadow alloc] initForRightHand:isRight];
        twoFingerHelper = [[MMTwoFingerPanShadow alloc] initForRightHand:isRight];
        thumbAndIndexHelper = [[MMThumbAndIndexShadow alloc] initForRightHand:isRight];
    }
    return self;
}

-(BOOL) isActive{
    // return true if this hand is currently shown with
    // a gesture
    return isBezeling || isPanning || isDrawing || isPinching;
}
-(BOOL) isDrawing{
    return isDrawing;
}

#pragma mark - Bezeling Pages

-(void) startBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    activeTouches = [[NSSet setWithArray:touches] copy];
    isBezeling = YES;
    layer.opacity = .5;
    [self continueBezelingInFromRight:fromRight withTouches:touches];
}

-(void) continueBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    if(!isBezeling){
        [self startBezelingInFromRight:fromRight withTouches:touches];
        return;
    }
    UITouch* indexFingerTouch = [touches firstObject];
    if(!isRight && [[touches lastObject] locationInView:relativeView].x > [indexFingerTouch locationInView:relativeView].x){
        indexFingerTouch = [touches lastObject];
    }else if(isRight && [[touches lastObject] locationInView:relativeView].x < [indexFingerTouch locationInView:relativeView].x){
        indexFingerTouch = [touches lastObject];
    }
    UITouch* middleFingerTouch = [touches firstObject] == indexFingerTouch ? [touches lastObject] : [touches firstObject];

    CGPoint indexFingerLocation = [indexFingerTouch locationInView:relativeView];
    CGPoint middleFingerLocation = [middleFingerTouch locationInView:relativeView];
    if([touches count] == 1){
        // only 1 touch, so we need to fake the middle finger
        // being off the edge of the screen
        if(fromRight){
            if(isRight){
                // find the right-hand edge of the screen
                middleFingerLocation = CGPointMake(relativeView.bounds.size.width + 15, indexFingerLocation.y);
            }else{
                // find the right-hand edge of the screen
                indexFingerLocation = CGPointMake(relativeView.bounds.size.width + 15, indexFingerLocation.y);
            }
        }else{
            if(isRight){
                // find the left-hand edge of the screen
                indexFingerLocation = CGPointMake(-15, indexFingerLocation.y);
            }else{
                // find the left-hand edge of the screen
                middleFingerLocation = CGPointMake(-15, indexFingerLocation.y);
            }
        }
    }
    [self continuePanningWithIndexFinger:indexFingerLocation
                         andMiddleFinger:middleFingerLocation];
    
}

-(void) endBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    if(isBezeling){
        if(![touches count] || [activeTouches isEqualToSet:[NSSet setWithArray:touches]]){
            activeTouches = nil;
            layer.opacity = 0;
            isBezeling = NO;
        }
    }
}

#pragma mark - Panning a Page


-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches{
    heldObject = obj;
    isPanning = YES;
    layer.opacity = .5;
    recentTheta = CGFLOAT_MAX;
    [self continuePanningObject:obj withTouches:touches];
}

-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches{
    if(!isPanning){
        [self startPanningObject:obj withTouches:touches];
    }
    if(obj != heldObject){
        @throw [NSException exceptionWithName:@"ShadowException" reason:@"Asked to pan different object than what's held." userInfo:nil];
    }
    if([touches count] >= 2){
        CGPoint indexFingerTouch = [[touches firstObject] CGPointValue];
        if(!isRight && [[touches lastObject] CGPointValue].x > indexFingerTouch.x){
            indexFingerTouch = [[touches lastObject] CGPointValue];
        }else if(isRight && [[touches lastObject] CGPointValue].x < indexFingerTouch.x){
            indexFingerTouch = [[touches lastObject] CGPointValue];
        }
        CGPoint middleFingerTouch = CGPointEqualToPoint([[touches firstObject] CGPointValue], indexFingerTouch) ? [[touches lastObject] CGPointValue] : [[touches firstObject] CGPointValue];

        [self continuePanningWithIndexFinger:indexFingerTouch
                             andMiddleFinger:middleFingerTouch];
    }
}

-(void) endPanningObject:(id)obj{
    if(obj != heldObject){
        @throw [NSException exceptionWithName:@"ShadowException" reason:@"Asked to stop holding different object than what's held." userInfo:nil];
    }
    if(isPanning){
        activeTouches = nil;
        isPanning = NO;
        heldObject = nil;
        layer.opacity = 0;
    }
}



#pragma mark - Pinching a Page

-(void) startPinchingObject:(id)obj withTouches:(NSArray*)touches{
    heldObject = obj;
    isPinching = YES;
    layer.opacity = .5;
    recentTheta = CGFLOAT_MAX;
    [self continuePinchingObject:obj withTouches:touches];
}
-(void) continuePinchingObject:(id)obj withTouches:(NSArray*)touches{
    if(!isPinching){
        return;
//        [self startPinchingObject:obj withTouches:touches];
    }
    if(obj != heldObject){
        @throw [NSException exceptionWithName:@"ShadowException" reason:@"Asked to pinch different object than what's held." userInfo:nil];
    }
    if([touches count] >= 2){
        CGPoint indexFingerLocation = [[touches firstObject] CGPointValue];
        if([[touches lastObject] CGPointValue].y < indexFingerLocation.y){
            indexFingerLocation = [[touches lastObject] CGPointValue];
        }
        CGPoint middleFingerLocation = CGPointEqualToPoint([[touches firstObject] CGPointValue], indexFingerLocation) ? [[touches lastObject] CGPointValue] : [[touches firstObject] CGPointValue];
        
        
        CGFloat distance = [MMShadowHand distanceBetweenPoint:indexFingerLocation andPoint:middleFingerLocation];
    
        [thumbAndIndexHelper setFingerDistance:distance];
        [self preventCALayerImplicitAnimation:^{
            layer.path = [thumbAndIndexHelper pathForTouches:nil].CGPath;
            
            MMVector* currVector = [MMVector vectorWithPoint:indexFingerLocation
                                                    andPoint:middleFingerLocation];
            if(!isRight){
                currVector = [currVector flip];
            }
            CGFloat theta = [[MMVector vectorWithX:1 andY:0] angleBetween:currVector];
            CGPoint offset = [thumbAndIndexHelper locationOfIndexFingerInPathBounds];
            CGPoint finalLocation = CGPointMake(indexFingerLocation.x - offset.x, indexFingerLocation.y - offset.y);
            layer.position = finalLocation;
            layer.affineTransform = CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(offset.x, offset.y), theta), -offset.x, -offset.y);
        }];
    }
}
-(void) endPinchingObject:(id)obj{
    if(obj != heldObject){
        @throw [NSException exceptionWithName:@"ShadowException" reason:@"Asked to stop holding different object than what's held." userInfo:nil];
    }
    if(isPinching){
        activeTouches = nil;
        isPinching = NO;
        heldObject = nil;
        layer.opacity = 0;
    }
}

#pragma mark - Drawing Events

-(void) startDrawingAtTouch:(CGPoint)touch{
    isDrawing = YES;
    layer.opacity = .5;
    recentTheta = CGFLOAT_MAX;
    [self continueDrawingAtTouch:touch];
}
-(void) continueDrawingAtTouch:(CGPoint)locationOfTouch{
    if(!isDrawing){
        [self startDrawingAtTouch:locationOfTouch];
    }
    [self preventCALayerImplicitAnimation:^{
        layer.path = [pointerFingerHelper path].CGPath;
        CGPoint offset = [pointerFingerHelper locationOfIndexFingerInPathBounds];
        CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
        layer.position = finalLocation;
    }];
}
-(void) endDrawing{
    if(isDrawing){
        activeTouches = nil;
        isDrawing = NO;
        if(!isPanning && !isBezeling){
            layer.opacity = 0;
        }
    }
}


#pragma mark - Two Finger Gesture Helper

-(void) continuePanningWithIndexFinger:(CGPoint)indexFingerLocation andMiddleFinger:(CGPoint)middleFingerLocation{
    CGFloat distance = [MMShadowHand distanceBetweenPoint:indexFingerLocation andPoint:middleFingerLocation];
    [twoFingerHelper setFingerDistance:distance];
    [self preventCALayerImplicitAnimation:^{
        layer.path = [twoFingerHelper pathForTouches:nil].CGPath;
        
        MMVector* currVector = [MMVector vectorWithPoint:indexFingerLocation
                                                andPoint:middleFingerLocation];
        if(!isRight){
            currVector = [currVector flip];
        }
        
        CGFloat theta = [[MMVector vectorWithX:1 andY:0] angleBetween:currVector];
        CGPoint offset = [twoFingerHelper locationOfIndexFingerInPathBounds];
        CGPoint finalLocation = CGPointMake(indexFingerLocation.x - offset.x, indexFingerLocation.y - offset.y);

        NSLog(@"isright: %d  recentTheta: %f   theta: %f", isRight, recentTheta, theta);
        if(recentTheta == CGFLOAT_MAX){
            if(!isRight && theta < 0 && theta > -M_PI){
                [self continuePanningWithIndexFinger:middleFingerLocation andMiddleFinger:indexFingerLocation];
                return;
            }
            recentTheta = theta;
            NSLog(@"isright: %d  setRecentTheta: %f", isRight, recentTheta);
        }else if(ABS(recentTheta-theta) > M_PI/2 && ABS(recentTheta-theta) < M_PI*3/2){
            [self continuePanningWithIndexFinger:middleFingerLocation andMiddleFinger:indexFingerLocation];
            return;
        }else{
            recentTheta = theta;
            NSLog(@"isright: %d  setRecentTheta: %f", isRight, recentTheta);
        }

        layer.position = finalLocation;
        layer.affineTransform = CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(offset.x, offset.y), theta), -offset.x, -offset.y);
    }];
}






#pragma mark - CALayer Helper

-(void) preventCALayerImplicitAnimation:(void(^)(void))block{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    block();
    [CATransaction commit];
}

+(CGFloat) distanceBetweenPoint:(const CGPoint) p1 andPoint:(const CGPoint) p2 {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

@end
