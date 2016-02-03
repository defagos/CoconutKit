//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "ContainmentTestViewController.h"

#import "MemoryWarningTestCoverViewController.h"

@interface ContainmentTestViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *presentingModalSwitch;

@end

@implementation ContainmentTestViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.presentingModalSwitch.on = NO;
    
    // It is sufficient to log this information once, it won't change afterwards
    HLSLoggerInfo(@"navigationController = %@"
                  "\n\ttabBarController = %@"
                  "\n\tstackController = %@"
                  "\n\tplaceholderViewController = %@"
                  "\n\tparentViewController = %@"
                  "\n\tpresentedViewController = %@"
                  "\n\ttpresentingViewController = %@",
                  self.navigationController,
                  self.tabBarController,
                  self.stackController,
                  self.placeholderViewController,
                  self.parentViewController,
                  self.presentedViewController,
                  self.presentingViewController);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"isMovingToParentViewController = %@", HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"isMovingToParentViewController = %@", HLSStringFromBool([self isMovingToParentViewController]));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"isMovingFromParentViewController = %@", HLSStringFromBool([self isMovingFromParentViewController]));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"isMovingFromParentViewController = %@", HLSStringFromBool([self isMovingFromParentViewController]));
}

#pragma mark Containment

- (void)willMoveToParentViewController:(UIViewController *)parentViewController
{
    [super willMoveToParentViewController:parentViewController];
    
    HLSLoggerInfo(@"Called for object %@, parent is %@", self, parentViewController);
}

- (void)didMoveToParentViewController:(UIViewController *)parentViewController
{
    [super didMoveToParentViewController:parentViewController];
    
    HLSLoggerInfo(@"Called for object %@, parent is %@", self, parentViewController);    
}

#pragma mark Orientation management

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"interfaceOrientation = %@", HLSStringFromInterfaceOrientation(self.interfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"interfaceOrientation = %@", HLSStringFromInterfaceOrientation(self.interfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"ContainmentTestViewController";
}

#pragma mark Action callbacks

- (IBAction)hideWithModal:(id)sender
{
    // Just to test -parentViewController (if correct, then the topmost container will be presenting the modal)
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[MemoryWarningTestCoverViewController alloc] init];
    memoryWarningTestCoverViewController.modalPresentationStyle = self.presentingModalSwitch.on ? UIModalPresentationCurrentContext : UIModalPresentationFullScreen;
    [self presentViewController:memoryWarningTestCoverViewController animated:YES completion:nil];
}

@end
