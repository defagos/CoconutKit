//
//  nut_demoAppDelegate.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "nut_demoAppDelegate.h"

@implementation nut_demoAppDelegate

#pragma mark Object construction and destruction

- (void)dealloc
{
    self.window = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize window = m_window;

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

@end
