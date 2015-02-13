//
//  MMSilhouetteView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum HandType{
    LEFTHAND,
    RIGHTHAND
}HandType;

@interface MMShadowHandView : UIView

// bezel
-(void) startBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;
-(void) continueBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;
-(void) endBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches;

// panning a page
-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches forHand:(HandType)hand;
-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches forHand:(HandType)hand;
-(void) endPanningObject:(id)obj forHand:(HandType)hand;

// pinch a page
-(void) startPinchingObject:(id)obj withTouches:(NSArray*)touches;
-(void) continuePinchingObject:(id)obj withTouches:(NSArray*)touches;
-(void) endPinchingObject:(id)obj;

// drawing
-(void) startDrawingAtTouch:(CGPoint)touch;
-(void) continueDrawingAtTouch:(CGPoint)touch;
-(void) endDrawing;

@end
