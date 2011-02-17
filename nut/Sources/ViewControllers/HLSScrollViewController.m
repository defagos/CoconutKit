//
//  HLSScrollViewController.m
//  nut
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSScrollViewController.h"

@interface HLSScrollViewController ()

- (void)adjustContentSize;

- (void)syncPropertiesWithViewController:(UIViewController *)viewController;

@end

@implementation HLSScrollViewController

#pragma mark Accessors and mutators

- (void)setInsetViewController:(UIViewController *)insetViewController 
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
{
    // Check for self-assignment
    if (self.insetViewController == insetViewController) {
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
    
    // Install new inset and fit content area size
    [super setInsetViewController:insetViewController withTwoViewAnimationStepDefinitions:twoViewAnimationStepDefinitions];
    [self adjustContentSize];
    
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

- (void)loadView
{
    // Covers everything
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    self.placeholderView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 
                                                                           0.f, 
                                                                           applicationFrame.size.width, 
                                                                           applicationFrame.size.height)]
                            autorelease];
    self.placeholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Adjust content size if an inset was already attached
    [self adjustContentSize];
    
    // The scroll view is the main view
    self.view = self.placeholderView;
    
    [self syncPropertiesWithViewController:self.insetViewController];
}

#pragma mark Orientation management

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // In particular, adjust the size if a cloned view controller has been installed
    [self adjustContentSize];
}

#pragma mark Content size fitting

- (void)adjustContentSize
{
    UIScrollView *scrollView = (UIScrollView *)self.placeholderView;
    if (self.insetViewController) {
        scrollView.contentSize = self.insetViewController.view.bounds.size;
    }
    else {
        scrollView.contentSize = scrollView.bounds.size;
    }
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
    self.navigationItem.title = viewController.navigationItem.title;
    self.navigationItem.backBarButtonItem = viewController.navigationItem.backBarButtonItem;
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.prompt = viewController.navigationItem.prompt;
    self.navigationItem.hidesBackButton = viewController.navigationItem.hidesBackButton;
    self.navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
    
    // Sync the toolbar
    self.toolbarItems = viewController.toolbarItems;
}

@end
