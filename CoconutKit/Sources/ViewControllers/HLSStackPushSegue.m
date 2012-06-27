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

@implementation HLSStackPushSegue

#pragma mark Overrides

- (void)perform
{
    // The source is a stack controller. The segue is used to set its root view controller
    if ([self.sourceViewController isKindOfClass:[HLSStackController class]]) {
        HLSStackController *stackController = (HLSStackController *)self.sourceViewController;
        if (! [self.identifier isEqualToString:@"root"]) {
            HLSLoggerError(@"The push segue attached to a stack controller must be called 'root'");
            return;
        }
        
        if ([[stackController viewControllers] count] != 0) {
            HLSLoggerError(@"The segue called 'root can only be used to set a root view controller. No view controller "
                           "must have been loaded before");
            return;
        }
        
        [stackController pushViewController:self.destinationViewController];
    }
    // The source is an arbitrary view controller. Check that it is embedded into a stack controller, and
    // push the destination view controller into it
    else {
        UIViewController *sourceViewController = (UIViewController *)self.sourceViewController;
        if (! sourceViewController.stackController) {
            HLSLoggerError(@"The source view controller is not embedded into a stack controller");
            return;
        }
        
        [sourceViewController.stackController pushViewController:self.destinationViewController];
    }
}

@end
