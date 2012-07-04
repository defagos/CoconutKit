//
//  HLSSPushSegue.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSStackPushSegue.h"

#import "HLSLogger.h"
#import "HLSStackController.h"

NSString * const HLSStackRootSegueIdentifier = @"hls_root";

@implementation HLSStackPushSegue

#pragma mark Object creation and destruction

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if ((self = [super initWithIdentifier:identifier source:source destination:destination])) {
        self.transitionStyle = HLSTransitionStyleNone;
        self.duration = kAnimationTransitionDefaultDuration;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

#pragma mark Overrides

- (void)perform
{
    HLSStackController *stackController = nil;
    
    // The source is a stack controller. The 'hls_root' segue is used to set its root view controller
    if ([self.sourceViewController isKindOfClass:[HLSStackController class]]) {
        stackController = self.sourceViewController;
        if (! [self.identifier isEqualToString:HLSStackRootSegueIdentifier]) {
            HLSLoggerError(@"The push segue attached to a stack controller must be called '%@'", HLSStackRootSegueIdentifier);
            return;
        }
        
        if ([[stackController viewControllers] count] != 0) {
            HLSLoggerError(@"The segue called '%@' can only be used to set a root view controller. No view controller "
                           "must have been loaded before", HLSStackRootSegueIdentifier);
            return;
        }
        
        if (self.transitionStyle != HLSTransitionStyleNone) {
            HLSLoggerWarn(@"The transition style has been overridden with HLSTransitionStyleNone, which is "
                          "the only style available for view controller preloading");
            self.transitionStyle = HLSTransitionStyleNone;
        }
    }
    // The source is an arbitrary view controller. Check that it is embedded into a stack controller, and
    // push the destination view controller into it
    else {
        UIViewController *sourceViewController = self.sourceViewController;
        if (! sourceViewController.stackController) {
            HLSLoggerError(@"The source view controller is not embedded into a stack controller");
            return;
        }
        
        stackController = sourceViewController.stackController;
    }
    
    [stackController pushViewController:self.destinationViewController
                    withTransitionStyle:self.transitionStyle
                               duration:self.duration];
}

@end
