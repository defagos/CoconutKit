//
//  HLSStackPopSegue.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSStackPopSegue.h"

#import "HLSLogger.h"
#import "HLSStackController.h"

@implementation HLSStackPopSegue

#pragma mark Overrides

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    if (! sourceViewController.stackController) {
        HLSLoggerError(@"The source view controller is not embedded into a stack controller");
        return;
    }
    
    [sourceViewController.stackController popViewController];
}

@end
