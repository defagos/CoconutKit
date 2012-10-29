//
//  RootSplitViewDemoController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10/29/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "RootSplitViewDemoController.h"

@implementation RootSplitViewDemoController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@", self, HLSStringFromBool(animated));
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    HLSLoggerInfo(@"Called for object %@", self);
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    HLSLoggerInfo(@"Called");
    
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called, toInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called, fromInterfaceOrientation = %@", HLSStringFromInterfaceOrientation(fromInterfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"RootSplitViewDemoController";
}

@end
