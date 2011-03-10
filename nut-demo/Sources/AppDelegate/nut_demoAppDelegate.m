//
//  nut_demoAppDelegate.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "nut_demoAppDelegate.h"

#import "nut_demoApplication.h"

// Disable quasi-simultaneous taps
HLSEnableUIControlInjection();

@interface nut_demoAppDelegate ()

@property (nonatomic, retain) nut_demoApplication *application;

@end

@implementation nut_demoAppDelegate

#pragma mark Object construction and destruction

- (void)dealloc
{
    self.application = nil;
    self.window = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize application = m_application;

@synthesize window = m_window;

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [self.window makeKeyAndVisible];
    
    self.application = [[[nut_demoApplication alloc] init] autorelease];
    UIViewController *rootViewController = [self.application viewController];
    [self.window addSubview:rootViewController.view];
    
    return YES;
}

@end
