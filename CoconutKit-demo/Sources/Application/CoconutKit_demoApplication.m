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

- (void)toggleLanguageSheet:(id)sender;
- (void)currentLocalizationDidChange:(NSNotification *)notification;

@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) HLSActionSheet *languageActionSheet;

@end

@implementation CoconutKit_demoApplication

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        DemosListViewController *demosListViewController = [[[DemosListViewController alloc] init] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:demosListViewController] autorelease];
        UIBarButtonItem *languageBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Language", @"Language") style:UIBarButtonItemStyleBordered target:self action:@selector(toggleLanguageSheet:)] autorelease];
        demosListViewController.navigationItem.rightBarButtonItem = languageBarButtonItem;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocalizationDidChange:) name:HLSCurrentLocalizationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HLSCurrentLocalizationDidChangeNotification object:nil];
    self.navigationController = nil;
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
    self.navigationController.topViewController.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Language", @"Language");
}

#pragma mark Accesors and mutators

@synthesize navigationController = m_navigationController;

- (UIViewController *)viewController
{
    return self.navigationController;
}

@synthesize languageActionSheet = m_languageActionSheet;

@end
