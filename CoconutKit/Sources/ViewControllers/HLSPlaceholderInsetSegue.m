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

NSString * const HLSPlaceholderPreloadSegueIdentifierPrefix = @"hls_preload_at_index_";

@implementation HLSPlaceholderInsetSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if ((self = [super initWithIdentifier:identifier source:source destination:destination])) {
        self.index = 0;
        self.transitionClass = [HLSTransitionNone class];
        self.duration = kAnimationTransitionDefaultDuration;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize index = m_index;

@synthesize transitionClass = m_transitionClass;

@synthesize duration = m_duration;

#pragma mark Overrides

- (void)perform
{
    HLSPlaceholderViewController *placeholderViewController = nil;
    UIViewController *viewController = self.sourceViewController;
    
    // The source is a placeholder view controller. Reserved segue identifiers can be used to preload view controllers 
    // into a placeholder view controller
    if ([self.sourceViewController isKindOfClass:[HLSPlaceholderViewController class]]) {
        placeholderViewController = self.sourceViewController;
        if ([self.identifier hasPrefix:HLSPlaceholderPreloadSegueIdentifierPrefix]) {
            NSString *indexString = [self.identifier stringByReplacingOccurrencesOfString:HLSPlaceholderPreloadSegueIdentifierPrefix
                                                                               withString:@""];
            static NSNumberFormatter *s_numberFormatter = nil;
            if (! s_numberFormatter) {
                s_numberFormatter = [[NSNumberFormatter alloc] init];
            }
            NSNumber *indexNumber = [s_numberFormatter numberFromString:indexString];
            if (! indexNumber) {
                HLSLoggerError(@"Cannot parse inset index from segue identifier '%@'", self.identifier);
                return;
            }
            
            if (self.index != [indexNumber unsignedIntegerValue]) {
                HLSLoggerWarn(@"For preloading segues, the index is extracted from the segue identifier '%@' and will override the one "
                              "(%d) manually set", self.identifier, self.index);
                self.index = [indexNumber unsignedIntegerValue];
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
                                  withTransitionClass:self.transitionClass
                                             duration:self.duration];
}

@end
