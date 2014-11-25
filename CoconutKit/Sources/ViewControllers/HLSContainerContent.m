//
//  HLSContainerContent.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSContainerContent.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "HLSTransition.h"
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// Keys for runtime container - view controller / view object association
static void *s_containerContentKey = &s_containerContentKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UIViewController__isMovingToParentViewController_Imp)(id, SEL) = NULL;
static BOOL (*s_UIViewController__isMovingFromParentViewController_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzled_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd);
static BOOL swizzled_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd);

@interface HLSContainerContent ()

@property (nonatomic, strong) UIViewController *viewController;                 // The embedded view controller
@property (nonatomic, weak) UIViewController *containerViewController;          // The container it is inserted into
@property (nonatomic, assign) Class transitionClass;                            // The transition animation class used when inserting the view controller
@property (nonatomic, assign) NSTimeInterval duration;                          // The transition animation duration
@property (nonatomic, weak) HLSContainerStackView *containerStackView;          // The container stack view into which the view controller's view is inserted
@property (nonatomic, assign) CGRect originalViewFrame;                         // The view controller's view frame prior to insertion
@property (nonatomic, assign) UIViewAutoresizing originalAutoresizingMask;      // The view controller's view autoresizing mask prior to insertion
@property (nonatomic, assign, getter=isMovingToParentViewController) BOOL movingToParentViewController;
@property (nonatomic, assign, getter=isMovingFromParentViewController) BOOL movingFromParentViewController;

@end

@interface UIViewController (HLSContainerContent)

// Empty category. Just swizzling some UIViewController methods for HLSContainerContent

@end

@implementation HLSContainerContent

#pragma mark Class methods

+ (UIViewController *)containerViewControllerKindOfClass:(Class)containerViewControllerClass
                                       forViewController:(UIViewController *)viewController
{
    HLSContainerContent *containerContent = hls_getAssociatedObject(viewController, s_containerContentKey);
    if (containerViewControllerClass) {
        if ([containerContent.containerViewController isKindOfClass:containerViewControllerClass]) {
            return containerContent.containerViewController;
        }
        else {
            return nil;
        }
    }
    else {
        return containerContent.containerViewController;
    }
}

#pragma mark Object creation and destruction

- (instancetype)initWithViewController:(UIViewController *)viewController
               containerViewController:(UIViewController *)containerViewController
                       transitionClass:(Class)transitionClass
                              duration:(NSTimeInterval)duration
{
    if (self = [super init]) {
        if (! viewController) {
            HLSLoggerError(@"A view controller is mandatory");
            return nil;
        }
        
        if (! containerViewController) {
            HLSLoggerError(@"A container view controller must be provided");
            return nil;
        }
        
        if (! [transitionClass isSubclassOfClass:[HLSTransition class]]) {
            HLSLoggerWarn(@"Transitions must be subclasses of HLSTransition. No transition animation will be made");
            transitionClass = [HLSTransition class];
        }
        
        // Cannot be mixed with the containment API automatic event management
        if (([containerViewController respondsToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)]
             && [containerViewController shouldAutomaticallyForwardAppearanceMethods])
            || ([containerViewController respondsToSelector:@selector(shouldAutomaticallyForwardRotationMethods)]
                && [containerViewController shouldAutomaticallyForwardRotationMethods])) {
            HLSLoggerError(@"HLSContainerContent can only be used to implement containers for which view lifecycle and rotation event automatic "
                           "forwarding has been explicitly disabled");
            return nil;
        }
        
        // Even when pre-loading view controllers into a container which has not been displayed yet, the -interfaceOrientation property
        // returns a correct value. To be able to insert a view controller into a container view controller, their supported interface
        // orientations must be compatible (if the current container orientation is not supported, we will rotate the child view
        // controller appropriately)
        if (! [viewController isOrientationCompatibleWithViewController:containerViewController]) {
            HLSLoggerError(@"The view controller has no compatible orientation with the container");
            return nil;
        }
        
        // Associate the view controller with its container content object        
        if (hls_getAssociatedObject(viewController, s_containerContentKey)) {
            HLSLoggerError(@"A view controller can only be associated with one container");
            return nil;
        }
        hls_setAssociatedObject(viewController, s_containerContentKey, self, HLS_ASSOCIATION_WEAK_NONATOMIC);
        
        // We MUST use the UIViewController containment API to declare each view controller we insert into it as child.
        //
        // If we don't, problems arise when the container is the root view controller of an application or is presented 
        // modally. In such cases, view controller nesting is not detected, which yields to automatic -viewWillAppear:
        // and -viewDidAppear: event forwarding to ALL view controllers loaded into the container when the container
        // appears (i.e. when the application gets displayed or when the modal view appears). This leads to two
        // undesired effects:
        //   - non-top view controllers get -viewWillAppear: and -viewDidAppear: events
        //   - the top view controller gets each of these events twice (once from UIKit internals, and once
        //     through manual forwarding by the container implementation)
        [containerViewController addChildViewController:viewController];
                
        self.viewController = viewController;
        self.containerViewController = containerViewController;
        self.transitionClass = transitionClass;
        self.duration = duration;
        
        self.originalViewFrame = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    // Remove the view from the stack (this does NOT set viewController.view to nil to allow view caching)
    [self removeViewFromContainerStackView];
    
    // We must remove the parent - child relationship, see comment in -initWithViewController:containerViewController:transitionStyle:duration:
    [self.viewController removeFromParentViewController];
}

#pragma mark Accessors and mutators

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (isless(duration, 0.) && duration != kAnimationTransitionDefaultDuration) {
        HLSLoggerWarn(@"Duration must be non-negative or the default duration %.2f. Fixed to the default duration", kAnimationTransitionDefaultDuration);
        _duration = kAnimationTransitionDefaultDuration;
    }
    else {
        _duration = duration;
    }
}

- (BOOL)isAddedToContainerView
{
    return self.containerStackView != nil;
}

- (UIView *)viewIfLoaded
{
    return [self.viewController viewIfLoaded];
}

#pragma mark View management

- (void)addAsSubviewIntoContainerStackView:(HLSContainerStackView *)containerStackView
{
    [self insertAsSubviewIntoContainerStackView:containerStackView atIndex:[containerStackView.contentViews count]];
}

- (void)insertAsSubviewIntoContainerStackView:(HLSContainerStackView *)containerStackView atIndex:(NSUInteger)index
{
    if (index > [containerStackView.contentViews count]) {
        HLSLoggerError(@"Invalid index %lu. Expected in [0;%lu]", (unsigned long)index, (unsigned long)[containerStackView.contentViews count]);
        return;
    }
    
    if (self.addedToContainerView) {
        HLSLoggerDebug(@"View controller's view already added to a container view");
        return;
    }
    
    // This is where lazy loading of the view controller's view occurs if needed
    UIView *viewControllerView = self.viewController.view;
    
    // Save original view controller's view properties
    self.originalViewFrame = viewControllerView.frame;
    self.originalAutoresizingMask = viewControllerView.autoresizingMask;
        
    // Ugly fix for UINavigationController and UITabBarController: If their view frame is only adjusted after the view has been
    // added to the container view, a 20px displacement may arise at the top if the container is the root view controller of the
    // application (the implementations of UITabBarController and UINavigationController probably mess up with status bar dimensions 
    // internally)
    if ([self.viewController isKindOfClass:[UINavigationController class]] 
            || [self.viewController isKindOfClass:[UITabBarController class]]) {
        viewControllerView.frame = containerStackView.bounds;
    }
    
    // Ugly fix for UITabBarController only: After a memory warning has caused the tab bar controller to unload its current
    // view controller's view (if any), this view is neither reloaded nor added as subview of the tab bar controller's view 
    // again. The tab bar controller ends up empty.
    //
    // This happens only if the -[UIViewController addChildViewController:] method has been called to declare the tab
    // bar controller as child of a custom container implemented using HLSContainerContent. But since this containment
    // relationship must be declared for correct behavior with the containment API, we have to find a workaround.
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
    viewControllerView.frame = containerStackView.bounds;
        
    [containerStackView insertContentView:viewControllerView atIndex:index];
    
    self.containerStackView = containerStackView;
}

- (void)removeViewFromContainerStackView
{
    if (! self.addedToContainerView) {
        return;
    }
    
    // Remove the view controller's view
    [self.containerStackView removeContentView:[self viewIfLoaded]];
    self.containerStackView = nil;
    
    // Restore view controller original properties
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.autoresizingMask = self.originalAutoresizingMask;
    
    // We do NOT set self.viewController.view = nil here, on purpose: This allows a view controller's view to be cached
    // somewhere else if needed for performance reasons
}

- (void)viewWillAppear:(BOOL)animated movingToParentViewController:(BOOL)movingToParentViewController
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        return;
    }
    
    self.movingToParentViewController = movingToParentViewController;
    [self.viewController viewWillAppear:animated];
    self.movingToParentViewController = NO;
}

- (void)viewDidAppear:(BOOL)animated movingToParentViewController:(BOOL)movingToParentViewController
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        return;
    }
    
    self.movingToParentViewController = movingToParentViewController;
    [self.viewController viewDidAppear:animated];
    self.movingToParentViewController = NO;
}

- (void)viewWillDisappear:(BOOL)animated movingFromParentViewController:(BOOL)movingFromParentViewController
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        return;
    }
    
    self.movingFromParentViewController = movingFromParentViewController;
    [self.viewController viewWillDisappear:animated];
    self.movingFromParentViewController = NO;
}

- (void)viewDidDisappear:(BOOL)animated movingFromParentViewController:(BOOL)movingFromParentViewController
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        return;
    }
    
    self.movingFromParentViewController = movingFromParentViewController;
    [self.viewController viewDidDisappear:animated];
    self.movingFromParentViewController = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.viewController autorotatesToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [self.viewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.viewController supportedInterfaceOrientations];
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
    return [NSString stringWithFormat:@"<%@: %p; viewController: %@; containerViewController: %@; containerStackView:%@; "
            "addedToContainerView: %@; viewIfLoaded: %@>",
            [self class],
            self,
            self.viewController,
            self.containerViewController,
            self.containerStackView,
            HLSStringFromBool(self.addedToContainerView),
            [self viewIfLoaded]];
}

@end

@implementation UIViewController (HLSContainerContent)

+ (void)load
{
    // Swizzle the methods introduced by the containment API so that view controllers can get a correct information even when inserted into a custom container
    s_UIViewController__isMovingToParentViewController_Imp = (BOOL (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                                          @selector(isMovingToParentViewController),
                                                                                                          (IMP)swizzled_UIViewController__isMovingToParentViewController_Imp);
    s_UIViewController__isMovingFromParentViewController_Imp = (BOOL (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                                            @selector(isMovingFromParentViewController),
                                                                                                            (IMP)swizzled_UIViewController__isMovingFromParentViewController_Imp);
}

@end

static BOOL swizzled_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = hls_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.movingToParentViewController;
    }
    else {
        return (*s_UIViewController__isMovingToParentViewController_Imp)(self, _cmd);
    }
}

static BOOL swizzled_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = hls_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.movingFromParentViewController;
    }
    else {
        return (*s_UIViewController__isMovingFromParentViewController_Imp)(self, _cmd);
    }
}
