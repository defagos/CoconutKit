//
//  HLSInsetController.m
//  nut
//
//  Created by Samuel Défago on 9/28/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSInsetController.h"

#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSRuntimeChecks.h"

@interface HLSInsetController ()

@property (nonatomic, retain) UIViewController *placeholderViewController;

- (void)copyPlaceholderViewControllerPropertiesFromViewController:(UIViewController *)viewController;

@end

@implementation HLSInsetController

#pragma mark Object creation and destruction

- (id)initWithPlaceholderViewController:(UIViewController<HLSViewPlaceholder> *)placeholderViewController
{
    if (self = [super init]) {
        self.placeholderViewController = placeholderViewController;
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.placeholderViewController = nil;
    self.insetViewController = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize placeholderViewController = m_placeholderViewController;

- (void)setPlaceholderViewController:(UIViewController *)placeholderViewController
{
    // Check for self-assignment
    if (m_placeholderViewController == placeholderViewController) {
        return;
    }
    
    // Stop KVO for the old placeholder view controller
    if (m_placeholderViewController) {
        [m_placeholderViewController removeObserver:self forKeyPath:@"title"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.title"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.backBarButtonItem"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.titleView"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.prompt"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.hidesBackButton"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.leftBarButtonItem"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"navigationItem.rightBarButtonItem"];
        [m_placeholderViewController removeObserver:self forKeyPath:@"toolbarItems"];
    }
    
    // Update the value
    [m_placeholderViewController release];
    m_placeholderViewController = [placeholderViewController retain];
    
    // Sync properties
    [self copyPlaceholderViewControllerPropertiesFromViewController:m_placeholderViewController];
    
    // Start KVO for the new placeholder view controller
    if (m_placeholderViewController) {
        [m_placeholderViewController addObserver:self forKeyPath:@"title" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.title" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.backBarButtonItem" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.titleView" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.prompt" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.hidesBackButton" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.leftBarButtonItem" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"navigationItem.rightBarButtonItem" options:0 context:NULL];
        [m_placeholderViewController addObserver:self forKeyPath:@"toolbarItems" options:0 context:NULL];
    }
}

@synthesize insetViewController = m_insetViewController;

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    // If the inset view controller is not being changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Remove the old inset
    [m_insetViewController viewWillDisappear:NO];
    [m_insetViewController.view removeFromSuperview];
    [m_insetViewController viewDidDisappear:NO];
    
    // Update the value
    [m_insetViewController release];
    m_insetViewController = [insetViewController retain];
    
    // Get the new inset; this lazily creates the associated view
    UIView *insetView = insetViewController.view;
    
    // Display the new inset (the cast is guaranteed to work because of the initWithPlaceholderViewController: signature)
    [insetViewController viewWillAppear:NO];
    UIViewController<HLSViewPlaceholder> *placeholderViewController = self.placeholderViewController;
    [placeholderViewController.placeholderView addSubview:insetView];
    [insetViewController viewDidAppear:NO];
}

#pragma mark View lifecycle

- (void)loadView
{
    // The placeholder view is the one which gets displayed (this also triggers lazily loading for it)
    self.view = self.placeholderViewController.view;
    
    // Display the wrapped view (if any)
    UIViewController<HLSViewPlaceholder> *placeholderViewController = self.placeholderViewController;
    [placeholderViewController.placeholderView addSubview:self.insetViewController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.placeholderViewController viewWillAppear:animated];
    [self.insetViewController viewWillAppear:animated];
    
    // Now that the dimensions are known (because the view is about to be displayed), adjust the inset
    // frame so that the behavior is correct regardless of the inset autoresizing mask
    UIViewController<HLSViewPlaceholder> *placeholderViewController = self.placeholderViewController;
    self.insetViewController.view.frame = placeholderViewController.placeholderView.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.placeholderViewController viewDidAppear:animated];
    [self.insetViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.insetViewController viewWillDisappear:animated];
    [self.placeholderViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.insetViewController viewDidDisappear:animated];
    [self.placeholderViewController viewDidDisappear:animated];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return ([self.placeholderViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
            || [self.placeholderViewController conformsToProtocol:@protocol(HLSOrientationCloner)])
        && ([self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
            || [self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [self.placeholderViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Forward to the view controllers first
    [self.placeholderViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If the view controller can autorotate, just keep it (it will deal with its own orientation). Note that controllers
    // which can autorotate by generating another view does implement shouldAutorotateToInterfaceOrientation:,
    // but return NO for this orientation
    if ([self.placeholderViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        // Nothing to do
    }
    // If the view controller can rotate by cloning, create and use the clone for the new orientation
    else if ([self.placeholderViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *clonablePlaceholderViewController = self.placeholderViewController;
        UIViewController *clonedPlaceholderViewController = [clonablePlaceholderViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        
        // Special case: If the currently displayed view controller rotates by cloning, we must generate corresponding 
        // view lifecycle notifications that views will change
        // TODO: Can be moved to better locations
        [clonablePlaceholderViewController viewWillDisappear:YES];
        [clonedPlaceholderViewController viewWillAppear:YES];
        
        self.placeholderViewController = clonedPlaceholderViewController;
        
        [clonablePlaceholderViewController viewDidDisappear:YES];
        [clonedPlaceholderViewController viewDidAppear:YES];
    }
    // Should never happen, shouldAutorotateToInterfaceOrientation: returned YES if we arrived in this method
    else {
        logger_error(@"The placeholder view controller cannot be rotated");
    }
    
    // Same as above, but for the inset
    if ([self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        // Nothing to do
    }
    else if ([self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *clonableInsetViewController = self.insetViewController;
        UIViewController *clonedInsetViewController = [clonableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        
        // TODO: Can be moved to better locations
        [clonableInsetViewController viewWillDisappear:YES];
        [clonedInsetViewController viewWillAppear:YES];
        
        self.insetViewController = clonedInsetViewController;
        
        [clonableInsetViewController viewDidDisappear:YES];
        [clonedInsetViewController viewDidAppear:YES];
    }
    else {
        logger_error(@"The inset view controller cannot be rotated");
    }
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.placeholderViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];    
    [self.insetViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.placeholderViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];    
    [self.insetViewController didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];    
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.placeholderViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];
    [self.insetViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:fromInterfaceOrientation duration:duration];    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.placeholderViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.insetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self reloadData];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    if ([self.placeholderViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadablePlaceholderViewController = self.placeholderViewController;
        [reloadablePlaceholderViewController reloadData];
    }
    if ([self.insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = self.insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

#pragma mark Mirroring properties of the wrapped view controller

- (void)copyPlaceholderViewControllerPropertiesFromViewController:(UIViewController *)viewController
{
    // Forward title and navigation interface elements
    self.title = viewController.title;
    
    self.navigationItem.title = viewController.navigationItem.title;
    self.navigationItem.backBarButtonItem = viewController.navigationItem.backBarButtonItem;
    self.navigationItem.titleView = viewController.navigationItem.titleView;
    self.navigationItem.prompt = viewController.navigationItem.prompt;
    self.navigationItem.hidesBackButton = viewController.navigationItem.hidesBackButton;
    self.navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
    
    self.toolbarItems = viewController.toolbarItems;
}

#pragma mark KVO notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // KVO is here used to track changes made to the wrapped placeholder view controller; if a change has been
    // detected, just sync everything
    UIViewController *viewController = object;
    [self copyPlaceholderViewControllerPropertiesFromViewController:viewController];
}

@end
