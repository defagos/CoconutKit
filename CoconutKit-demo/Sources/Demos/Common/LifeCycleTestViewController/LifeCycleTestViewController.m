//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "LifeCycleTestViewController.h"

@implementation LifeCycleTestViewController

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
     
    HLSLoggerInfo(@"Called for object %@, animated = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@, isMovingToParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation), HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@, isMovingToParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation), HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@, isMovingFromParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation), HLSStringFromBool([self isMovingFromParentViewController]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@, isMovingFromParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation), HLSStringFromBool([self isMovingFromParentViewController]));
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
    
    return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    return [super supportedInterfaceOrientations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Calledfor object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@",
                  self, HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@",
                  self, HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called for object %@, fromInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@",
                  self, HLSStringFromInterfaceOrientation(fromInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

#pragma mark Layout management

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    HLSLoggerInfo(@"Called");
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    HLSLoggerInfo(@"Called");
}

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    HLSLoggerInfo(@"Called");
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"LifeCycleTestViewController";
}

@end
