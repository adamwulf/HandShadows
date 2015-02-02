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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:panGesture];
    
    shadowView = [[MMShadowHandView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:shadowView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void) pan:(UIPanGestureRecognizer*)panGesture{
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
