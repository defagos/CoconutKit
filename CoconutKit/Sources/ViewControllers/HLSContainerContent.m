//
//  HLSContainerContent.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"

#import "HLSAssert.h"
#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// TODO: Instead of a container view controller, we should not assume the container is a view controller, just an id

// Keys for runtime container - view controller / view object association
static void *s_containerContentKey = &s_containerContentKey;

// Original implementation of the methods we swizzle
static id (*s_UIViewController__navigationController_Imp)(id, SEL) = NULL;
static id (*s_UIViewController__navigationItem_Imp)(id, SEL) = NULL;
static id (*s_UIViewController__interfaceOrientation_Imp)(id, SEL) = NULL;

static void (*s_UIViewController__setTitle_Imp)(id, SEL, id) = NULL;
static void (*s_UIViewController__setHidesBottomBarWhenPushed_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__setToolbarItems_Imp)(id, SEL, id) = NULL;
static void (*s_UIViewController__setToolbarItems_animated_Imp)(id, SEL, id, BOOL) = NULL;

// All presentModal... and dismissModal... methods must be swizzled so that the embedding container deals with modal view controllers
// (otherwise we would get a silly buggy behavior when managing modal view controllers from within a view controller itself embedded
// into a container)
static void (*s_UIViewController__presentViewController_animated_completion_Imp)(id, SEL, id, BOOL, void (^)(void)) = NULL;
static void (*s_UIViewController__dismissViewControllerAnimated_completion_Imp)(id, SEL, BOOL, void (^)(void)) = NULL;
static void (*s_UIViewController__presentModalViewController_animated_Imp)(id, SEL, id, BOOL) = NULL;
static void (*s_UIViewController__dismissModalViewControllerAnimated_Imp)(id, SEL, BOOL) = NULL;

// Remark: We cannot swizzle parentViewController to return the container (see .h file to know why). There is also
//         no need to swizzle presentingViewControlller since the present... methods have been swizzled
static id (*s_UIViewController__modalViewController_Imp)(id, SEL) = NULL;
static id (*s_UIViewController__presentedViewController_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static id swizzled_UIViewController__id_accessor_Imp(UIViewController *self, SEL _cmd);
static id swizzled_UIViewController__id_forward_accessor_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__void_mutator_id_Imp(UIViewController *self, SEL _cmd, id value);
static void swizzled_UIViewController__void_mutator_BOOL_Imp(UIViewController *self, SEL _cmd, BOOL value);
static void swizzled_UIViewController__void_mutator_id_BOOL_Imp(UIViewController *self, SEL _cmd, id value1, BOOL value2);

static void swizzled_UIViewController__presentViewController_animated_completion_Imp(UIViewController *self, SEL _cmd, UIViewController *viewControllerToPresent, 
                                                                                     BOOL flag, void (^completion)(void));
static void swizzled_UIViewController__dismissViewControllerAnimated_completion_Imp(UIViewController *self, SEL _cmd, BOOL flag, void (^completion)(void));
static void swizzled_UIViewController__presentModalViewController_animated_Imp(UIViewController *self, SEL _cmd, UIViewController *modalViewController, BOOL animated);
static void swizzled_UIViewController__dismissModalViewControllerAnimated_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static UIViewController *swizzled_UIViewController__modalViewController_Imp(UIViewController *self, SEL _cmd);
static UIViewController *swizzled_UIViewController__presentedViewController_Imp(UIViewController *self, SEL _cmd);

@interface HLSContainerContent ()

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign) UIViewController *containerViewController;        // weak ref

@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedToContainerView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;
@property (nonatomic, assign) UIViewAutoresizing originalAutoresizingMask;

- (void)removeViewFromContainerView;

@end

@interface UIViewController (HLSContainerContent)

// Empty category. Just swizzling some UIViewController methods for HLSContainerContent

@end

@implementation HLSContainerContent

#pragma mark Class methods

+ (UIViewController *)containerViewControllerKindOfClass:(Class)containerViewControllerClass forViewController:(UIViewController *)viewController
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(viewController, s_containerContentKey);
    if ([containerContent.containerViewController isKindOfClass:containerViewControllerClass]) {
        return containerContent.containerViewController;
    }
    else {
        return nil;
    }
}

#pragma mark Object creation and destruction

- (id)initWithViewController:(UIViewController *)viewController
     containerViewController:(UIViewController *)containerViewController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
{
    if ((self = [super init])) {
        if (! viewController) {
            [self release];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"A view controller must be provided"
                                         userInfo:nil];
        }
        if (! containerViewController) {
            [self release];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"A container must be provided"
                                         userInfo:nil];
        }
        
        // Cannot be mixed with new iOS 5 containment API (but fully iOS 5 compatible)
        if ([containerViewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)]
                && [containerViewController automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers]) {
            [self release];
            NSString *reason = @"HLSContainerContent can only be used to implement containers for which automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers "
                "has been implemented and returns NO (i.e. containers which do not forward view lifecycle events automatically through the iOS 5 containment "
                "mechanism)";
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:reason
                                         userInfo:nil];
        }
        
        // Associate the view controller with its container content object        
        if (objc_getAssociatedObject(viewController, s_containerContentKey)) {
            [self release];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"A view controller can only be associated with one container"
                                         userInfo:nil];
        }
        objc_setAssociatedObject(viewController, s_containerContentKey, self, OBJC_ASSOCIATION_ASSIGN);
        
        // >= iOS 5: For containers having automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
        // return NO, we MUST use the UIViewController containment API to declare each view controller we insert
        // into it as child. 
        //
        // If we don't, problems arise when the container is the root view controller of an application or is presented 
        // modally. In such cases, view controller nesting is not detected, which yields to automatic viewWillAppear: 
        // and viewDidAppear: event forwarding to ALL view controllers loaded into the container when the container 
        // appears (i.e. when the application gets displayed or when the modal view appears). This leads to two
        // undesired effects:
        //   - non-top view controllers get viewWillAppear: and viewDidAppear: events
        //   - the top view controller gets each of these events twice (once from UIKit internals, and once
        //     through manual forwarding by the container implementation)
        if ([containerViewController respondsToSelector:@selector(addChildViewController:)]) {
            [containerViewController addChildViewController:viewController];
        }
                
        self.viewController = viewController;
        self.containerViewController = containerViewController;
        self.transitionStyle = transitionStyle;
        self.duration = duration;
        
        self.originalViewFrame = CGRectZero;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    [self removeViewFromContainerView];
    
    // Restore the view controller's original properties. If the view controller was not retained elsewhere, this would
    // not be necessary. But clients might keep additional references to view controllers for caching purposes. The 
    // best we can do is to restore a view controller's properties when it is removed from a container, no matter whether 
    // or not it is later reused
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    self.viewController.view.autoresizingMask = self.originalAutoresizingMask;
    
    // Remove the association of the view controller with its content container object
    NSAssert(objc_getAssociatedObject(self.viewController, s_containerContentKey), @"The view controller was not associated with a content container");
    objc_setAssociatedObject(self.viewController, s_containerContentKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    // iOS 5 only: See comment in initWithViewController:containerViewController:transitionStyle:duration:
    if ([self.viewController respondsToSelector:@selector(removeFromParentViewController)]) {
        [self.viewController removeFromParentViewController];
    }
    
    // We do not release the view container's view here, on purpose, so that the view controller can be cached and its
    // view reused
    self.viewController = nil;
    self.containerViewController = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize containerViewController = m_containerViewController;

@synthesize addedToContainerView = m_addedToContainerView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.) && ! doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        HLSLoggerWarn(@"Duration must be non-negative or the default duration %f. Fixed to the default duration", kAnimationTransitionDefaultDuration);
        m_duration = kAnimationTransitionDefaultDuration;
    }
    else {
        m_duration = duration;
    }
}

@synthesize forwardingProperties = m_forwardingProperties;

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    if (m_forwardingProperties == forwardingProperties) {
        return;
    }
    
    m_forwardingProperties = forwardingProperties;
    
    // Performs initial sync
    if (forwardingProperties) {
        self.containerViewController.title = self.viewController.title;
        self.containerViewController.navigationItem.title = self.viewController.navigationItem.title;
        self.containerViewController.navigationItem.backBarButtonItem = self.viewController.navigationItem.backBarButtonItem;
        self.containerViewController.navigationItem.titleView = self.viewController.navigationItem.titleView;
        self.containerViewController.navigationItem.prompt = self.viewController.navigationItem.prompt;
        self.containerViewController.navigationItem.hidesBackButton = self.viewController.navigationItem.hidesBackButton;
        self.containerViewController.navigationItem.leftBarButtonItem = self.viewController.navigationItem.leftBarButtonItem;
        self.containerViewController.navigationItem.rightBarButtonItem = self.viewController.navigationItem.rightBarButtonItem;
        self.containerViewController.toolbarItems = self.viewController.toolbarItems;
        self.containerViewController.hidesBottomBarWhenPushed = self.viewController.hidesBottomBarWhenPushed;
    }
}

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

@synthesize originalAutoresizingMask = m_originalAutoresizingMask;

- (UIView *)viewIfLoaded
{
    return [self.viewController viewIfLoaded].superview;
}

#pragma mark View management

- (void)addAsSubviewIntoView:(UIView *)view
{
    [self insertAsSubviewIntoView:view atIndex:[view.subviews count]];
}

- (void)insertAsSubviewIntoView:(UIView *)view atIndex:(NSUInteger)index
{
    if (index > [view.subviews count]) {
        NSString *reason = [NSString stringWithFormat:@"Invalid index %d. Expected in [0;%d]", index, [view.subviews count]];
        @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                       reason:reason
                                     userInfo:nil];
    }
    
    if (self.addedToContainerView) {
        HLSLoggerDebug(@"View controller's view already added to a container view");
        return;
    }
    
    // Force a lazy loading of the view controller's view if needed
    UIView *viewControllerView = self.viewController.view;
    
    // Save original view controller's view properties
    self.originalViewFrame = self.viewController.view.frame;
    self.originalViewAlpha = self.viewController.view.alpha;
    self.originalAutoresizingMask = self.viewController.view.autoresizingMask;
        
    // Ugly fix for UINavigationController and UITabBarController: If their view frame is only adjusted after the view has been
    // added to the container view, a 20px displacement may arise at the top if the container is the root view controller of the
    // application (the implementations of UITabBarController and UINavigationController probably mess up with status bar dimensions 
    // internally)
    if ([self.viewController isKindOfClass:[UINavigationController class]] 
            || [self.viewController isKindOfClass:[UITabBarController class]]) {
        viewControllerView.frame = view.bounds;
    }
    
    // Ugly fix for UITabBarController only: After a memory warning has caused the tab bar controller to unload its current
    // view controller's view (if any), this view is neither reloaded nor added as subview of the tab bar controller's view 
    // again. The tab bar controller ends up empty.
    //
    // This happens only if the new iOS 5 -[UIViewController addChildViewController:] method has been called to declare the 
    // tab bar controller as child of a custom container implemented using HLSContainerContent. But since this containment
    // relationship must be declared for correct behavior on iOS 5, we have to find a workaround.
    //
    // Steps to reproduce the issue (with the code below commented out):
    //   - push a view controller wrapped into a tab bar controller into a custom stack-based container (e.g. HLSStackController)
    //   - add another view controller on top
    //   - cover with a modal, and trigger a memory warning
    //   - dismiss the modal, and remove the view controller on top. The tab bar controller does not get properly reloaded
    // 
    // To fix this issue, we force the tab bar controller to reload its child view controller by setting the current view
    // controller again.
    if ([self.viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)self.viewController;
        if (tabBarController.selectedViewController && ! [tabBarController.selectedViewController isViewLoaded]) {
            UIViewController *currentViewController = tabBarController.selectedViewController;
            tabBarController.selectedViewController = nil;
            tabBarController.selectedViewController = currentViewController;
        }
    }
    
    // The background view of view controller's views inserted into a container must fill its bounds completely, no matter
    // what this original frame is. This is required because of how the root view controller is displayed, and leads to
    // issues when a container is set as root view controller for an application starting in landscape mode. Overriding the
    // autoresizing mask is here not a problem, though: We already are adjusting the view controller's view frame (see below),
    // and this overriding should not conflict with how the view controller is displayed:
    //   - if the view controller's view can resize in all directions, nothing is changed by overriding the autoresizing
    //     mask
    //   - if the view cannot resize in all directions and does not support rotation, the view controller which gets displayed
    //     must have been designed accordingly (i.e. its dimensions match the container view). In such cases the autoresizing
    //     mask of the view is irrelevant and can be safely overridden
    viewControllerView.autoresizingMask = HLSViewAutoresizingAll;
    
    // Match the inserted view frame so that it fills the container bounds
    viewControllerView.frame = view.bounds;
    
    // Wrap into a transparent view with alpha = 1.f. This ensures that no animation relies on the initial value of the view
    // controller's view alpha
    UIView *wrapperView = [[[UIView alloc] initWithFrame:view.bounds] autorelease];
    wrapperView.backgroundColor = [UIColor clearColor];
    wrapperView.autoresizingMask = HLSViewAutoresizingAll;
    [wrapperView addSubview:viewControllerView];
    
    // TODO: Just for easier identification in logs. Remove ASAP
    wrapperView.tag = 3;
    
    // Associate wrapper and container content for easier retrieval
    objc_setAssociatedObject(wrapperView, s_containerContentKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    // The index [containerView.subviews count] is valid and equivalent to -addSubview:
    [view insertSubview:wrapperView atIndex:index];
    self.addedToContainerView = YES;
}

- (void)removeViewFromContainerView
{
    if (! self.addedToContainerView) {
        return;
    }
    
    // Remove the view controller's view
    [self.viewController.view.superview removeFromSuperview];
    [self.viewController.view removeFromSuperview];
    self.addedToContainerView = NO;
    
    // Restore view controller original properties
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    self.viewController.view.autoresizingMask = self.originalAutoresizingMask;
}

- (void)releaseViews
{
    [self removeViewFromContainerView];
    
    if ([self.viewController isViewLoaded]) {
        self.viewController.view = nil;
        [self.viewController viewDidUnload];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        return;
    }
    
    [self.viewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        return;
    }
    
    [self.viewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        return;
    }
    
    [self.viewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        return;
    }
    
    [self.viewController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; viewController: %@; containerViewController: %@; addedToContainerView: %@; viewIfLoaded: %@; forwardingProperties: %@>", 
            [self class],
            self,
            self.viewController,
            self.containerViewController,
            HLSStringFromBool(self.addedToContainerView),
            [self viewIfLoaded],
            HLSStringFromBool(self.forwardingProperties)];
}

@end

@implementation UIViewController (HLSContainerContent)

+ (void)load
{
    s_UIViewController__navigationController_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                       @selector(navigationController), 
                                                                                       (IMP)swizzled_UIViewController__id_forward_accessor_Imp);
    s_UIViewController__navigationItem_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                 @selector(navigationItem), 
                                                                                 (IMP)swizzled_UIViewController__id_forward_accessor_Imp);
    s_UIViewController__interfaceOrientation_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                       @selector(interfaceOrientation), 
                                                                                       (IMP)swizzled_UIViewController__id_accessor_Imp);
    
    s_UIViewController__setTitle_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                 @selector(setTitle:), 
                                                                                 (IMP)swizzled_UIViewController__void_mutator_id_Imp);
    s_UIViewController__setHidesBottomBarWhenPushed_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self,
                                                                                                      @selector(setHidesBottomBarWhenPushed:), 
                                                                                                      (IMP)swizzled_UIViewController__void_mutator_BOOL_Imp);
    s_UIViewController__setToolbarItems_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                        @selector(setToolbarItems:), 
                                                                                        (IMP)swizzled_UIViewController__void_mutator_id_Imp);
    s_UIViewController__setToolbarItems_animated_Imp = (void (*)(id, SEL, id, BOOL))HLSSwizzleSelector(self, 
                                                                                                       @selector(setToolbarItems:animated:), 
                                                                                                       (IMP)swizzled_UIViewController__void_mutator_id_BOOL_Imp);
    
    // The two methods with blocks are only available starting with iOS 5. If we are running on a prior iOS version, their swizzling is a no-op
    s_UIViewController__presentViewController_animated_completion_Imp = (void (*)(id, SEL, id, BOOL, void (^)(void)))HLSSwizzleSelector(self,
                                                                                                                                        @selector(presentViewController:animated:completion:), 
                                                                                                                                        (IMP)swizzled_UIViewController__presentViewController_animated_completion_Imp);
    s_UIViewController__dismissViewControllerAnimated_completion_Imp = (void (*)(id, SEL, BOOL, void (^)(void)))HLSSwizzleSelector(self,
                                                                                                                                   @selector(dismissViewControllerAnimated:completion:), 
                                                                                                                                   (IMP)swizzled_UIViewController__dismissViewControllerAnimated_completion_Imp);
    s_UIViewController__presentModalViewController_animated_Imp = (void (*)(id, SEL, id, BOOL))HLSSwizzleSelector(self, 
                                                                                                                  @selector(presentModalViewController:animated:), 
                                                                                                                  (IMP)swizzled_UIViewController__presentModalViewController_animated_Imp);
    s_UIViewController__dismissModalViewControllerAnimated_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, 
                                                                                                             @selector(dismissModalViewControllerAnimated:), 
                                                                                                             (IMP)swizzled_UIViewController__dismissModalViewControllerAnimated_Imp);
    s_UIViewController__modalViewController_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                      @selector(modalViewController), 
                                                                                      (IMP)swizzled_UIViewController__modalViewController_Imp);
    s_UIViewController__presentedViewController_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                          @selector(presentedViewController), 
                                                                                          (IMP)swizzled_UIViewController__presentedViewController_Imp);
}

@end

@implementation UIView (HLSContainerContent)

- (HLSContainerContent *)containerContent
{
    return objc_getAssociatedObject(self, s_containerContentKey);
}

@end

#pragma mark Swizzled method implementations

static id swizzled_UIViewController__id_accessor_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    // We cannot not forward parentViewController (see why in the .h documentation), we must therefore swizzle
    // interfaceOrientation to fix its behavior
    if (_cmd == @selector(interfaceOrientation)) {
        if (containerContent) {
            // Call the same method, but on the container. This handles view controller nesting correctly
            return swizzled_UIViewController__id_accessor_Imp(containerContent.containerViewController, _cmd);
        }
        else {
            return s_UIViewController__interfaceOrientation_Imp(self, _cmd);
        }
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property getter (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }    
}

static id swizzled_UIViewController__id_forward_accessor_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    id (*UIViewControllerMethod)(id, SEL) = NULL;
    if (_cmd == @selector(navigationController)) {
        UIViewControllerMethod = s_UIViewController__navigationController_Imp;
    }
    else if (_cmd == @selector(navigationItem)) {
        UIViewControllerMethod = s_UIViewController__navigationItem_Imp;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property getter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Forwarding only makes sense if the controller itself is a view controller; if not, call original implementation
    if (containerContent.forwardingProperties) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        return swizzled_UIViewController__id_forward_accessor_Imp(containerContent.containerViewController, _cmd);
    }
    else {
        return UIViewControllerMethod(self, _cmd);
    }
}

static void swizzled_UIViewController__void_mutator_id_Imp(UIViewController *self, SEL _cmd, id value)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    void (*UIViewControllerMethod)(id, SEL, id) = NULL;
    if (_cmd == @selector(setTitle:)) {
        UIViewControllerMethod = s_UIViewController__setTitle_Imp;
    }
    else if (_cmd == @selector(setToolbarItems:)) {
        UIViewControllerMethod = s_UIViewController__setToolbarItems_Imp;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property setter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Call the setter on the view controller first
    UIViewControllerMethod(self, _cmd, value);
    
    // Also set the title of the container controller if it is a view controller and forwarding is enabled
    if (containerContent.forwardingProperties) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_id_Imp(containerContent.containerViewController, _cmd, value);
    }
}

static void swizzled_UIViewController__void_mutator_BOOL_Imp(UIViewController *self, SEL _cmd, BOOL value)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    void (*UIViewControllerMethod)(id, SEL, BOOL) = NULL;
    if (_cmd == @selector(setHidesBottomBarWhenPushed:)) {
        UIViewControllerMethod = s_UIViewController__setHidesBottomBarWhenPushed_Imp;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property setter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Call the setter on the view controller first
    UIViewControllerMethod(self, _cmd, value);
    
    // Also set the title of the container controller if it is a view controller and forwarding is enabled
    if (containerContent.forwardingProperties) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_BOOL_Imp(containerContent.containerViewController, _cmd, value);
    }
}

static void swizzled_UIViewController__void_mutator_id_BOOL_Imp(UIViewController *self, SEL _cmd, id value1, BOOL value2)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    void (*UIViewControllerMethod)(id, SEL, id, BOOL) = NULL;
    if (_cmd == @selector(setToolbarItems:animated:)) {
        UIViewControllerMethod = s_UIViewController__setToolbarItems_animated_Imp;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property setter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Call the setter on the view controller first
    UIViewControllerMethod(self, _cmd, value1, value2);
    
    // Also set the title of the container controller if it is a view controller and forwarding is enabled
    if (containerContent.forwardingProperties) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_id_BOOL_Imp(containerContent.containerViewController, _cmd, value1, value2);
    }
}

static void swizzled_UIViewController__presentViewController_animated_completion_Imp(UIViewController *self, SEL _cmd, UIViewController *viewControllerToPresent, 
                                                                                     BOOL flag, void (^completion)(void))
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        [containerContent.containerViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    else {
        (*s_UIViewController__presentViewController_animated_completion_Imp)(self, @selector(presentViewController:animated:completion:), viewControllerToPresent, flag, completion);
    }
}

static void swizzled_UIViewController__dismissViewControllerAnimated_completion_Imp(UIViewController *self, SEL _cmd, BOOL flag, void (^completion)(void))
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        [containerContent.containerViewController dismissViewControllerAnimated:flag completion:completion];
    }
    else {
        (*s_UIViewController__dismissViewControllerAnimated_completion_Imp)(self, @selector(dismissViewControllerAnimated:completion:), flag, completion);
    }
}

static void swizzled_UIViewController__presentModalViewController_animated_Imp(UIViewController *self, SEL _cmd, UIViewController *modalViewController, BOOL animated)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        [containerContent.containerViewController presentModalViewController:modalViewController animated:animated];
    }
    else {
        (*s_UIViewController__presentModalViewController_animated_Imp)(self, @selector(presentModalViewController:animated:), modalViewController, animated);
    }
}

static void swizzled_UIViewController__dismissModalViewControllerAnimated_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        [containerContent.containerViewController dismissModalViewControllerAnimated:animated];
    }
    else {
        (*s_UIViewController__dismissModalViewControllerAnimated_Imp)(self, @selector(dismissModalViewControllerAnimated:), animated);
    }
}

static UIViewController *swizzled_UIViewController__modalViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.containerViewController.modalViewController;
    }
    else {
        return (*s_UIViewController__modalViewController_Imp)(self, @selector(modalViewController));
    }
}

static UIViewController *swizzled_UIViewController__presentedViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.containerViewController.presentedViewController;
    }
    else {
        return (*s_UIViewController__presentedViewController_Imp)(self, @selector(presentedViewController));
    }
}

