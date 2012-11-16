//
//  HLSContainerContent.m
//  CoconutKit
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"

#import "HLSAssert.h"
#import "HLSAutorotationCompatibility.h"
#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransition.h"
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// Keys for runtime container - view controller / view object association
static void *s_containerContentKey = &s_containerContentKey;

// Original implementation of the methods we swizzle
static id (*s_UIViewController__parentViewController_Imp)(id, SEL) = NULL;
static BOOL (*s_UIViewController__isMovingToParentViewController_Imp)(id, SEL) = NULL;
static BOOL (*s_UIViewController__isMovingFromParentViewController_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static UIViewController *swizzled_UIViewController__parentViewController_Imp(UIViewController *self, SEL _cmd);
static BOOL swizzled_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd);
static BOOL swizzled_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd);

// Added method implementations
static void iOS4_UIViewController__willMoveToParentViewController_Imp(UIViewController *self, SEL _cmd, UIViewController *viewController);
static void iOS4_UIViewController__didMoveToParentViewController_Imp(UIViewController *self, SEL _cmd, UIViewController *viewController);
static BOOL iOS4_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd);
static BOOL iOS4_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd);

@interface HLSContainerContent ()

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign) UIViewController *containerViewController;        // weak ref

@property (nonatomic, assign) Class transitionClass;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) HLSContainerStackView *containerStackView;        // weak ref
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) UIViewAutoresizing originalAutoresizingMask;
@property (nonatomic, assign) BOOL movingToParentViewController;
@property (nonatomic, assign) BOOL movingFromParentViewController;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

/**
 * Declarations to suppress warnings when compiling against the iOS SDK 5. Remove when CoconutKit support requires
 * at least SDK 6
 */
@interface UIViewController (HLSContainerContentSDK5Compatibility)

- (BOOL)shouldAutomaticallyForwardAppearanceMethods;
- (BOOL)shouldAutomaticallyForwardRotationMethods;

@end

#endif

@interface UIViewController (HLSContainerContent) <HLSAutorotationCompatibility>

// Empty category. Just swizzling some UIViewController methods for HLSContainerContent

@end

@implementation HLSContainerContent

#pragma mark Class methods

+ (UIViewController *)containerViewControllerKindOfClass:(Class)containerViewControllerClass forViewController:(UIViewController *)viewController
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(viewController, s_containerContentKey);
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

- (id)initWithViewController:(UIViewController *)viewController
     containerViewController:(UIViewController *)containerViewController
             transitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
{
    if ((self = [super init])) {
        if (! viewController) {
            HLSLoggerError(@"A view controller is mandatory");
            [self release];
            return nil;
        }
        
        if (! containerViewController) {
            HLSLoggerError(@"A container view controller must be provided");
            [self release];
            return nil;
        }
        
        if (! [transitionClass isSubclassOfClass:[HLSTransition class]]) {
            HLSLoggerWarn(@"Transitions must be subclasses of HLSTransition. No transition animation will be made");
            transitionClass = [HLSTransition class];
        }
        
        // Cannot be mixed with iOS 5 & 6 containment API (but fully iOS 5 & 6 compatible)
        if (([containerViewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)]
                    && [containerViewController automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers])
                || ([containerViewController respondsToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)]
                    && [containerViewController shouldAutomaticallyForwardAppearanceMethods])
                || ([containerViewController respondsToSelector:@selector(shouldAutomaticallyForwardRotationMethods)]
                    && [containerViewController shouldAutomaticallyForwardRotationMethods])) {
            HLSLoggerError(@"HLSContainerContent can only be used to implement containers for which view lifecycle and rotation event automatic "
                           "forwarding has been explicitly disabled (iOS 5 and 6)");
            [self release];
            return nil;
        }
        
        // Even when pre-loading view controllers into a container which has not been displayed yet, the -interfaceOrientation property
        // returns a correct value. To be able to insert a view controller into a container view controller, their supported interface
        // orientations must be compatible (if the current container orientation is not supported, we will rotate the child view
        // controller appropriately)
        if (! [viewController isOrientationCompatibleWithViewController:containerViewController]) {
            HLSLoggerError(@"The view controller has no compatible orientation with the container");
            return NO;
        }
        
        // Associate the view controller with its container content object        
        if (objc_getAssociatedObject(viewController, s_containerContentKey)) {
            HLSLoggerError(@"A view controller can only be associated with one container");
            [self release];
            return nil;
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
        //
        // Remark: Cannot test -addChildViewController: existence since it existed as a private method before iOS 5.
        //         Test -removeFromParentViewController existence instead
        if ([containerViewController respondsToSelector:@selector(removeFromParentViewController)]) {
            [containerViewController addChildViewController:viewController];
        }
                
        self.viewController = viewController;
        self.containerViewController = containerViewController;
        self.transitionClass = transitionClass;
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
    // Remove the view from the stack (this does NOT set viewController.view to nil to avoid view caching)
    [self removeViewFromContainerStackView];
        
    // Remove the association of the view controller with its content container object
    NSAssert(objc_getAssociatedObject(self.viewController, s_containerContentKey), @"The view controller was not associated with a content container");
    objc_setAssociatedObject(self.viewController, s_containerContentKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    // We must call -willMoveToParentViewController: manually right before the containment relationship is removed without
    // animation, if one remains of course (iOS 5 and above, see UIViewController documentation)
    // This method is always available, even on iOS 4 through method injection (see HLSContainerContent.m)
    [self.viewController willMoveToParentViewController:nil];
    
    // iOS 5 only: See comment in initWithViewController:containerViewController:transitionStyle:duration:. We need to -callRemoveFromParentViewController:
    //             so that the view controller reference count is correctly decreased
    if ([self.viewController respondsToSelector:@selector(removeFromParentViewController)]) {
        [self.viewController removeFromParentViewController];
    }
    
    self.viewController = nil;
    self.containerViewController = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize containerViewController = m_containerViewController;

@synthesize transitionClass = m_transitionClass;

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.) && ! doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        HLSLoggerWarn(@"Duration must be non-negative or the default duration %.2f. Fixed to the default duration", kAnimationTransitionDefaultDuration);
        m_duration = kAnimationTransitionDefaultDuration;
    }
    else {
        m_duration = duration;
    }
}

@synthesize containerStackView = m_containerStackView;

- (BOOL)isAddedToContainerView
{
    return self.containerStackView != nil;
}

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalAutoresizingMask = m_originalAutoresizingMask;

@synthesize movingToParentViewController = m_movingToParentViewController;

@synthesize movingFromParentViewController = m_movingFromParentViewController;

- (UIView *)viewIfLoaded
{
    return [self.viewController viewIfLoaded];
}

#pragma mark View management

- (void)addAsSubviewIntoContainerStackView:(HLSContainerStackView *)stackView
{
    [self insertAsSubviewIntoContainerStackView:stackView atIndex:[stackView.contentViews count]];
}

- (void)insertAsSubviewIntoContainerStackView:(HLSContainerStackView *)stackView atIndex:(NSUInteger)index
{
    if (index > [stackView.contentViews count]) {
        HLSLoggerError(@"Invalid index %d. Expected in [0;%d]", index, [stackView.contentViews count]);
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
        viewControllerView.frame = stackView.bounds;
    }
    
    // Ugly fix for UITabBarController only: After a memory warning has caused the tab bar controller to unload its current
    // view controller's view (if any), this view is neither reloaded nor added as subview of the tab bar controller's view 
    // again. The tab bar controller ends up empty.
    //
    // This happens only if the iOS 5 -[UIViewController addChildViewController:] method has been called to declare the tab
    // bar controller as child of a custom container implemented using HLSContainerContent. But since this containment
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
    viewControllerView.frame = stackView.bounds;
        
    [stackView insertContentView:viewControllerView atIndex:index];
    
    self.containerStackView = stackView;
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

- (void)releaseViews
{
    [self removeViewFromContainerStackView];
    [self.viewController unloadViews];
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
    if ([self.viewController respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.viewController shouldAutorotate];
    }
    else {
        return [self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]
            || [self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]
            || [self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]
            || [self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self.viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.viewController supportedInterfaceOrientations];
    }
    else {
        UIInterfaceOrientationMask orientations = 0;
        if ([self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            orientations |= UIInterfaceOrientationMaskPortrait;
        }
        if ([self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            orientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }
        if ([self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            orientations |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if ([self.viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            orientations |= UIInterfaceOrientationMaskLandscapeRight;
        }
        return orientations;
    }
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
    // iOS 4: Private -addChildViewController: and -removeChildViewController: methods exist to define parent-child containment relationships, but
    //        of course these cannot be used. This is sad since they make the public -parentViewController return the parent container of a view
    //        controller (if any), providing correct propagation for several view controller properties (e.g. embedding in a navigation controller,
    //        correct value for interfaceOrientation, correct container containment chain, etc.).
    //
    //        Note that the -addChildViewController: method has been made public in iOS 5, but that the -removeChildViewController: method has been
    //        replaced with the new -removeFromParentViewController. To test whether we are running iOS 4, we therefore must test whether
    //        -removeFromParentViewController exists
    
    // iOS 4: Swizzle parentViewController to return the custom container into which a view controller has been inserted (if any), and inject
    //        implementations for isMovingTo/FromParentViewController and willMoveTo/FromParentViewController
    if (! class_getInstanceMethod(self, @selector(removeFromParentViewController))) {
        s_UIViewController__parentViewController_Imp = (id (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                           @selector(parentViewController),
                                                                                           (IMP)swizzled_UIViewController__parentViewController_Imp);
        class_addMethod(self,
                        @selector(willMoveToParentViewController:),
                        (IMP)iOS4_UIViewController__willMoveToParentViewController_Imp,
                        "v@:@");
        class_addMethod(self,
                        @selector(didMoveToParentViewController:),
                        (IMP)iOS4_UIViewController__didMoveToParentViewController_Imp,
                        "v@:@");
        class_addMethod(self,
                        @selector(isMovingToParentViewController),
                        (IMP)iOS4_UIViewController__isMovingToParentViewController_Imp,
                        "c@:");
        class_addMethod(self,
                        @selector(isMovingFromParentViewController),
                        (IMP)iOS4_UIViewController__isMovingFromParentViewController_Imp,
                        "c@:");
    }
    // iOS 5: Swizzle the new methods introduced by the containment API so that view controllers can get a correct information even
    //        when inserted into a custom container
    else {
        s_UIViewController__isMovingToParentViewController_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                                       @selector(isMovingToParentViewController),
                                                                                                       (IMP)swizzled_UIViewController__isMovingToParentViewController_Imp);
        s_UIViewController__isMovingFromParentViewController_Imp = (BOOL (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                                         @selector(isMovingFromParentViewController),
                                                                                                         (IMP)swizzled_UIViewController__isMovingFromParentViewController_Imp);
    }
}

@end

static UIViewController *swizzled_UIViewController__parentViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.containerViewController;
    }
    else {
        return (*s_UIViewController__parentViewController_Imp)(self, _cmd);
    }
}

static BOOL swizzled_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.movingToParentViewController;
    }
    else {
        return (*s_UIViewController__isMovingToParentViewController_Imp)(self, _cmd);
    }
}

static BOOL swizzled_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent) {
        return containerContent.movingFromParentViewController;
    }
    else {
        return (*s_UIViewController__isMovingFromParentViewController_Imp)(self, _cmd);
    }
}

static void iOS4_UIViewController__willMoveToParentViewController_Imp(UIViewController *self, SEL _cmd, UIViewController *viewController)
{
    // Empty implementation, so that subclasses of UIViewController can call [super willMoveToParentViewController:]
}

static void iOS4_UIViewController__didMoveToParentViewController_Imp(UIViewController *self, SEL _cmd, UIViewController *viewController)
{
    // Empty implementation, so that subclasses of UIViewController can call [super didMoveToParentViewController:]
}

static BOOL iOS4_UIViewController__isMovingToParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    UIViewController *currentViewController = self;
    while (currentViewController) {
        HLSContainerContent *containerContent = objc_getAssociatedObject(currentViewController, s_containerContentKey);
        if (containerContent.movingToParentViewController) {
            return YES;
        }
        currentViewController = currentViewController.parentViewController;
    }
    return NO;
}

static BOOL iOS4_UIViewController__isMovingFromParentViewController_Imp(UIViewController *self, SEL _cmd)
{
    UIViewController *currentViewController = self;
    while (currentViewController) {
        HLSContainerContent *containerContent = objc_getAssociatedObject(currentViewController, s_containerContentKey);
        if (containerContent.movingFromParentViewController) {
            return YES;
        }
        currentViewController = currentViewController.parentViewController;
    }
    return NO;
}
