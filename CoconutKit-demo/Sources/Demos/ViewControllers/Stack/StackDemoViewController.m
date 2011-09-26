//
//  StackDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "StackDemoViewController.h"

#import "ContainerCustomizationViewController.h"
#import "FixedSizeViewController.h"
#import "LandscapeOnlyViewController.h"
#import "LifeCycleTestViewController.h"
#import "MemoryWarningTestCoverViewController.h"
#import "OrientationClonerViewController.h"
#import "PortraitOnlyViewController.h"
#import "StretchableViewController.h"
#import "TransparentViewController.h"
#import "RootStackDemoViewController.h"

@interface StackDemoViewController ()

- (void)displayContentViewController:(UIViewController *)viewController;

- (void)lifeCycleTestSampleButtonClicked:(id)sender;
- (void)stretchableSampleButtonClicked:(id)sender;
- (void)fixedSizeSampleButtonClicked:(id)sender;
- (void)portraitOnlyButtonClicked:(id)sender;
- (void)landscapeOnlyButtonClicked:(id)sender;
- (void)hideWithModalButtonClicked:(id)sender;
- (void)orientationClonerButtonClicked:(id)sender;
- (void)containerCustomizationButtonClicked:(id)sender;
- (void)transparentButtonClicked:(id)sender;
- (void)testInModalButtonClicked:(id)sender;
- (void)popButtonClicked:(id)sender;
- (void)forwardingPropertiesSwitchValueChanged:(id)sender;

@end

@implementation StackDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        UIViewController *rootViewController = [[[LifeCycleTestViewController alloc] init] autorelease];        
        HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootViewController] autorelease];
        stackController.title = @"HLSStackController";
        
        // Pre-load other view controllers before display. Yep, this is possible!
        UIViewController *firstViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:firstViewController withTransitionStyle:HLSTransitionStyleEmergeFromCenter];
        UIViewController *secondViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:secondViewController withTransitionStyle:HLSTransitionStylePushFromRight];
        UIViewController *thirdViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:thirdViewController withTransitionStyle:HLSTransitionStyleCoverFromBottom];
        UIViewController *fourthViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
        [stackController pushViewController:fourthViewController withTransitionStyle:HLSTransitionStylePushFromTop];
        
        self.insetViewController = stackController;
        self.forwardingProperties = YES;
    }
    return self;
}

- (void)releaseViews
{ 
    [super releaseViews];
    
    self.lifecycleTestSampleButton = nil;
    self.stretchableSampleButton = nil;
    self.fixedSizeSampleButton = nil;
    self.portraitOnlyButton = nil;
    self.landscapeOnlyButton = nil;
    self.orientationClonerButton = nil;
    self.containerCustomizationButton = nil;
    self.transparentButton = nil;
    self.testInModalButton = nil;
    self.popButton = nil;
    self.hideWithModalButton = nil;
    self.transitionLabel = nil;
    self.transitionPickerView = nil;
    self.forwardingPropertiesLabel = nil;
    self.forwardingPropertiesSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize lifecycleTestSampleButton = m_lifecycleTestSampleButton;

@synthesize stretchableSampleButton = m_stretchableSampleButton;

@synthesize fixedSizeSampleButton = m_fixedSizeSampleButton;

@synthesize portraitOnlyButton = m_portraitOnlyButton;

@synthesize landscapeOnlyButton = m_landscapeOnlyButton;

@synthesize orientationClonerButton = m_orientationClonerButton;

@synthesize containerCustomizationButton = m_containerCustomizationButton;

@synthesize transparentButton = m_transparentButton;

@synthesize testInModalButton = m_testInModalButton;

@synthesize popButton = m_popButton;

@synthesize hideWithModalButton = m_hideWithModalButton;

@synthesize transitionLabel = m_transitionLabel;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize forwardingPropertiesLabel = m_forwardingPropertiesLabel;

@synthesize forwardingPropertiesSwitch = m_forwardingPropertiesSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lifecycleTestSampleButton addTarget:self
                                       action:@selector(lifeCycleTestSampleButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [self.stretchableSampleButton addTarget:self
                                     action:@selector(stretchableSampleButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.fixedSizeSampleButton addTarget:self
                                   action:@selector(fixedSizeSampleButtonClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [self.portraitOnlyButton addTarget:self
                                action:@selector(portraitOnlyButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.landscapeOnlyButton addTarget:self
                                 action:@selector(landscapeOnlyButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.orientationClonerButton addTarget:self
                                     action:@selector(orientationClonerButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerCustomizationButton addTarget:self
                                          action:@selector(containerCustomizationButtonClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [self.transparentButton addTarget:self
                               action:@selector(transparentButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.testInModalButton addTarget:self
                               action:@selector(testInModalButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.popButton addTarget:self
                       action:@selector(popButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.hideWithModalButton addTarget:self
                                 action:@selector(hideWithModalButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    self.forwardingPropertiesSwitch.on = stackController.forwardingProperties;
    [self.forwardingPropertiesSwitch addTarget:self
                                        action:@selector(forwardingPropertiesSwitchValueChanged:)
                              forControlEvents:UIControlEventValueChanged];    
}

#pragma mark Displaying a view controller according to the user settings

- (void)displayContentViewController:(UIViewController *)viewController
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    [stackController pushViewController:viewController withTransitionStyle:pickedIndex];
}

#pragma mark Event callbacks

- (void)lifeCycleTestSampleButtonClicked:(id)sender
{
    LifeCycleTestViewController *lifecycleTestViewController = [[[LifeCycleTestViewController alloc] init] autorelease];
    [self displayContentViewController:lifecycleTestViewController];
}

- (void)stretchableSampleButtonClicked:(id)sender
{
    StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
    [self displayContentViewController:stretchableViewController];
}

- (void)fixedSizeSampleButtonClicked:(id)sender
{
    FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
    [self displayContentViewController:fixedSizeViewController];
}

- (void)portraitOnlyButtonClicked:(id)sender
{
    PortraitOnlyViewController *portraitOnlyViewController = [[[PortraitOnlyViewController alloc] init] autorelease];
    [self displayContentViewController:portraitOnlyViewController];
}

- (void)landscapeOnlyButtonClicked:(id)sender
{
    LandscapeOnlyViewController *landscapeOnlyViewController = [[[LandscapeOnlyViewController alloc] init] autorelease];
    [self displayContentViewController:landscapeOnlyViewController];
}

- (void)hideWithModalButtonClicked:(id)sender
{
    MemoryWarningTestCoverViewController *memoryWarningTestViewController = [[[MemoryWarningTestCoverViewController alloc] init] autorelease];
    [self presentModalViewController:memoryWarningTestViewController animated:YES];
}

- (void)orientationClonerButtonClicked:(id)sender
{
    OrientationClonerViewController *orientationClonerViewController = [[[OrientationClonerViewController alloc] 
                                                                         initWithPortraitOrientation:UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
                                                                         large:NO]
                                                                        autorelease];
    [self displayContentViewController:orientationClonerViewController];
}

- (void)transparentButtonClicked:(id)sender
{
    TransparentViewController *transparentViewController = [[[TransparentViewController alloc] init] autorelease];
    [self displayContentViewController:transparentViewController];
}

- (void)testInModalButtonClicked:(id)sender
{
    RootStackDemoViewController *rootStackDemoViewController = [[[RootStackDemoViewController alloc] init] autorelease];
    HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController] autorelease];
    [self presentModalViewController:stackController animated:YES];
}

- (void)containerCustomizationButtonClicked:(id)sender
{
    ContainerCustomizationViewController *containerCustomizationViewController = [[[ContainerCustomizationViewController alloc] init] autorelease];
    [self displayContentViewController:containerCustomizationViewController];
}

- (void)popButtonClicked:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    [stackController popViewController];
}

- (void)forwardingPropertiesSwitchValueChanged:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    stackController.forwardingProperties = self.forwardingPropertiesSwitch.on;
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return HLSTransitionStyleEnumSize;
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case HLSTransitionStyleNone: {
            return @"HLSTransitionStyleNone";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            return @"HLSTransitionStyleCoverFromBottom";
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            return @"HLSTransitionStyleCoverFromTop";
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            return @"HLSTransitionStyleCoverFromLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromRight: {
            return @"HLSTransitionStyleCoverFromRight";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft: {
            return @"HLSTransitionStyleCoverFromTopLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight: {
            return @"HLSTransitionStyleCoverFromTopRight";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            return @"HLSTransitionStyleCoverFromBottomLeft";
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight: {
            return @"HLSTransitionStyleCoverFromBottomRight";
            break;
        }
            
        case HLSTransitionStyleFadeIn: {
            return @"HLSTransitionStyleFadeIn";
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            return @"HLSTransitionStyleCrossDissolve";
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            return @"HLSTransitionStylePushFromBottom";
            break;
        }
            
        case HLSTransitionStylePushFromTop: {
            return @"HLSTransitionStylePushFromTop";
            break;
        }
            
        case HLSTransitionStylePushFromLeft: {
            return @"HLSTransitionStylePushFromLeft";
            break;
        }
            
        case HLSTransitionStylePushFromRight: {
            return @"HLSTransitionStylePushFromRight";
            break;
        }
            
        case HLSTransitionStyleEmergeFromCenter: {
            return @"HLSTransitionStyleEmergeFromCenter";
            break;
        }
            
        default: {
            return @"";
            break;
        }            
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    [self.lifecycleTestSampleButton setTitle:NSLocalizedString(@"Lifecycle test", @"Lifecycle test") forState:UIControlStateNormal];
    [self.stretchableSampleButton setTitle:NSLocalizedString(@"Stretchable", @"Stretchable") forState:UIControlStateNormal];
    [self.fixedSizeSampleButton setTitle:NSLocalizedString(@"Fixed size", @"Fixed size") forState:UIControlStateNormal];
    [self.portraitOnlyButton setTitle:NSLocalizedString(@"Portrait only", @"Portrait only") forState:UIControlStateNormal];
    [self.landscapeOnlyButton setTitle:NSLocalizedString(@"Landscape only", @"Landscape only") forState:UIControlStateNormal];
    [self.orientationClonerButton setTitle:@"HLSOrientationCloner" forState:UIControlStateNormal];
    [self.containerCustomizationButton setTitle:NSLocalizedString(@"Container customization", @"Container customization") forState:UIControlStateNormal];
    [self.transparentButton setTitle:NSLocalizedString(@"Transparent", @"Transparent") forState:UIControlStateNormal];
    [self.testInModalButton setTitle:NSLocalizedString(@"Test in modal", @"Test in modal") forState:UIControlStateNormal];
    [self.popButton setTitle:NSLocalizedString(@"Pop", @"Pop") forState:UIControlStateNormal];
    [self.hideWithModalButton setTitle:NSLocalizedString(@"Hide with modal", @"Hide with modal") forState:UIControlStateNormal];
    self.transitionLabel.text = NSLocalizedString(@"Transition", @"Transition");
    self.forwardingPropertiesLabel.text = NSLocalizedString(@"Forwarding properties", @"Forwarding properties");
}

@end
