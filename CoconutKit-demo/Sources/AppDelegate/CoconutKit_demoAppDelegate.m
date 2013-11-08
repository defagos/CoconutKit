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

// Enable Core Data easy validation
HLSEnableNSManagedObjectValidation();

@interface CoconutKit_demoAppDelegate ()

@property (nonatomic, retain) CoconutKit_demoApplication *application;

@end

@implementation CoconutKit_demoAppDelegate

#pragma mark Class methods

+ (void)load
{
    // Make the demos look nice on iOS 7. I will try to update the view layout to cope with iOS 7 when it is the
    // minimum version required by CoconutKit
    // See Cédric Luthi's tweet: https://twitter.com/0xced/status/344519492786847744
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UIUseLegacyUI" : @YES}];
}

#pragma mark Object construction and destruction

- (void)dealloc
{
    self.application = nil;
    [super dealloc];
}

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // We do not assign to the optional property, to ensure that CoconutKit does not rely on this property
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor blackColor];
    [window makeKeyAndVisible];
    
    // Use optional preloading provided by CoconutKit
    [application preload];
    
    // Instead of using the UIAppFonts key in the plist to load the Beon font, do it in code
    [UIFont loadFontWithFileName:@"Beon-Regular.otf" inBundle:nil];
    
    self.application = [[[CoconutKit_demoApplication alloc] init] autorelease];
    window.rootViewController = [self.application rootViewController];
    
    return YES;
}

@end
