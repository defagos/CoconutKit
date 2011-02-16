//
//  ModalWrapperViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/16/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ModalWrapperViewController.h"

@interface ModalWrapperViewController ()

- (void)syncPropertiesWithViewController:(UIViewController *)viewController;

@end

@implementation ModalWrapperViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.navigationBar = nil;
    self.toolbar = nil;
}

#pragma mark Accessors and mutators

@synthesize navigationBar = m_navigationBar;

@synthesize toolbar = m_toolbar;

// Recommended way to override the parent implementation. Check the HLSPlaceholderViewController documentation
- (void)setInsetViewController:(UIViewController *)insetViewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;
{
    // Check for self-assignment
    if (insetViewController == self.insetViewController) {
        return;
    }
    
    // Stop KVO for old view controller
    if (self.insetViewController) {
        [self.insetViewController removeObserver:self forKeyPath:@"title"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.title"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.backBarButtonItem"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.titleView"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.prompt"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.hidesBackButton"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
        [self.insetViewController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
        [self.insetViewController removeObserver:self forKeyPath:@"toolbarItems"];
    }
        
    // Install new inset and sync UI with it
    [super setInsetViewController:insetViewController withTwoViewAnimationStepDefinitions:twoViewAnimationStepDefinitions];
    [self syncPropertiesWithViewController:insetViewController];
    
    // Start listening to changes of the wrapped view controllers which require a UI refresh
    if (self.insetViewController) {
        [self.insetViewController addObserver:self forKeyPath:@"title" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.title" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.backBarButtonItem" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.titleView" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.prompt" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.hidesBackButton" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:0 context:NULL];
        [self.insetViewController addObserver:self forKeyPath:@"toolbarItems" options:0 context:NULL];
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self syncPropertiesWithViewController:self.insetViewController];
}

#pragma mark KVO notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    UIViewController *viewController = (UIViewController *)object;
    [self syncPropertiesWithViewController:viewController];
}

#pragma mark Syncing the wrapper UI with the wrapped view controller

- (void)syncPropertiesWithViewController:(UIViewController *)viewController
{
    // Sync the title
    self.title = viewController.title;
    
    // Sync the navigation bar
    [self.navigationBar popNavigationItemAnimated:NO];
    [self.navigationBar pushNavigationItem:viewController.navigationItem animated:NO];
    
    // Sync the toolbar
    self.toolbar.hidden = NO;
    self.toolbar.items = viewController.toolbarItems;
}

@end
