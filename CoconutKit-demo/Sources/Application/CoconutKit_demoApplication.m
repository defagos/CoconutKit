//
//  CoconutKit_demoApplication.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CoconutKit_demoApplication.h"

#import "DemosListViewController.h"
#import "RootNavigationDemoViewController.h"
#import "RootSplitViewDemoController.h"
#import "RootStackDemoViewController.h"
#import "RootTabBarDemoViewController.h"

@interface CoconutKit_demoApplication ()

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
                                                                               inBundle:nil
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
        else if ([demoMode isEqualToString:@"RootNavigation"]) {
            RootNavigationDemoViewController *rootNavigationDemoViewController = [[[RootNavigationDemoViewController alloc] init] autorelease];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:rootNavigationDemoViewController] autorelease];
            navigationController.delegate = self;
            self.rootViewController = navigationController;
        }
        else if ([demoMode isEqualToString:@"RootSplitView"]) {
            RootSplitViewDemoController *leftRootSplitViewController = [[[RootSplitViewDemoController alloc] init] autorelease];
            RootSplitViewDemoController *rightRootSplitViewController = [[[RootSplitViewDemoController alloc] init] autorelease];
            UISplitViewController *splitViewController = [[[UISplitViewController alloc] init] autorelease];
            splitViewController.viewControllers = [NSArray arrayWithObjects:leftRootSplitViewController, rightRootSplitViewController, nil];
            splitViewController.delegate = self;
            self.rootViewController = splitViewController;
        }
        else if ([demoMode isEqualToString:@"RootTabBar"]) {
            RootTabBarDemoViewController *rootTabBarDemoViewController1 = [[[RootTabBarDemoViewController alloc] init] autorelease];
            RootTabBarDemoViewController *rootTabBarDemoViewController2 = [[[RootTabBarDemoViewController alloc] init] autorelease];
            RootTabBarDemoViewController *rootTabBarDemoViewController3 = [[[RootTabBarDemoViewController alloc] init] autorelease];
            UITabBarController *tabBarController = [[[UITabBarController alloc] init] autorelease];
            tabBarController.viewControllers = [NSArray arrayWithObjects:rootTabBarDemoViewController1, rootTabBarDemoViewController2,
                                                rootTabBarDemoViewController3, nil];
            tabBarController.delegate = self;
            self.rootViewController = tabBarController;
        }
        else if ([demoMode isEqualToString:@"RootStoryboard"]) {
            // TODO: Cleanup this mess when CoconutKit compatible with iOS >= 5. Remove UIKit weak-linking in CoconutKit-demo
            if ([UIStoryboard class]) {
                // The compiled storyboard has a storyboardc extension
                if ([[NSBundle mainBundle] pathForResource:@"SegueDemo" ofType:@"storyboardc"]) {
                    UIStoryboard *segueStoryboard = [UIStoryboard storyboardWithName:@"SegueDemo" bundle:nil];
                    self.rootViewController = [segueStoryboard instantiateInitialViewController];
                }
                else {
                    HLSLoggerError(@"No storyboard file available in application bundle");
                    [self release];
                    return nil;
                }
            }
            else {
                HLSLoggerError(@"Storyboards are not available on iOS 4");
                [self release];
                return nil;
            }
        }
        else {
            DemosListViewController *demosListViewController = [[[DemosListViewController alloc] init] autorelease];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:demosListViewController] autorelease];
            navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
            self.rootViewController = navigationController;
            UIBarButtonItem *languageBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Language", nil)
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

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    // Normal demo mode
    if ([self.rootViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.rootViewController;
        navigationController.topViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Language", nil);
    }
}

#pragma mark Accesors and mutators

- (UIViewController *)viewController
{
    return self.rootViewController;
}

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

#pragma mark UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString *localization = [[[NSBundle mainBundle] localizations] objectAtIndex:buttonIndex];
    [NSBundle setLocalization:localization];
}

#pragma mark UINavigationControllerDelegate protocol implementation

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

#pragma mark UISplitViewControllerDelegate protocol implementation

- (void)splitViewController:(UISplitViewController *)splitViewController
          popoverController:(UIPopoverController *)popoverController
  willPresentViewController:(UIViewController *)viewController
{
    HLSLoggerInfo(@"Popover controller %@ will present view controller %@", popoverController, viewController);
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
   shouldHideViewController:(UIViewController *)viewController
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)splitViewController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    HLSLoggerInfo(@"Will show view controller %@ invalidating bar button item %@", viewController, barButtonItem);
}

- (void)splitViewController:(UISplitViewController *)splitViewController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    HLSLoggerInfo(@"Will hide view controller %@ with barButtonItem %@ for popoverController %@", viewController, barButtonItem, popoverController);
}

#pragma mark UITabBarControllerDelegate protocol implementation

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    HLSLoggerInfo(@"Did select view controller %@", viewController);
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
