//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "RootSplitViewDemoController.h"

#import "MemoryWarningTestCoverViewController.h"

@interface RootSplitViewDemoController ()

@property (nonatomic, weak) IBOutlet UISwitch *portraitSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *landscapeRightSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *landscapeLeftSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *portraitUpsideDownSwitch;
@property (nonatomic, weak) IBOutlet UIView *autorotationBackgroundView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

@end

@implementation RootSplitViewDemoController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.portraitSwitch.on = YES;
    self.landscapeRightSwitch.on = YES;
    self.landscapeLeftSwitch.on = YES;
    self.portraitUpsideDownSwitch.on = YES;
    
    // Display the container autorotation settings only on the right child (always visible)
    if ([self.splitViewController.viewControllers indexOfObject:self] == 0) {
        self.autorotationBackgroundView.hidden = YES;
    }
    else {
        self.autorotationBackgroundView.hidden = NO;
    }
    
    self.autorotationModeSegmentedControl.selectedSegmentIndex = self.splitViewController.autorotationMode;
    
    HLSLoggerInfo(@"Called for object %@", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingToParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingToParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    HLSLoggerInfo(@"Called for object %@, animated = %@, isMovingFromParentViewController = %@, interfaceOrientation = %@, "
                  "displayedInterfaceOrientation = %@", self, HLSStringFromBool(animated), HLSStringFromBool([self isMovingFromParentViewController]),
                  HLSStringFromInterfaceOrientation(self.interfaceOrientation), HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
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

- (BOOL)shouldAutorotate
{
    HLSLoggerInfo(@"Called");
    
    return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    HLSLoggerInfo(@"Called");
    
    NSUInteger supportedOrientations = 0;
    if ([self isViewLoaded]) {
        if (self.portraitSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskPortrait;
        }
        if (self.landscapeRightSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskLandscapeRight;
        }
        if (self.landscapeLeftSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if (self.portraitUpsideDownSwitch.on) {
            supportedOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }
    }
    else {
        supportedOrientations = UIInterfaceOrientationMaskAll;
    }
    
    return [super supportedInterfaceOrientations] & supportedOrientations;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    HLSLoggerInfo(@"Called for object %@, toInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(toInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    HLSLoggerInfo(@"Called for object %@, fromInterfaceOrientation = %@, interfaceOrientation = %@, displayedInterfaceOrientation = %@", self,
                  HLSStringFromInterfaceOrientation(fromInterfaceOrientation), HLSStringFromInterfaceOrientation(self.interfaceOrientation),
                  HLSStringFromInterfaceOrientation(self.displayedInterfaceOrientation));
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"RootSplitViewDemoController";
    
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"Container", nil) forSegmentAtIndex:0];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"No children", nil) forSegmentAtIndex:1];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"Visible", nil) forSegmentAtIndex:2];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"All", nil) forSegmentAtIndex:3];
}

#pragma mark Action callbacks

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[MemoryWarningTestCoverViewController alloc] init];
    [self presentViewController:memoryWarningTestCoverViewController animated:YES completion:nil];
}

- (IBAction)changeAutorotationMode:(id)sender
{
    self.splitViewController.autorotationMode = self.autorotationModeSegmentedControl.selectedSegmentIndex;
}

@end
