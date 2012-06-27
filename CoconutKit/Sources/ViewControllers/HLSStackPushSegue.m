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
    if (! [self.sourceViewController isKindOfClass:[HLSStackController class]]) {
        HLSLoggerError(@"The source view controller is not a stack controller");
        return;
    }
    
    HLSStackController *stackController = (HLSStackController *)self.sourceViewController;
    if ([self.identifier isEqualToString:@"root"] && [[stackController viewControllers] count] != 0) {
        HLSLoggerError(@"The segue called 'root can only be used to set a root view controller. No view controller "
                       "must have been loaded");
        return;
    }
    
    [stackController pushViewController:self.destinationViewController];
}

@end
