//
//  ViewController.m
//  ios-hand-shadows
//
//  Created by Adam Wulf on 2/2/15.
//  Copyright (c) 2015 Milestone Made. All rights reserved.
//

#import "ViewController.h"
@import HandShadows;

@implementation ViewController{
    HandShadowView* shadowView;
    
    // index finger and thumb
    UIPanGestureRecognizer* pinchGesture;
    UISwitch* pinchGestureSwitch;

    // index and middle fingers
    UIPanGestureRecognizer* panGesture;
    UISwitch* panGestureSwitch;

    // index finger
    UIPanGestureRecognizer* indexGesture;
    UISwitch* indexGestureSwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.userInteractionEnabled = YES;
    
    shadowView = [[HandShadowView alloc] initForHand:HandTypeLeftHand];
    [self.view addSubview:shadowView];
    
    pinchGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinchGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:pinchGesture];
    pinchGestureSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 60, 40)];
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(160, 100, 400, 40)];
    lbl.text = @"Index and Thumb Pinch Gesture";
    [self.view addSubview:lbl];
    pinchGestureSwitch.on = YES;
    [pinchGestureSwitch addTarget:self action:@selector(toggleGesture:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pinchGestureSwitch];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGesture];
    panGestureSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 160, 60, 40)];
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(160, 160, 400, 40)];
    lbl.text = @"Index and Middle Finger Pan Gesture";
    [self.view addSubview:lbl];
    panGestureSwitch.on = NO;
    [panGestureSwitch addTarget:self action:@selector(toggleGesture:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:panGestureSwitch];

    indexGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(finger:)];
    indexGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:indexGesture];
    indexGestureSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 220, 60, 40)];
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(160, 220, 400, 40)];
    lbl.text = @"Index Finger Pan Gesture";
    [self.view addSubview:lbl];
    indexGestureSwitch.on = NO;
    [indexGestureSwitch addTarget:self action:@selector(toggleGesture:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:indexGestureSwitch];

    [self toggleGesture:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) toggleGesture:(UISwitch*)aSwitch {
    pinchGesture.enabled = pinchGestureSwitch.on;
    panGesture.enabled = panGestureSwitch.on;
    indexGesture.enabled = indexGestureSwitch.on;
}

-(void) pinch:(UIPanGestureRecognizer*)_panGesture{
    if(_panGesture.numberOfTouches >= 2){
        CGPoint touch1 = [_panGesture locationOfTouch:0 inView:self.view];
        CGPoint touch2 = [_panGesture locationOfTouch:1 inView:self.view];

        if(_panGesture.state == UIGestureRecognizerStateBegan) {
            [shadowView startPinchWith:touch1 and:touch2];
        }else if(_panGesture.state == UIGestureRecognizerStateChanged){
            [shadowView continuePinchWith:touch1 and:touch2];
        }
    }
    if(_panGesture.state == UIGestureRecognizerStateEnded ||
       _panGesture.state == UIGestureRecognizerStateCancelled){
        [shadowView endPinch];
    }
}


-(void) pan:(UIPanGestureRecognizer*)_panGesture{
    if(_panGesture.numberOfTouches >= 2){
        CGPoint touch1 = [_panGesture locationOfTouch:0 inView:self.view];
        CGPoint touch2 = [_panGesture locationOfTouch:1 inView:self.view];
        
        if(_panGesture.state == UIGestureRecognizerStateBegan){
            [shadowView startTwoFingerPanWith:touch1 and:touch2];
        }else if(_panGesture.state == UIGestureRecognizerStateChanged){
            [shadowView continueTwoFingerPanWith:touch1 and:touch2];
        }
    }
    if(_panGesture.state == UIGestureRecognizerStateEnded ||
       _panGesture.state == UIGestureRecognizerStateCancelled){
        [shadowView endTwoFingerPan];
    }
}


-(void) finger:(UIPanGestureRecognizer*)_panGesture{
    if(_panGesture.numberOfTouches == 1){
        CGPoint point = [_panGesture locationOfTouch:0 inView:self.view];
        
        if(_panGesture.state == UIGestureRecognizerStateBegan){
            [shadowView startPointingAt:point];
        }else if(_panGesture.state == UIGestureRecognizerStateChanged){
            [shadowView continuePointingAt:point];
        }
    }
    if(_panGesture.state == UIGestureRecognizerStateFailed ||
       _panGesture.state == UIGestureRecognizerStateEnded ||
          _panGesture.state == UIGestureRecognizerStateCancelled){
        [shadowView endPointing];
    }
}

@end
