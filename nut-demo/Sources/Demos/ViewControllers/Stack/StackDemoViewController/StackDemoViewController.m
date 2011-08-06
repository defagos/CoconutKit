//
//  StackDemoViewController.m
//  nut-demo
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
- (void)popButtonClicked:(id)sender;
- (void)stretchingContentSwitchValueChanged:(id)sender;
- (void)forwardingPropertiesSwitchValueChanged:(id)sender;

@end

@implementation StackDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        UIViewController *rootViewController = [[[LifeCycleTestViewController alloc] init] autorelease];        
        HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootViewController] autorelease];
        stackController.title = @"HLSStackController";
        stackController.stretchingContent = YES;
        
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
        self.stretchingContent = YES;
        self.forwardingPropertiesEnabled = YES;
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
    self.popButton = nil;
    self.hideWithModalButton = nil;
    self.transitionLabel = nil;
    self.transitionPickerView = nil;
    self.stretchingContentLabel = nil;
    self.stretchingContentSwitch = nil;
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

@synthesize popButton = m_popButton;

@synthesize hideWithModalButton = m_hideWithModalButton;

@synthesize transitionLabel = m_transitionLabel;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize stretchingContentLabel = m_stretchingContentLabel;

@synthesize stretchingContentSwitch = m_stretchingContentSwitch;

@synthesize forwardingPropertiesLabel = m_forwardingPropertiesLabel;

@synthesize forwardingPropertiesSwitch = m_forwardingPropertiesSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lifecycleTestSampleButton setTitle:NSLocalizedString(@"Lifecycle test", @"Lifecycle test")
                                    forState:UIControlStateNormal];
    [self.lifecycleTestSampleButton addTarget:self
                                       action:@selector(lifeCycleTestSampleButtonClicked:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [self.stretchableSampleButton setTitle:NSLocalizedString(@"Stretchable", @"Stretchable") 
                                  forState:UIControlStateNormal];
    [self.stretchableSampleButton addTarget:self
                                     action:@selector(stretchableSampleButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.fixedSizeSampleButton setTitle:NSLocalizedString(@"Fixed size", @"Fixed size") 
                                forState:UIControlStateNormal];
    [self.fixedSizeSampleButton addTarget:self
                                   action:@selector(fixedSizeSampleButtonClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [self.portraitOnlyButton setTitle:NSLocalizedString(@"Portrait only", @"Portrait only") 
                             forState:UIControlStateNormal];
    [self.portraitOnlyButton addTarget:self
                                action:@selector(portraitOnlyButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.landscapeOnlyButton setTitle:NSLocalizedString(@"Landscape only", @"Landscape only") 
                              forState:UIControlStateNormal];
    [self.landscapeOnlyButton addTarget:self
                                 action:@selector(landscapeOnlyButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.orientationClonerButton setTitle:@"HLSOrientationCloner"
                                  forState:UIControlStateNormal];
    [self.orientationClonerButton addTarget:self
                                     action:@selector(orientationClonerButtonClicked:)
                           forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerCustomizationButton setTitle:NSLocalizedString(@"Container customization", @"Container customization")
                                       forState:UIControlStateNormal];
    [self.containerCustomizationButton addTarget:self
                                          action:@selector(containerCustomizationButtonClicked:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [self.transparentButton setTitle:NSLocalizedString(@"Transparent", @"Transparent")
                            forState:UIControlStateNormal];
    [self.transparentButton addTarget:self
                               action:@selector(transparentButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.popButton setTitle:NSLocalizedString(@"Pop", @"Pop")
                    forState:UIControlStateNormal];
    [self.popButton addTarget:self
                       action:@selector(popButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.hideWithModalButton setTitle:NSLocalizedString(@"Hide with modal", @"Hide with modal")
                              forState:UIControlStateNormal];
    [self.hideWithModalButton addTarget:self
                                 action:@selector(hideWithModalButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    self.transitionLabel.text = NSLocalizedString(@"Transition", @"Transition");
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
    
    self.stretchingContentLabel.text = NSLocalizedString(@"Stretch content", @"Stretch content");
    
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    self.stretchingContentSwitch.on = stackController.stretchingContent;
    [self.stretchingContentSwitch addTarget:self
                                     action:@selector(stretchingContentSwitchValueChanged:)
                           forControlEvents:UIControlEventValueChanged];
    
    self.forwardingPropertiesLabel.text = NSLocalizedString(@"Forwarding properties", @"Forwarding properties");
    
    self.forwardingPropertiesSwitch.on = stackController.forwardingPropertiesEnabled;
    [self.forwardingPropertiesSwitch addTarget:self
                                        action:@selector(forwardingPropertiesSwitchValueChanged:)
                              forControlEvents:UIControlEventValueChanged];    
}

#pragma mark Displaying a view controller according to the user settings

- (void)displayContentViewController:(UIViewController *)viewController
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    
    // Built-in transition effects in picker
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    if (pickedIndex < HLSTransitionStyleEnumSize) {
        [stackController pushViewController:viewController withTransitionStyle:pickedIndex];
    }
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

- (void)stretchingContentSwitchValueChanged:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    stackController.stretchingContent = self.stretchingContentSwitch.on;
}

- (void)forwardingPropertiesSwitchValueChanged:(id)sender
{
    HLSStackController *stackController = (HLSStackController *)self.insetViewController;
    stackController.forwardingPropertiesEnabled = self.forwardingPropertiesSwitch.on;
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

@end
