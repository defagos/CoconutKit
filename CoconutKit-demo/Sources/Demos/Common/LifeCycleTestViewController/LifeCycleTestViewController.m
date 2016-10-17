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
     
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@",
                  self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]));
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    HLSLoggerInfo(@"Called");
    
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    return [super supportedInterfaceOrientations];
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
    
    self.title = NSLocalizedString(@"LifeCycleTestViewController", nil);
}

@end
