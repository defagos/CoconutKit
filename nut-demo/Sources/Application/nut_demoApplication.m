//
//  nut_demoApplication.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "nut_demoApplication.h"

#import "DemosListViewController.h"

@interface nut_demoApplication ()

@property (nonatomic, retain) UINavigationController *navigationController;

@end

@implementation nut_demoApplication

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
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
