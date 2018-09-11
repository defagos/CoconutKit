//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CoconutKit_demoApplication.h"

#import "DemosListViewController.h"
#import "RootNavigationDemoViewController.h"
#import "RootSplitViewDemoController.h"
#import "RootStackDemoViewController.h"
#import "RootTabBarDemoViewController.h"

@interface CoconutKit_demoApplication ()

@property (nonatomic) UIViewController *rootViewController;

@end

@implementation CoconutKit_demoApplication

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(currentLocalizationDidChange:) 
                                                     name:HLSCurrentLocalizationDidChangeNotification 
                                                   object:nil];
        
        // Create the default model entry point and context
        HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"CoconutKitDemoData"
                                                                               inBundle:nil
                                                                          configuration:nil 
                                                                         storeDirectory:HLSApplicationDocumentDirectoryPath()
                                                                            fileManager:nil
                                                                                options:HLSModelManagerLightweightMigrationOptions];
        [HLSModelManager pushModelManager:modelManager];
        
        // Special modes can be set by setting the CoconutKitDemoMode environment variable:
        //    - "Normal" (or not set): Full set of demos
        //    - "RootStack": Test a stack controller as root view controller of the application
        NSString *demoMode = [NSProcessInfo processInfo].environment[@"CoconutKitDemoMode"];
        if ([demoMode isEqualToString:@"RootStack"]) {
            // Pre-load the stack with two view controllers (by enabling logging, one can discover that view events are correctly
            // forwarded to the view controller on top only)
            RootStackDemoViewController *rootStackDemoViewController1 = [[RootStackDemoViewController alloc] init];
            HLSStackController *stackController = [[HLSStackController alloc] initWithRootViewController:rootStackDemoViewController1];
            stackController.delegate = self;
            RootStackDemoViewController *rootStackDemoViewController2 = [[RootStackDemoViewController alloc] init];
            [stackController pushViewController:rootStackDemoViewController2 withTransitionClass:[HLSTransitionCoverFromBottom class] animated:NO];
            self.rootViewController = stackController;
        }
        else if ([demoMode isEqualToString:@"RootNavigation"]) {
            RootNavigationDemoViewController *rootNavigationDemoViewController = [[RootNavigationDemoViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootNavigationDemoViewController];
            navigationController.delegate = self;
            self.rootViewController = navigationController;
        }
        else if ([demoMode isEqualToString:@"RootSplitView"]) {
            RootSplitViewDemoController *leftRootSplitViewController = [[RootSplitViewDemoController alloc] init];
            RootSplitViewDemoController *rightRootSplitViewController = [[RootSplitViewDemoController alloc] init];
            UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
            splitViewController.viewControllers = @[leftRootSplitViewController, rightRootSplitViewController];
            self.rootViewController = splitViewController;
        }
        else if ([demoMode isEqualToString:@"RootTabBar"]) {
            RootTabBarDemoViewController *rootTabBarDemoViewController1 = [[RootTabBarDemoViewController alloc] init];
            RootTabBarDemoViewController *rootTabBarDemoViewController2 = [[RootTabBarDemoViewController alloc] init];
            RootTabBarDemoViewController *rootTabBarDemoViewController3 = [[RootTabBarDemoViewController alloc] init];
            UITabBarController *tabBarController = [[UITabBarController alloc] init];
            tabBarController.viewControllers = @[rootTabBarDemoViewController1, rootTabBarDemoViewController2, rootTabBarDemoViewController3];
            tabBarController.delegate = self;
            self.rootViewController = tabBarController;
        }
        else if ([demoMode isEqualToString:@"RootStoryboard"]) {
            UIStoryboard *segueStoryboard = [UIStoryboard storyboardWithName:@"SegueDemo" bundle:nil];
            self.rootViewController = [segueStoryboard instantiateInitialViewController];
        }
        else {
            DemosListViewController *demosListViewController = [[DemosListViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:demosListViewController];
            navigationController.autorotationMode = HLSAutorotationModeContainerAndTopChildren;
            self.rootViewController = navigationController;
            
            UIBarButtonItem *languageBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Language", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self 
                                                                                      action:@selector(toggleLanguageSheet:)];
            UIBarButtonItem *logsButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log", nil)
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(showSettings:)];
            UIBarButtonItem *debugOverlayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bindings", nil)
                                                                                          style:UIBarButtonItemStylePlain
                                                                                         target:self
                                                                                         action:@selector(showBindingDebugOverlay:)];
            demosListViewController.navigationItem.rightBarButtonItems = @[languageBarButtonItem, logsButtonItem, debugOverlayBarButtonItem];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HLSCurrentLocalizationDidChangeNotification object:nil];
}

#pragma mark Dynamic Localization

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    // Normal demo mode
    if ([self.rootViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = self.rootViewController;
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

#pragma mark UINavigationControllerDelegate protocol implementation

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    HLSLoggerInfo(@"Will show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    HLSLoggerInfo(@"Did show view controller %@, animated = %@", viewController, HLSStringFromBool(animated));
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
    if (managedObjectContext.hasChanges) {
        HLSLoggerInfo(@"Saving pending changes on exit");
        NSError *error = nil;
        if (! [managedObjectContext save:&error]) {
            HLSLoggerError(@"Failed to save pending changes. Reason: %@", error.localizedDescription);
        }
    }
}

#pragma mark Actions

- (void)toggleLanguageSheet:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *localization in [NSBundle mainBundle].localizations) {
        [alertController addAction:[UIAlertAction actionWithTitle:HLSLanguageForLocalization(localization) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NSBundle setLocalization:localization];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    alertController.popoverPresentationController.barButtonItem = sender;
    [self.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showSettings:(id)sender
{
    [[HLSLogger sharedLogger] showSettings];
}

- (IBAction)showBindingDebugOverlay:(id)sender
{
    [UIView showBindingsDebugOverlay];
}

@end
