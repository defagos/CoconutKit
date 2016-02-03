//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "PlaceholderDemoViewController.h"

#import "ContainmentTestViewController.h"
#import "FixedSizeViewController.h"
#import "HeavyViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "PortraitOnlyViewController.h"
#import "StretchableViewController.h"

typedef NS_ENUM(NSInteger, AutorotationModeIndex) {
    AutorotationModeIndexEnumBegin = 0,
    AutorotationModeIndexNoChildren = AutorotationModeIndexEnumBegin,
    AutorotationModeIndexAllChildren,
    AutorotationModeIndexEnumEnd,
    AutorotationModeIndexEnumSize = AutorotationModeIndexEnumEnd - AutorotationModeIndexEnumBegin
};

@interface PlaceholderDemoViewController ()

@property (nonatomic, weak) IBOutlet UIButton *heavyButton;
@property (nonatomic, weak) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, weak) IBOutlet UISwitch *inTabBarControllerSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *inNavigationControllerSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *leftPlaceholderSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *rightPlaceholderSwitch;
@property (nonatomic, weak) IBOutlet UISegmentedControl *autorotationModeSegmentedControl;

@property (nonatomic, strong) HeavyViewController *leftHeavyViewController;
@property (nonatomic, strong) HeavyViewController *rightHeavyViewController;

@end

@implementation PlaceholderDemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // To be able to test modal presentation contexts, we here make the placeholder view controller display those modal view controllers
        // with the UIModalPresentationCurrentContext presentation style.        if ([self respondsToSelector:@selector(setDefinesPresentationContext:)]) {
        self.definesPresentationContext = YES;
        
        // Preload view controllers before display. Yep, this is possible (not all placeholders have to be preloaded)!
        LifeCycleTestViewController *lifeCycleTestViewController = [[LifeCycleTestViewController alloc] init];
        [self setInsetViewController:lifeCycleTestViewController atIndex:0];
        
        // We can even assign a transition animation. Since the view controller has been preloaded, it won't be played,
        // but it will later be used if we set the inset to nil
        ContainmentTestViewController *containmentTestViewController = [[ContainmentTestViewController alloc] init];
        [self setInsetViewController:containmentTestViewController atIndex:1 withTransitionClass:[HLSTransitionCoverFromBottom class]];
        
        self.delegate = self;
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inTabBarControllerSwitch.on = NO;
    self.inNavigationControllerSwitch.on = NO;
    self.leftPlaceholderSwitch.on = YES;
    self.rightPlaceholderSwitch.on = YES;
    
    if (self.autorotationMode == HLSAutorotationModeContainerAndTopChildren || self.autorotationMode == HLSAutorotationModeContainerAndAllChildren) {
        self.autorotationModeSegmentedControl.selectedSegmentIndex = AutorotationModeIndexAllChildren;
    }
    else {
        self.autorotationModeSegmentedControl.selectedSegmentIndex = AutorotationModeIndexNoChildren;
    }
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    // We must prevent insertion of the same view controller twice (this yields an error)
    if ((self.leftHeavyViewController && self.leftPlaceholderSwitch.on && [self insetViewControllerAtIndex:0] == self.leftHeavyViewController)
        || (self.rightHeavyViewController && self.rightPlaceholderSwitch.on && [self insetViewControllerAtIndex:1] == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = @"HLSPlaceholderViewController";
    
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"No children", nil) forSegmentAtIndex:AutorotationModeIndexNoChildren];
    [self.autorotationModeSegmentedControl setTitle:NSLocalizedString(@"All", nil) forSegmentAtIndex:AutorotationModeIndexAllChildren];
}

#pragma mark Displaying an inset view controller according to the user settings

- (void)displayInsetViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{    
    // We can even embed navigation and tab bar controllers within a placeolder view controller!
    UIViewController *insetViewController = viewController;
    if (insetViewController) {
        if (self.inNavigationControllerSwitch.on) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:insetViewController];
            navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
            insetViewController = navigationController;
        }
        if (self.inTabBarControllerSwitch.on) {
            UITabBarController *tabBarController = [[UITabBarController alloc] init];
            tabBarController.viewControllers = @[insetViewController];
            insetViewController = tabBarController;
        }    
    }
        
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    NSString *transitionName = [[HLSTransition availableTransitionNames] objectAtIndex:pickedIndex];
    
    @try {
        [self setInsetViewController:insetViewController atIndex:index withTransitionClass:NSClassFromString(transitionName)];
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:NSLocalizedString(@"The view controller is not compatible with the container (most probably its orientation)", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark HLSPlaceholderViewControllerDelegate protocol implementation

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didShowInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
    
    if ((self.leftPlaceholderSwitch.on && index == 0 && viewController == self.leftHeavyViewController)
        || (self.rightPlaceholderSwitch.on && index == 1 && viewController == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
      willHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will hide inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)placeholderViewController:(HLSPlaceholderViewController *)placeholderViewController
       didHideInsetViewController:(UIViewController *)viewController
                          atIndex:(NSUInteger)index
                         animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did hide inset view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
    
    self.heavyButton.hidden = NO;
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

#pragma mark Event callbacks

- (IBAction)displayLifeCycleTest:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        LifeCycleTestViewController *lifecycleTestViewController = [[LifeCycleTestViewController alloc] init];
        [self displayInsetViewController:lifecycleTestViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        LifeCycleTestViewController *lifecycleTestViewController = [[LifeCycleTestViewController alloc] init];
        [self displayInsetViewController:lifecycleTestViewController atIndex:1];
    }
}

- (IBAction)displayContainmentTest:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        ContainmentTestViewController *containmentTestViewController = [[ContainmentTestViewController alloc] init];
        [self displayInsetViewController:containmentTestViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        ContainmentTestViewController *containmentTestViewController = [[ContainmentTestViewController alloc] init];
        [self displayInsetViewController:containmentTestViewController atIndex:1];
    }    
}

- (IBAction)displayStretchable:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        StretchableViewController *stretchableViewController = [[StretchableViewController alloc] init];
        [self displayInsetViewController:stretchableViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        StretchableViewController *stretchableViewController = [[StretchableViewController alloc] init];
        [self displayInsetViewController:stretchableViewController atIndex:1];
    }
}

- (IBAction)displayFixedSize:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        FixedSizeViewController *fixedSizeViewController = [[FixedSizeViewController alloc] init];
        [self displayInsetViewController:fixedSizeViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        FixedSizeViewController *fixedSizeViewController = [[FixedSizeViewController alloc] init];
        [self displayInsetViewController:fixedSizeViewController atIndex:1];
    }
}

- (IBAction)displayHeavy:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    // Store a strong ref to an already built HeavyViewController; this way, this view controller is kept alive and does
    // not need to be recreated from scratch each time it is displayed as inset (lazy creation suffices). This proves 
    // that caching view controller's views is made possible by HLSPlaceholderViewController if needed
    if (self.leftPlaceholderSwitch.on) {
        if (! self.leftHeavyViewController) {
            self.leftHeavyViewController = [[HeavyViewController alloc] init];
        }
        [self displayInsetViewController:self.leftHeavyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        if (! self.rightHeavyViewController) {
            self.rightHeavyViewController = [[HeavyViewController alloc] init];
        }
        [self displayInsetViewController:self.rightHeavyViewController atIndex:1];
    }
}

- (IBAction)displayPortraitOnly:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        PortraitOnlyViewController *portraitOnlyViewController = [[PortraitOnlyViewController alloc] init];
        [self displayInsetViewController:portraitOnlyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        PortraitOnlyViewController *portraitOnlyViewController = [[PortraitOnlyViewController alloc] init];
        [self displayInsetViewController:portraitOnlyViewController atIndex:1];
    }
}

- (IBAction)displayLandscapeOnly:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        LandscapeOnlyViewController *landscapeOnlyViewController = [[LandscapeOnlyViewController alloc] init];
        [self displayInsetViewController:landscapeOnlyViewController atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        LandscapeOnlyViewController *landscapeOnlyViewController = [[LandscapeOnlyViewController alloc] init];
        [self displayInsetViewController:landscapeOnlyViewController atIndex:1];
    }
}

- (IBAction)remove:(id)sender
{
    if (! self.leftPlaceholderSwitch.on && ! self.rightPlaceholderSwitch.on) {
        HLSLoggerWarn(@"You must either enable insertion / removal in the left and / or right placeholder");
        return;
    }
    
    if (self.leftPlaceholderSwitch.on) {
        [self setInsetViewController:nil atIndex:0];
    }
    if (self.rightPlaceholderSwitch.on) {
        [self setInsetViewController:nil atIndex:1];
    }
}

- (IBAction)hideWithModal:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestCoverViewController = [[MemoryWarningTestCoverViewController alloc] init];
    [self presentViewController:memoryWarningTestCoverViewController animated:YES completion:nil];
}

- (IBAction)togglePlaceholder:(id)sender
{
    // We must prevent insertion of the same view controller twice (this yields an error)
    if ((self.leftHeavyViewController && self.leftPlaceholderSwitch.on && [self insetViewControllerAtIndex:0] == self.leftHeavyViewController)
        || (self.rightHeavyViewController && self.rightPlaceholderSwitch.on && [self insetViewControllerAtIndex:1] == self.rightHeavyViewController)) {
        self.heavyButton.hidden = YES;
    }
    else {
        self.heavyButton.hidden = NO;
    }
}

- (IBAction)changeAutorotationMode:(id)sender
{
    if (self.autorotationModeSegmentedControl.selectedSegmentIndex == AutorotationModeIndexNoChildren) {
        self.autorotationMode = HLSAutorotationModeContainerAndNoChildren;
    }
    // All rotation modes involving children are equivalent for a placeholder view controller. Pick any of them
    else {
        self.autorotationMode = HLSAutorotationModeContainerAndAllChildren;
    }
}

- (IBAction)testResponderChain:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HLSLocalizedStringFromUIKit(@"OK")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)navigateForwardNonAnimated:(id)sender
{
    PlaceholderDemoViewController *placeholderDemoViewController = [[PlaceholderDemoViewController alloc] init];
    [self.navigationController pushViewController:placeholderDemoViewController animated:NO];
}

- (IBAction)navigateBackNonAnimated:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
