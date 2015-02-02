//
//  ViewController.m
//  ios-hand-shadows
//
//  Created by Adam Wulf on 2/2/15.
//  Copyright (c) 2015 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import "MMShadowHandView.h"

@implementation ViewController{
    MMShadowHandView* shadowView;
    UIPanGestureRecognizer* panGesture;
    UISwitch* pinchGestureSwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:panGesture];
    
    shadowView = [[MMShadowHandView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:shadowView];
    
    pinchGestureSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 60, 40)];
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(160, 100, 200, 40)];
    lbl.text = @"Pinch Gesture";
    [self.view addSubview:lbl];
    pinchGestureSwitch.on = YES;
    [pinchGestureSwitch addTarget:self action:@selector(toggleGesture:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pinchGestureSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) toggleGesture:(UISwitch*)theSwitch{
    panGesture.enabled = pinchGestureSwitch.on;
}

-(void) pan:(UIPanGestureRecognizer*)_panGesture{
    NSLog(@"pan: %d", panGesture.state);
    if(panGesture.numberOfTouches >= 2){
        CGPoint touch1 = [panGesture locationOfTouch:0 inView:self.view];
        CGPoint touch2 = [panGesture locationOfTouch:1 inView:self.view];
        
        NSArray* touchLocations = @[[NSValue valueWithCGPoint:touch1],
                                    [NSValue valueWithCGPoint:touch2]];
        
        if(panGesture.state == UIGestureRecognizerStateBegan){
            [shadowView startPanningObject:self.view withTouches:touchLocations];
        }else if(panGesture.state == UIGestureRecognizerStateChanged){
            [shadowView continuePanningObject:self.view withTouches:touchLocations];
        }
    }
    if(panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateCancelled){
        [shadowView endPanningObject:self.view];
    }
}

@end
