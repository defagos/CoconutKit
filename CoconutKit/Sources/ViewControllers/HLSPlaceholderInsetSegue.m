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
    HLSPlaceholderViewController *placeholderViewController = nil;
    UIViewController *viewController = self.sourceViewController;
    
    // The source is a placeholder view controller. Reserved segue identifiers can be used to pre-load view controller 
    // into a placeholder view controller
    if ([self.sourceViewController isKindOfClass:[HLSPlaceholderViewController class]]) {
        placeholderViewController = self.sourceViewController;
        if ([self.identifier hasPrefix:@"init_at_index_"]) {
            NSString *indexString = [self.identifier stringByReplacingOccurrencesOfString:@"init_at_index_" withString:@""];
            static NSNumberFormatter *s_numberFormatter = nil;
            if (! s_numberFormatter) {
                s_numberFormatter = [[NSNumberFormatter alloc] init];
            }
            NSNumber *indexNumber = [s_numberFormatter numberFromString:indexString];
            if (! indexNumber) {
                HLSLoggerError(@"Cannot parse inset index from segue identifier %@", self.identifier);
                return;
            }
            
            if (self.index != [indexNumber unsignedIntegerValue]) {
                HLSLoggerWarn(@"For init_at_index_ segues, the index is given by the identifier. The index "
                              "%d manually set has been overridden");
                self.index = [indexNumber unsignedIntegerValue];
            }
            
            if (self.transitionStyle != HLSTransitionStyleNone) {
                HLSLoggerWarn(@"The transition style has been overridden with HLSTransitionStyleNone, which is "
                              "the only style available for view controller preloading");
                self.transitionStyle = HLSTransitionStyleNone;
            }
        }
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
