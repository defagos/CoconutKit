//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "RootStackDemoViewController.h"

#import "MemoryWarningTestCoverViewController.h"
#import "StretchableViewController.h"

@interface RootStackDemoViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (nonatomic, weak) IBOutlet UIButton *popButton;
@property (nonatomic, weak) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, weak) IBOutlet UISwitch *animatedSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *portraitSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *landscapeRightSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *landscapeLeftSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *portraitUpsideDownSwitch;
@property (nonatomic, weak) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

@end

@implementation RootStackDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
        
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    self.portraitSwitch.on = YES;
    self.landscapeRightSwitch.on = YES;
    self.landscapeLeftSwitch.on = YES;
    self.portraitUpsideDownSwitch.on = YES;
    
    self.autorotationModeSegmentedControl.selectedSegmentIndex = self.stackController.autorotationMode;
    
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
    
    self.backBarButtonItem.title = HLSLocalizedStringFromUIKit(@"Back");
    
    if (self == [self.stackController rootViewController]) {
        [self.popButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    }
    else {
        [self.popButton setTitle:NSLocalizedString(@"Pop", nil) forState:UIControlStateNormal];
    }
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[HLSTransition availableTransitionNames] count];
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[HLSTransition availableTransitionNames] objectAtIndex:row];
}

#pragma mark Displaying view controllers

- (void)displayViewController:(UIViewController *)viewController
{
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    NSString *transitionName = [[HLSTransition availableTransitionNames] objectAtIndex:pickedIndex];
    [self.stackController pushViewController:viewController
                         withTransitionClass:NSClassFromString(transitionName)
                                    animated:self.animatedSwitch.on];
}

#pragma mark Event callbacks

- (IBAction)push:(id)sender
{
    RootStackDemoViewController *demoViewController = [[RootStackDemoViewController alloc] init];
    [self displayViewController:demoViewController];
}

- (IBAction)pop:(id)sender
{
    if (self == [self.stackController rootViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.stackController popViewControllerAnimated:self.animatedSwitch.on];
    }
}

- (IBAction)pushTabBarController:(id)sender
{
    StretchableViewController *stretchableViewController = [[StretchableViewController alloc] init];
    stretchableViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                                                  style:UIBarButtonItemStyleDone
                                                                                                 target:self
                                                                                                 action:@selector(closeNativeContainer:)];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:stretchableViewController];
    navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[navigationController];
    [self displayViewController:tabBarController];    
}

- (IBAction)pushNavigationController:(id)sender
{
    StretchableViewController *stretchableViewController = [[StretchableViewController alloc] init];
    stretchableViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                                                  style:UIBarButtonItemStyleDone
                                                                                                 target:self
                                                                                                 action:@selector(closeNativeContainer:)];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:stretchableViewController];
    navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
    [self displayViewController:navigationController];
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[MemoryWarningTestCoverViewController alloc] init];
    memoryWarningTestCoverViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:memoryWarningTestCoverViewController animated:YES completion:nil];
}

- (void)closeNativeContainer:(id)sender
{
    [self.stackController popViewControllerAnimated:YES];
}

- (IBAction)changeAutorotationMode:(id)sender
{
    self.stackController.autorotationMode = self.autorotationModeSegmentedControl.selectedSegmentIndex;
}

@end
