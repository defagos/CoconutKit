//
//  ConnectionDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.03.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "ConnectionDemoViewController.h"

@implementation ConnectionDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Code
    }
    return self;
}

- (void)dealloc
{
    // Code
    
    [super dealloc];
}

#pragma mark Accessors and mutators

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Code
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Connection", nil);
}

@end
