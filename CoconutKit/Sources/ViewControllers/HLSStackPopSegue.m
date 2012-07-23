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

#pragma mark Object creation and destruction

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if ((self = [super initWithIdentifier:identifier source:source destination:destination])) {
        self.animated = YES;
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize animated = m_animated;

#pragma mark Overrides

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    if (! sourceViewController.stackController) {
        HLSLoggerError(@"The source view controller is not embedded into a stack controller");
        return;
    }
    
    [sourceViewController.stackController popViewControllerAnimated:self.animated];
}

@end
