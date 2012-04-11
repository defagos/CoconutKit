//
//  CoconutKit_demoApplication.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CoconutKit_demoApplication.h"

#import "DemosListViewController.h"
#import "RootStackDemoViewController.h"

@interface CoconutKit_demoApplication ()

- (void)toggleLanguageSheet:(id)sender;
- (void)currentLocalizationDidChange:(NSNotification *)notification;

@property (nonatomic, retain) UIViewController *rootViewController;
@property (nonatomic, retain) HLSActionSheet *languageActionSheet;

@end

@implementation CoconutKit_demoApplication

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(currentLocalizationDidChange:) 
                                                     name:HLSCurrentLocalizationDidChangeNotification 
                                                   object:nil];
        
        // Create the default model entry point and context
        HLSModelManager *modelManager = [[[HLSModelManager alloc] initWithModelFileName:@"CoconutKitDemoData" 
                                                                         storeDirectory:HLSApplicationDocumentDirectoryPath()] autorelease];
        [HLSModelManager setDefaultModelManager:modelManager];
        
        // Special modes can be set by setting the CoconutKitDemoMode environment variable:
        //    - "Normal" (or not set): Full set of demos
        //    - "RootStack": Test a stack controller as root view controller of the application
        NSString *demoMode = [[[NSProcessInfo processInfo] environment] objectForKey:@"CoconutKitDemoMode"];
        if ([demoMode isEqualToString:@"RootStack"]) {
            // Pre-load the stack with two view controllers (by enabling logging, one can discover that view events are correctly
            // forwarded to the view controller on top only)
            RootStackDemoViewController *rootStackDemoViewController1 = [[[RootStackDemoViewController alloc] init] autorelease];
            HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController1] autorelease];
            RootStackDemoViewController *rootStackDemoViewController2 = [[[RootStackDemoViewController alloc] init] autorelease];
            [stackController pushViewController:rootStackDemoViewController2];
            self.rootViewController = stackController;
        }
        else {
            DemosListViewController *demosListViewController = [[[DemosListViewController alloc] init] autorelease];
            self.rootViewController = [[[UINavigationController alloc] initWithRootViewController:demosListViewController] autorelease];
            UIBarButtonItem *languageBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Language", @"Language") 
                                                                                       style:UIBarButtonItemStyleBordered 
                                                                                      target:self 
                                                                                      action:@selector(toggleLanguageSheet:)] autorelease];
            demosListViewController.navigationItem.rightBarButtonItem = languageBarButtonItem;
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HLSCurrentLocalizationDidChangeNotification object:nil];
    self.rootViewController = nil;
    self.languageActionSheet = nil;
    [super dealloc];
}

#pragma mark Dynamic Localization

- (void)toggleLanguageSheet:(id)sender
{
    self.languageActionSheet = [[[HLSActionSheet alloc] init] autorelease];
    self.languageActionSheet.delegate = self;
    for (NSString *localization in [[NSBundle mainBundle] localizations]) {
        [self.languageActionSheet addButtonWithTitle:HLSLanguageForLocalization(localization)];
    }
    [self.languageActionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString *localization = [[[NSBundle mainBundle] localizations] objectAtIndex:buttonIndex];
    [NSBundle setLocalization:localization];
}

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    // Normal demo mode
    if ([self.rootViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.rootViewController;
        navigationController.topViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Language", @"Language");
    }
}

#pragma mark Accesors and mutators

@synthesize rootViewController = m_rootViewController;

- (UIViewController *)viewController
{
    return self.rootViewController;
}

@synthesize languageActionSheet = m_languageActionSheet;

#pragma mark Core Data

- (void)savePendingChanges
{
    // Save any pending changes in the default context
    NSManagedObjectContext *managedObjectContext = [HLSModelManager defaultModelContext];
    if ([managedObjectContext hasChanges]) {
        HLSLoggerInfo(@"Saving pending changes on exit");
        NSError *error = nil;
        if (! [managedObjectContext save:&error]) {
            HLSLoggerError(@"Failed to save pending changes. Reason: %@", [error localizedDescription]);
        }
    }
}

@end
