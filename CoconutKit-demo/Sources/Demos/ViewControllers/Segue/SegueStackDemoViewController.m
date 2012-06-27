//
//  SegueStackDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "SegueStackDemoViewController.h"

@implementation SegueStackDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Just to suppress localization warnings
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[HLSStackPushSegue class]]) {
        HLSStackPushSegue *stackPushSegue = (HLSStackPushSegue *)segue;
        if ([stackPushSegue.identifier isEqualToString:@"pushFromBottom"]) {
            stackPushSegue.transitionStyle = HLSTransitionStylePushFromBottom;
        }
        else if ([stackPushSegue.identifier isEqualToString:@"coverFromTop"]) {
            stackPushSegue.transitionStyle = HLSTransitionStyleCoverFromTop;
        }
    }
}

@end
