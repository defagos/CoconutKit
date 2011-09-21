//
//  CoconutKit_demoAppDelegate.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CoconutKit_demoAppDelegate.h"

#import "CoconutKit_demoApplication.h"

// Disable quasi-simultaneous taps
HLSEnableUIControlExclusiveTouch();

@interface CoconutKit_demoAppDelegate ()

@property (nonatomic, retain) CoconutKit_demoApplication *application;

@end

@implementation CoconutKit_demoAppDelegate

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
    
    self.application = [[[CoconutKit_demoApplication alloc] init] autorelease];
    UIViewController *rootViewController = [self.application rootViewController];
    [self.window addSubview:rootViewController.view];
    
    return YES;
}

@end
