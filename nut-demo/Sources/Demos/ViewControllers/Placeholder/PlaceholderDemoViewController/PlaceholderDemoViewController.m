//
//  PlaceholderDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/14/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PlaceholderDemoViewController.h"

#import "FixedSizeViewController.h"
#import "StretchableViewController.h"

@interface PlaceholderDemoViewController ()

- (void)displayInsetViewController:(UIViewController *)viewController;

- (void)stretchableSampleButtonClicked:(id)sender;
- (void)fixedSizeSampleButtonClicked:(id)sender;
- (void)heavySampleButtonClicked:(id)sender;
- (void)portraitOnlyButtonClicked:(id)sender;
- (void)landscapeOnlyButtonClicked:(id)sender;
- (void)orientationClonerButtonClicked:(id)sender;
- (void)adjustingInsetSwitchValueChanged:(id)sender;

@end

@implementation PlaceholderDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.title = @"HLSPlaceholderViewController";
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.stretchableSampleButton = nil;
    self.fixedSizeSampleButton = nil;
    self.heavySampleButton = nil;
    self.portraitOnlyButton = nil;
    self.landscapeOnlyButton = nil;
    self.orientationClonerButton = nil;
    self.transitionLabel = nil;
    self.transitionPickerView = nil;
    self.adjustingInsetLabel = nil;
    self.adjustingInsetSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize stretchableSampleButton = m_stretchableSampleButton;

@synthesize fixedSizeSampleButton = m_fixedSizeSampleButton;

@synthesize heavySampleButton = m_heavySampleButton;

@synthesize portraitOnlyButton = m_portraitOnlyButton;

@synthesize landscapeOnlyButton = m_landscapeOnlyButton;

@synthesize orientationClonerButton = m_orientationClonerButton;

@synthesize transitionLabel = m_transitionLabel;

@synthesize transitionPickerView = m_transitionPickerView;

@synthesize adjustingInsetLabel = m_adjustingInsetLabel;

@synthesize adjustingInsetSwitch = m_adjustingInsetSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [self.heavySampleButton setTitle:NSLocalizedString(@"Heavy view", @"Heavy view") 
                            forState:UIControlStateNormal];
    [self.heavySampleButton addTarget:self
                               action:@selector(heavySampleButtonClicked:)
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
    
    self.adjustingInsetLabel.text = NSLocalizedString(@"Adjust inset", @"Adjust inset");
    
    self.adjustingInsetSwitch.on = self.adjustingInset;
    [self.adjustingInsetSwitch addTarget:self
                                  action:@selector(adjustingInsetSwitchValueChanged:)
                        forControlEvents:UIControlEventValueChanged];    
    
    self.transitionLabel.text = NSLocalizedString(@"Transition", @"Transition");
    
    self.transitionPickerView.delegate = self;
    self.transitionPickerView.dataSource = self;
}

#pragma mark Displaying an inset view controller according to the user settings

- (void)displayInsetViewController:(UIViewController *)viewController
{
    // Built-in transition effects in picker
    NSUInteger pickedIndex = [self.transitionPickerView selectedRowInComponent:0];
    if (pickedIndex < HLSTransitionStyleEnumSize) {
        [self setInsetViewController:viewController withTransitionStyle:pickedIndex];
    }
    // Custom transition effects in picker
    else {
        
    }
}

#pragma mark Event callbacks

- (void)stretchableSampleButtonClicked:(id)sender
{
    StretchableViewController *stretchableViewController = [[[StretchableViewController alloc] init] autorelease];
    [self displayInsetViewController:stretchableViewController];
}

- (void)fixedSizeSampleButtonClicked:(id)sender
{
    FixedSizeViewController *fixedSizeViewController = [[[FixedSizeViewController alloc] init] autorelease];
    [self displayInsetViewController:fixedSizeViewController];
}

- (void)heavySampleButtonClicked:(id)sender
{

}

- (void)portraitOnlyButtonClicked:(id)sender
{

}

- (void)landscapeOnlyButtonClicked:(id)sender
{

}

- (void)orientationClonerButtonClicked:(id)sender
{

}

- (void)adjustingInsetSwitchValueChanged:(id)sender
{
    self.adjustingInset = self.adjustingInsetSwitch.on;
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return HLSTransitionStyleEnumSize + 1;              // + 1 is for a custom style; first HLSTransitionStyleEnumSize are reserved for built-in transitions
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
            
        // From now on: Custom transitions
            
        case HLSTransitionStyleEnumSize: {
            return NSLocalizedString(@"Custom transition", @"Custom transition");
            break;
        }
            
        default: {
            return @"";
            break;
        }            
    }
}

@end
