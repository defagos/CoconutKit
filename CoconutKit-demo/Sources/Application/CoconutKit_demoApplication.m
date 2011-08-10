//
//  CoconutKit_demoApplication.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CoconutKit_demoApplication.h"

#import "DemosListViewController.h"

@interface CoconutKit_demoApplication ()

@property (nonatomic, retain) UINavigationController *navigationController;

@end

@implementation CoconutKit_demoApplication

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        DemosListViewController *demosListViewController = [[[DemosListViewController alloc] init] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:demosListViewController] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.navigationController = nil;
    [super dealloc];
}

#pragma mark Accesors and mutators

@synthesize navigationController = m_navigationController;

- (UIViewController *)viewController
{
    return self.navigationController;
}

@end
