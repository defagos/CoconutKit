//
//  HLSPlaceholderInsetSegue.m
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSPlaceholderInsetSegue.h"

#import "HLSLogger.h"
#import "HLSPlaceholderViewController.h"

@implementation HLSPlaceholderInsetSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if ((self = [super initWithIdentifier:identifier source:source destination:destination])) {
        self.index = 0;
        self.transitionStyle = HLSTransitionStyleNone;
        self.duration = kAnimationTransitionDefaultDuration;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize index = m_index;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

#pragma mark Overrides

- (void)perform
{
    UIViewController *viewController = self.sourceViewController;
    HLSPlaceholderViewController *placeholderViewController = nil;
    if ([viewController isKindOfClass:[HLSPlaceholderViewController class]]) {
        placeholderViewController = (HLSPlaceholderViewController *)viewController;
    }
    else if (viewController.placeholderViewController) {
        placeholderViewController = viewController.placeholderViewController;
    }
    else {
        HLSLoggerError(@"The source view controller is neither a placeholder view controller not an inset view controller");
        return;
    }
    
    [placeholderViewController setInsetViewController:self.destinationViewController
                                              atIndex:self.index
                                  withTransitionStyle:self.transitionStyle 
                                             duration:self.duration];
}

@end
