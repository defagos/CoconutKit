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
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"CoconutKitDemoData"
                                                                          configuration:nil 
                                                                         storeDirectory:documentsDirectoryPath 
                                                                                options:HLSModelManagerLightweightMigrationOptions];
        [HLSModelManager pushModelManager:modelManager];
        
        // Special modes can be set by setting the CoconutKitDemoMode environment variable:
        //    - "Normal" (or not set): Full set of demos
        //    - "RootStack": Test a stack controller as root view controller of the application
        NSString *demoMode = [[[NSProcessInfo processInfo] environment] objectForKey:@"CoconutKitDemoMode"];
        if ([demoMode isEqualToString:@"RootStack"]) {
            // Pre-load the stack with two view controllers (by enabling logging, one can discover that view events are correctly
            // forwarded to the view controller on top only)
            RootStackDemoViewController *rootStackDemoViewController1 = [[[RootStackDemoViewController alloc] init] autorelease];
            HLSStackController *stackController = [[[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController1] autorelease];
            stackController.delegate = self;
            RootStackDemoViewController *rootStackDemoViewController2 = [[[RootStackDemoViewController alloc] init] autorelease];
            [stackController pushViewController:rootStackDemoViewController2 withTransitionClass:[HLSTransitionCoverFromBottom class] animated:NO];
            self.rootViewController = stackController;
        }
        else if ([demoMode isEqualToString:@"RootStoryboard"]) {
            // TODO: Cleanup this mess when CoconutKit compatible with iOS >= 5. Remove UIKit weak-linking in CoconutKit-demo
            if ([UIStoryboard class]) {
                @try {
                    UIStoryboard *segueStoryboard = [UIStoryboard storyboardWithName:@"SegueDemo" bundle:nil];
                    self.rootViewController = [segueStoryboard instantiateInitialViewController];
                }
                @catch (NSException *exception) {
                    HLSLoggerError(@"No storyboard file available in application bundle");
                }
            }
            else {
                HLSLoggerError(@"Storyboards are not available on iOS 4");
            }
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

#pragma mark HLSStackControllerDelegate protocol implementation

- (void)stackController:(HLSStackController *)stackController
 willPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will push view controller %@, cover view controller %@, animated = %@", pushedViewController, coveredViewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
 willShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  didShowViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  didPushViewController:(UIViewController *)pushedViewController
    coverViewController:(UIViewController *)coveredViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did push view controller %@, cover view controller %@, animated = %@", pushedViewController, coveredViewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  willPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will pop view controller %@, reveal view controller %@, animated = %@", poppedViewController, revealedViewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
 willHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will hide view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
  didHideViewController:(UIViewController *)viewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did hide view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)stackController:(HLSStackController *)stackController
   didPopViewController:(UIViewController *)poppedViewController
   revealViewController:(UIViewController *)revealedViewController
               animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did pop view controller %@, reveal view controller %@, animated = %@", poppedViewController, revealedViewController, HLSStringFromBool(animated));
}

#pragma mark Core Data

- (void)savePendingChanges
{
    // Save any pending changes in the default context
    NSManagedObjectContext *managedObjectContext = [HLSModelManager currentModelContext];
    if ([managedObjectContext hasChanges]) {
        HLSLoggerInfo(@"Saving pending changes on exit");
        NSError *error = nil;
        if (! [managedObjectContext save:&error]) {
            HLSLoggerError(@"Failed to save pending changes. Reason: %@", [error localizedDescription]);
        }
    }
}

@end
