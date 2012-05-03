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

// Constants
static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.01f;      // cannot use 0.f, otherwise infinite matrix elements

// Keys for runtime container - view controller object association
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
@property (nonatomic, assign) id containerController;           // weak ref
@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedToContainerView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;
@property (nonatomic, assign) UIViewAutoresizing originalAutoresizingMask;

+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                         appearingContainerContent:(HLSContainerContent *)appearingContainerContent;

+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                          appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                      disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)fadeInAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                 disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)fadeInAnimation2WithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                  disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)crossDissolveAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                        disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent;

+ (HLSAnimation *)flipAnimationAroundVectorWithXComponent:(CGFloat)xComponent
                                               yComponent:(CGFloat)yComponent
                                               zComponent:(CGFloat)zComponent
                                appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                            disappearingContainerContents:(NSArray *)disappearingContainerContents;

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView;

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration;

+ (CGRect)fixedFrameForView:(UIView *)view;

@end

@interface UIViewController (HLSContainerContent)

// Empty category. Just swizzling some UIViewController methods for HLSContainerContent

@end

@implementation HLSContainerContent

#pragma mark Class methods

+ (id)containerControllerKindOfClass:(Class)containerControllerClass forViewController:(UIViewController *)viewController;
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(viewController, s_containerContentKey);
    if ([containerContent.containerController isKindOfClass:containerControllerClass]) {
        return containerContent.containerController;
    }
    else {
        return nil;
    }
}

/**
 * When a view controller is added as root view controller, there is a subtlety: When the device is rotated into landscape mode, the
 * root view is applied a rotation matrix transform. When a view controller container is set as root, there is an issue if the contentView
 * happens to be the root view: We cannot just use contentView.frame to calculate animations in landscape mode, otherwise animations
 * will be incorrect (they will correspond to the animations in portrait mode!). This method just fixes this issue, providing the
 * correct frame in all situations
 */
+ (CGRect)fixedFrameForView:(UIView *)view
{
    CGRect frame = CGRectZero;
    // Root view
    if ([view.superview isKindOfClass:[UIWindow class]]) {
        frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
    }
    // All other cases
    else {
        frame = view.frame;
    }
    return frame;
}

+ (HLSAnimation *)rotationAnimationForContainerContentStack:(NSArray *)containerContentStack 
                                              containerView:(UIView *)containerView
                                               withDuration:(NSTimeInterval)duration
{
    CGRect fixedFrame = [self fixedFrameForView:containerView];
    
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    animationStep.duration = duration;
    
    // Apply a fix for each contained view controller (except the bottommost one which has no other view controller
    // below)
    for (NSUInteger index = 1; index < [containerContentStack count]; ++index) {
        HLSContainerContent *containerContent = [containerContentStack objectAtIndex:index];
        
        // Fix all view controller's views below
        NSArray *belowContainerContents = [containerContentStack subarrayWithRange:NSMakeRange(0, index)];
        for (HLSContainerContent *belowContainerContent in belowContainerContents) {
            UIView *belowView = [belowContainerContent view];
            
            // This creates the animations needed to fix the view controller's view positions during rotation. To 
            // understand the applied animation transforms, use transparent view controllers loaded into the stack. Push 
            // one view controller into the stack using one of the transitions, then rotate the device, and pop it. For 
            // each transition style, do it once with push in portrait mode and pop in landscape mode, and once with push 
            // in landscape mode and pop in portrait mode. Try to remove the transforms to understand what happens if no 
            // correction is applied during rotation
            HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
            switch (containerContent.transitionStyle) {
                case HLSTransitionStylePushFromTop: {
                    CGFloat offset = CGRectGetHeight(fixedFrame) - belowView.transform.ty;
                    viewAnimationStep.transform = CATransform3DMakeTranslation(0.f, offset, 0.f);
                    break;
                }
                    
                case HLSTransitionStylePushFromBottom: {
                    CGFloat offset = CGRectGetHeight(fixedFrame) + belowView.transform.ty;
                    viewAnimationStep.transform = CATransform3DMakeTranslation(0.f, -offset, 0.f);
                    break;
                }
                    
                case HLSTransitionStylePushFromLeft: {
                    CGFloat offset = CGRectGetWidth(fixedFrame) - belowView.transform.tx;
                    viewAnimationStep.transform = CATransform3DMakeTranslation(offset, 0.f, 0.f);
                    break;
                }
                    
                case HLSTransitionStylePushFromRight: {
                    CGFloat offset = CGRectGetWidth(fixedFrame) + belowView.transform.tx;
                    viewAnimationStep.transform = CATransform3DMakeTranslation(-offset, 0.f, 0.f);
                    break;
                }
                    
                case HLSTransitionStyleCoverFromBottom2:
                case HLSTransitionStyleCoverFromTop2:
                case HLSTransitionStyleCoverFromLeft2:
                case HLSTransitionStyleCoverFromRight2:
                case HLSTransitionStyleCoverFromTopLeft2:
                case HLSTransitionStyleCoverFromTopRight2:
                case HLSTransitionStyleCoverFromBottomLeft2:
                case HLSTransitionStyleCoverFromBottomRight2:
                case HLSTransitionStyleFadeIn2: {
                    viewAnimationStep.transform = CATransform3DMakeScale(kPushToTheBackScaleFactor * CGRectGetWidth(fixedFrame) / CGRectGetWidth(belowView.frame), 
                                                                         kPushToTheBackScaleFactor * CGRectGetHeight(fixedFrame) / CGRectGetHeight(belowView.frame),
                                                                         1.f);
                    break;
                }
                    
                default: {
                    // Nothing to do
                    break;
                }
            }
            [animationStep addViewAnimationStep:viewAnimationStep forView:[belowContainerContent view]];
        }        
    }
    
    // Return the animation to be played. During rotation, views must be resized to account for frame size changes 
    // (because the container view dimensions in general change when it is rotated. If it is the screen area, e.g.,
    // then the 768px x 1004px portrait screen becomes 1024px x 748px in landscape mode, not simply 1004px x 768px)
    HLSAnimation *animation = [HLSAnimation animationWithAnimationStep:animationStep];
    animation.lockingUI = YES;
    animation.resizeViews = YES;
    return animation;
}

#pragma mark Object creation and destruction

- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
{
    if ((self = [super init])) {
        NSAssert(viewController != nil, @"View controller cannot be nil");
        NSAssert(containerController != nil, @"The container cannot be nil");
        
        // >= iOS 5: For containers having automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
        // return NO, we MUST use the UIViewController containment API to declare each view controller we insert
        // into it as child. 
        //
        // If we don't, problems arise when the container is the root view controller of an application or is presented 
        // modally. In such cases, view controller nesting is not detected, which yields to automatic viewWillAppear: 
        // and viewDidAppear: event forwarding to ALL view controllers loaded into the container when the container 
        // appears (i.e. when the application gets displayed or when the modal view appears). This leads to two
        // undesired effects:
        //   - invisible view controllers get viewWillAppear: and viewDidAppear: events
        //   - the visible view controller gets each of these events twice (once from UIKit internals, and once
        //     through manual forwarding by the container implementation)
        if ([containerController isKindOfClass:[UIViewController class]]) {
            UIViewController *containerViewController = (UIViewController *)containerController;
            NSAssert(! [containerViewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)]
                     || ! [containerViewController automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers], @"HLSContainerContent can "
                     "only be used to implement containers for which automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers has been "
                     "implemented and returns NO (i.e. containers which do not forward view lifecycle events automatically through the iOS 5 containment "
                     "mechanism)");
            if ([containerViewController respondsToSelector:@selector(addChildViewController:)]) {
                [containerViewController addChildViewController:viewController];
            }
        }
        
        // Associate the view controller with its container
        self.containerController = containerController;
        
        // Associate the view controller with its container content object
        NSAssert(! objc_getAssociatedObject(viewController, s_containerContentKey), @"A view controller can only be associated with one container content object");
        objc_setAssociatedObject(viewController, s_containerContentKey, self, OBJC_ASSOCIATION_ASSIGN);
        
        self.viewController = viewController;
        self.transitionStyle = transitionStyle;
        self.duration = duration;
        
        self.originalViewFrame = CGRectZero;
    }
    return self;
}

- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
{
    return [self initWithViewController:viewController 
                    containerController:containerController 
                        transitionStyle:transitionStyle 
                               duration:kAnimationTransitionDefaultDuration];
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    // Restore the view controller's frame. If the view controller was not retained elsewhere, this would not be necessary. 
    // But clients might keep additional references to view controllers for caching purposes. The cleanest we can do is to 
    // restore a view controller's properties when it is removed from a container, no matter whether or not it is later 
    // reused by the client
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    self.viewController.view.autoresizingMask = self.originalAutoresizingMask;
    
    // Remove the association of the view controller with its content container object
    NSAssert(objc_getAssociatedObject(self.viewController, s_containerContentKey), @"The view controller was not associated with a content container");
    objc_setAssociatedObject(self.viewController, s_containerContentKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    // See comment in initWithViewController:containerController:transitionStyle:duration:
    if ([self.viewController respondsToSelector:@selector(removeFromParentViewController)]) {
        [self.viewController removeFromParentViewController];
    }
    
    self.viewController = nil;
    self.containerController = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize containerController = m_containerController;

@synthesize addedToContainerView = m_addedToContainerView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.) && ! doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        HLSLoggerWarn(@"Duration must be non-negative or %f. Fixed to 0", kAnimationTransitionDefaultDuration);
        m_duration = 0.;
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
    
    if (forwardingProperties) {
        if ([self.containerController isKindOfClass:[UIViewController class]]) {
            UIViewController *containerViewController = (UIViewController *)self.containerController;
            containerViewController.title = self.viewController.title;
            containerViewController.navigationItem.title = self.viewController.navigationItem.title;
            containerViewController.navigationItem.backBarButtonItem = self.viewController.navigationItem.backBarButtonItem;
            containerViewController.navigationItem.titleView = self.viewController.navigationItem.titleView;
            containerViewController.navigationItem.prompt = self.viewController.navigationItem.prompt;
            containerViewController.navigationItem.hidesBackButton = self.viewController.navigationItem.hidesBackButton;
            containerViewController.navigationItem.leftBarButtonItem = self.viewController.navigationItem.leftBarButtonItem;
            containerViewController.navigationItem.rightBarButtonItem = self.viewController.navigationItem.rightBarButtonItem;
            containerViewController.toolbarItems = self.viewController.toolbarItems;
            containerViewController.hidesBottomBarWhenPushed = self.viewController.hidesBottomBarWhenPushed;
        }   
    }
}

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

@synthesize originalAutoresizingMask = m_originalAutoresizingMask;

- (UIView *)view
{
    if (! self.addedToContainerView) {
        return nil;
    }
    else {
        return self.viewController.view;
    }
}

#pragma mark View management

- (BOOL)addViewToContainerView:(UIView *)containerView 
       inContainerContentStack:(NSArray *)containerContentStack
{
    if (self.addedToContainerView) {
        HLSLoggerInfo(@"View controller's view already added to a container view");
        return NO;
    }
    
    // Ugly fix for UINavigationController and UITabBarController: If their view frame is only adjusted after the view has been
    // added to the container view, a 20px displacement may arise at the top if the container is the root view controller of the
    // application (the implementations of UITabBarController and UINavigationController probably mess up with status bar dimensions internally)
    if ([self.viewController isKindOfClass:[UINavigationController class]] || [self.viewController isKindOfClass:[UITabBarController class]]) {
        self.viewController.view.frame = containerView.bounds;
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
    
    // If a non-empty stack has been provided, find insertion point
    HLSAssertObjectsInEnumerationAreKindOfClass(containerContentStack, HLSContainerContent);
    if ([containerContentStack count] != 0) {
        NSUInteger index = [containerContentStack indexOfObject:self];
        if (index == NSNotFound) {
            HLSLoggerError(@"Receiver not found in the container content stack");
            return NO;
        }
        
        // Last element? Add to top
        if (index == [containerContentStack count] - 1) {
            [containerView addSubview:self.viewController.view];
        }
        // Otherwise add below first content above for which a view is available (most probably the nearest neighbour above)
        else {
            BOOL added = NO;
            for (NSUInteger i = index + 1; i < [containerContentStack count]; ++i) {
                HLSContainerContent *aboveContainerContent = [containerContentStack objectAtIndex:i];
                if ([aboveContainerContent view]) {
                    NSAssert(self.containerController == aboveContainerContent.containerController,
                             @"Both container contents must be associated with the same container controller");
                    NSAssert([aboveContainerContent view].superview == containerView, 
                             @"Other container contents has not been added to the same container view");
                    
                    [containerView insertSubview:self.viewController.view belowSubview:[aboveContainerContent view]];
                    added = YES;
                    break;
                }                
            }
            
            if (! added) {
                HLSLoggerError(@"Could not insert the view; no view found above in the stack");
                return NO;
            }            
        }
    }
    // If no stack provided, simply add at the top
    else {
        [containerView addSubview:self.viewController.view];
    }
    
    self.addedToContainerView = YES;
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidLoad;
    
    // Save original view controller's view properties
    self.originalViewFrame = self.viewController.view.frame;
    self.originalViewAlpha = self.viewController.view.alpha;
    self.originalAutoresizingMask = self.viewController.view.autoresizingMask;
    
    // The background view of view controller's views inserted into a container must fill its bounds completely, no matter
    // what this original frame is. This is required because of how the root view controller is displayed, and leads to
    // issues when a container is set as root view controller for an application starting in landscape mode. Overriding the
    // autoresizing mask is here not a problem, though: We already are adjusting the view controller's view frame (see below),
    // and this overriding the autoresizing mask should not conflict with how the view controller is displayed:
    //   - if the view controller's view can resize in all directions, nothing is changed by overriding the autoresizing
    //     mask
    //   - if the view cannot resize in all directions and does not support rotation, the view controller which gets displayed 
    //     must have been designed accordingly (i.e. its dimensions match the container view). In such cases the autoresizing
    //     mask of the view is irrelevant and can be safely overridden
    self.viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Match the inserted view frame so that it fills the container bounds
    self.viewController.view.frame = containerView.bounds;
    
    // The transitions of the contents above in the stack might move views below in the stack. To account for this
    // effect, we must replay them so that the view we have inserted is put at the proper location
    if ([containerContentStack count] != 0) {
        NSUInteger index = [containerContentStack indexOfObject:self];
        for (NSUInteger i = index + 1; i < [containerContentStack count]; ++i) {
            HLSContainerContent *aboveContainerContent = [containerContentStack objectAtIndex:i];
            HLSAnimation *animation = [HLSContainerContent animationWithTransitionStyle:aboveContainerContent.transitionStyle 
                                                              appearingContainerContent:nil 
                                                          disappearingContainerContents:[NSArray arrayWithObject:self]
                                                                          containerView:containerView 
                                                                               duration:0.];
            // Override the default here: We do not want already visible views to be brought to the background by the animations
            // resurrecting unloaded view controller's views
            animation.bringToFront = NO;
            [animation playAnimated:NO];
        }
    }    
    return YES;
}

- (void)removeViewFromContainerView
{
    if (! self.addedToContainerView) {
        HLSLoggerInfo(@"View controller's view is not added to a container view");
        return;
    }
    
    // Remove the view controller's view
    [self.viewController.view removeFromSuperview];
    self.addedToContainerView = NO;
    
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseInitialized;
    
    // Restore view controller original properties (this way, if addViewToContainerView:inContainerContentStack:
    // is called again later, it will get the view controller's view in its original state)
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
        
        m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidUnload;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        return;
    }
    
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillAppear;
    [self.viewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        return;
    }
    
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidAppear;
    [self.viewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        return;
    }
    
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewWillDisappear;
    [self.viewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (! [self.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        return;
    }
    
    m_lifeCyclePhase = HLSViewControllerLifeCyclePhaseViewDidDisappear;
    [self.viewController viewDidDisappear:animated];
}

#pragma mark Animation

// The new view covers the views below (which is not moved)
+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                         appearingContainerContent:(HLSContainerContent *)appearingContainerContent
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = CATransform3DMakeTranslation(xOffset, yOffset, 0.f);
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view covers the views below, which get slightly shrinked (Fliboard-style)
+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                          appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                      disappearingContainerContents:(NSArray *)disappearingContainerContents

{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = CATransform3DMakeTranslation(xOffset, yOffset, 0.f);
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.transform = CATransform3DMakeScale(kPushToTheBackScaleFactor, kPushToTheBackScaleFactor, 1.f);
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]];
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The view belows are left as is
+ (HLSAnimation *)fadeInAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                 disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in. The view belows are pushed to the back
+ (HLSAnimation *)fadeInAnimation2WithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                  disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.transform = CATransform3DMakeScale(kPushToTheBackScaleFactor, kPushToTheBackScaleFactor, 1.f);
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]];
    }
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view fades in while the views below fade out
+ (HLSAnimation *)crossDissolveAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
                                        disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.alphaVariation = -disappearingContainerContent.originalViewAlpha;
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]];                 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = appearingContainerContent.originalViewAlpha;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view pushes the other ones
+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                        appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                    disappearingContainerContents:(NSArray *)disappearingContainerContents
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = CATransform3DMakeTranslation(xOffset, yOffset, 0.f);
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.transform = CATransform3DMakeTranslation(-xOffset, -yOffset, 0.f);
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The new view emerges from the center of the screen
+ (HLSAnimation *)emergeFromCenterAnimationWithAppearingContainerContent:(HLSContainerContent *)appearingContainerContent
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    CATransform3D shrinkTransform = CATransform3DMakeScale(kEmergeFromCenterScaleFactor, kEmergeFromCenterScaleFactor, 1.f);
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = shrinkTransform;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.transform = CATransform3DInvert(shrinkTransform);
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

// The two views are flipped around an axis
+ (HLSAnimation *)flipAnimationAroundVectorWithXComponent:(CGFloat)xComponent
                                               yComponent:(CGFloat)yComponent
                                               zComponent:(CGFloat)zComponent
                                appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                            disappearingContainerContents:(NSArray *)disappearingContainerContents

{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    CATransform3D flipTransform = CATransform3DMakeRotation(M_PI, xComponent, yComponent, zComponent);
    CATransform3D halfFlipTransform = CATransform3DMakeRotation(M_PI_2, xComponent, yComponent, zComponent);
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.transform = flipTransform;
    viewAnimationStep11.alphaVariation = -appearingContainerContent.originalViewAlpha;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.transform = CATransform3DInvert(halfFlipTransform);
        viewAnimationStep21.alphaVariation = -disappearingContainerContent.originalViewAlpha * 0.5f;
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
    }
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.transform = CATransform3DInvert(halfFlipTransform);
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
    animationStep2.curve = UIViewAnimationCurveEaseOut;
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = appearingContainerContent.originalViewAlpha * 0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:[appearingContainerContent view]]; 
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep32.alphaVariation = -disappearingContainerContent.originalViewAlpha * 0.5f;
        [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:[disappearingContainerContent view]]; 
    }
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
        HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep41.transform = CATransform3DInvert(halfFlipTransform);
        [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:[disappearingContainerContent view]]; 
    }
    HLSViewAnimationStep *viewAnimationStep42 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep42.transform = CATransform3DInvert(halfFlipTransform);
    viewAnimationStep42.alphaVariation = appearingContainerContent.originalViewAlpha * 0.5f;
    [animationStep4 addViewAnimationStep:viewAnimationStep42 forView:[appearingContainerContent view]]; 
    animationStep4.curve = UIViewAnimationCurveEaseIn;
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(disappearingContainerContents, HLSContainerContent);
    
    CGRect frame = [HLSContainerContent fixedFrameForView:containerView];
    
    HLSAnimation *animation = nil;
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            // Empty animation (not simply nil) so that the animation is played (and the associated
            // callback are called)
            animation = [HLSAnimation animationWithAnimationStep:nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            animation = [self coverAnimationWithInitialXOffset:0.f
                                                       yOffset:CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            animation = [self coverAnimationWithInitialXOffset:0.f
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:0.f
                                     appearingContainerContent:appearingContainerContent];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:0.f
                                     appearingContainerContent:appearingContainerContent];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:-CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            animation = [self coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            animation = [self coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                       yOffset:CGRectGetHeight(frame) 
                                     appearingContainerContent:appearingContainerContent];
            break;
        } 
            
        case HLSTransitionStyleCoverFromBottom2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:CGRectGetHeight(frame) 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop2: {
            animation = [self coverAnimation2WithInitialXOffset:0.f
                                                        yOffset:-CGRectGetHeight(frame) 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:0.f 
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:0.f
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromTopRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:-CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft2: {
            animation = [self coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomRight2: {
            animation = [self coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                        yOffset:CGRectGetHeight(frame)
                                      appearingContainerContent:appearingContainerContent
                                  disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFadeIn: {
            animation = [self fadeInAnimationWithAppearingContainerContent:appearingContainerContent
                                             disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFadeIn2: {
            animation = [self fadeInAnimation2WithAppearingContainerContent:appearingContainerContent
                                              disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            animation = [self crossDissolveAnimationWithAppearingContainerContent:appearingContainerContent 
                                                    disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            animation = [self pushAnimationWithInitialXOffset:0.f
                                                      yOffset:-CGRectGetHeight(frame)
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            animation = [self pushAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            animation = [self pushAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                      yOffset:0.f
                                    appearingContainerContent:appearingContainerContent 
                                disappearingContainerContents:disappearingContainerContents];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            animation = [self emergeFromCenterAnimationWithAppearingContainerContent:appearingContainerContent];
            break;
        }
            
        case HLSTransitionStyleFlipVertical: {
            animation = [self flipAnimationAroundVectorWithXComponent:0.f 
                                                           yComponent:1.f 
                                                           zComponent:0.f 
                                            appearingContainerContent:appearingContainerContent 
                                        disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        case HLSTransitionStyleFlipHorizontal: {
            animation = [self flipAnimationAroundVectorWithXComponent:1.f 
                                                           yComponent:0.f 
                                                           zComponent:0.f 
                                            appearingContainerContent:appearingContainerContent 
                                        disappearingContainerContents:disappearingContainerContents];
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            return nil;
            break;
        }
    }
    
    animation.lockingUI = YES;
    animation.bringToFront = YES;
    return animation;
}

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration
{
    HLSAnimation *animation = [HLSContainerContent animationWithTransitionStyle:transitionStyle 
                                                      appearingContainerContent:appearingContainerContent 
                                                  disappearingContainerContents:disappearingContainerContents 
                                                                  containerView:containerView];    
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
    }
    
    // Calculate the total animation duration
    NSTimeInterval totalDuration = 0.;
    for (HLSAnimationStep *animationStep in animation.animationSteps) {
        totalDuration += animationStep.duration;
    }
    
    // Find out which factor must be applied to each animation step to preserve the animation appearance for the specified duration
    double factor = duration / totalDuration;
    
    // Distribute the total duration evenly among animation steps
    for (HLSAnimationStep *animationStep in animation.animationSteps) {
        animationStep.duration *= factor;
    }
    
    return animation;
}


- (HLSAnimation *)animationWithContainerContentStack:(NSArray *)containerContentStack
                                       containerView:(UIView *)containerView
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(containerContentStack, HLSContainerContent);
    
    // Make the receiver appear. Locate it in the stack
    NSUInteger index = [containerContentStack indexOfObject:self];
    if (index == NSNotFound) {
        HLSLoggerError(@"Container content to animate must be part of the stack");
        return nil;
    }
    
    // Make all container contents below in the stack disappear
    NSArray *belowContainerContents = [containerContentStack subarrayWithRange:NSMakeRange(0, index)];
    
    return [HLSContainerContent animationWithTransitionStyle:self.transitionStyle
                                   appearingContainerContent:self 
                               disappearingContainerContents:belowContainerContents
                                               containerView:containerView 
                                                    duration:self.duration];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; viewController: %@; addedToContainerView: %@; view: %@; forwardingProperties: %@>", 
            [self class],
            self,
            self.viewController,
            HLSStringFromBool(self.addedToContainerView),
            [self view],
            HLSStringFromBool(self.forwardingProperties)];
}

@end

@implementation UIViewController (HLSContainerContent)

+ (void)load
{
    s_UIViewController__navigationController_Imp = (id (*)(id, SEL))hls_class_swizzle_selector(self, 
                                                                                               @selector(navigationController), 
                                                                                               (IMP)swizzled_UIViewController__id_forward_accessor_Imp);
    s_UIViewController__navigationItem_Imp = (id (*)(id, SEL))hls_class_swizzle_selector(self, 
                                                                                         @selector(navigationItem), 
                                                                                         (IMP)swizzled_UIViewController__id_forward_accessor_Imp);
    s_UIViewController__interfaceOrientation_Imp = (id (*)(id, SEL))hls_class_swizzle_selector(self,
                                                                                               @selector(interfaceOrientation), 
                                                                                               (IMP)swizzled_UIViewController__id_accessor_Imp);
    
    s_UIViewController__setTitle_Imp = (void (*)(id, SEL, id))hls_class_swizzle_selector(self, 
                                                                                         @selector(setTitle:), 
                                                                                         (IMP)swizzled_UIViewController__void_mutator_id_Imp);
    s_UIViewController__setHidesBottomBarWhenPushed_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzle_selector(self,
                                                                                                              @selector(setHidesBottomBarWhenPushed:), 
                                                                                                              (IMP)swizzled_UIViewController__void_mutator_BOOL_Imp);
    s_UIViewController__setToolbarItems_Imp = (void (*)(id, SEL, id))hls_class_swizzle_selector(self, 
                                                                                                @selector(setToolbarItems:), 
                                                                                                (IMP)swizzled_UIViewController__void_mutator_id_Imp);
    s_UIViewController__setToolbarItems_animated_Imp = (void (*)(id, SEL, id, BOOL))hls_class_swizzle_selector(self, 
                                                                                                               @selector(setToolbarItems:animated:), 
                                                                                                               (IMP)swizzled_UIViewController__void_mutator_id_BOOL_Imp);
    
    // The two methods with blocks are only available starting with iOS 5. If we are running on a prior iOS version, their swizzling is a no-op
    s_UIViewController__presentViewController_animated_completion_Imp = (void (*)(id, SEL, id, BOOL, void (^)(void)))hls_class_swizzle_selector(self,
                                                                                                                                                @selector(presentViewController:animated:completion:), 
                                                                                                                                                (IMP)swizzled_UIViewController__presentViewController_animated_completion_Imp);
    s_UIViewController__dismissViewControllerAnimated_completion_Imp = (void (*)(id, SEL, BOOL, void (^)(void)))hls_class_swizzle_selector(self,
                                                                                                                                           @selector(dismissViewControllerAnimated:completion:), 
                                                                                                                                           (IMP)swizzled_UIViewController__dismissViewControllerAnimated_completion_Imp);
    s_UIViewController__presentModalViewController_animated_Imp = (void (*)(id, SEL, id, BOOL))hls_class_swizzle_selector(self, 
                                                                                                                          @selector(presentModalViewController:animated:), 
                                                                                                                          (IMP)swizzled_UIViewController__presentModalViewController_animated_Imp);
    s_UIViewController__dismissModalViewControllerAnimated_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzle_selector(self, 
                                                                                                                     @selector(dismissModalViewControllerAnimated:), 
                                                                                                                     (IMP)swizzled_UIViewController__dismissModalViewControllerAnimated_Imp);
    s_UIViewController__modalViewController_Imp = (id (*)(id, SEL))hls_class_swizzle_selector(self, 
                                                                                              @selector(modalViewController), 
                                                                                              (IMP)swizzled_UIViewController__modalViewController_Imp);
    s_UIViewController__presentedViewController_Imp = (id (*)(id, SEL))hls_class_swizzle_selector(self, 
                                                                                                  @selector(presentedViewController), 
                                                                                                  (IMP)swizzled_UIViewController__presentedViewController_Imp);
}

@end

#pragma mark Swizzled method implementations

static id swizzled_UIViewController__id_accessor_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    
    // We cannot not forward parentViewController (see why in the .h documentation), we must therefore swizzle
    // interfaceOrientation to fix its behavior
    if (_cmd == @selector(interfaceOrientation)) {
        if (containerContent
                && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
            // Call the same method, but on the container. This handles view controller nesting correctly
            return swizzled_UIViewController__id_accessor_Imp(containerContent.containerController, _cmd);
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
    if (containerContent
            && containerContent.forwardingProperties 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        return swizzled_UIViewController__id_forward_accessor_Imp(containerContent.containerController, _cmd);
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
    if (containerContent
            && containerContent.forwardingProperties 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_id_Imp(containerContent.containerController, _cmd, value);
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
    if (containerContent
            && containerContent.forwardingProperties 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_BOOL_Imp(containerContent.containerController, _cmd, value);
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
    if (containerContent
            && containerContent.forwardingProperties 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        // Call the same method, but on the container. This handles view controller nesting correctly
        swizzled_UIViewController__void_mutator_id_BOOL_Imp(containerContent.containerController, _cmd, value1, value2);
    }
}

static void swizzled_UIViewController__presentViewController_animated_completion_Imp(UIViewController *self, SEL _cmd, UIViewController *viewControllerToPresent, 
                                                                                     BOOL flag, void (^completion)(void))
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        [containerViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
    else {
        (*s_UIViewController__presentViewController_animated_completion_Imp)(self, @selector(presentViewController:animated:completion:), viewControllerToPresent, flag, completion);
    }
}

static void swizzled_UIViewController__dismissViewControllerAnimated_completion_Imp(UIViewController *self, SEL _cmd, BOOL flag, void (^completion)(void))
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        [containerViewController dismissViewControllerAnimated:flag completion:completion];
    }
    else {
        (*s_UIViewController__dismissViewControllerAnimated_completion_Imp)(self, @selector(dismissViewControllerAnimated:completion:), flag, completion);
    }
}

static void swizzled_UIViewController__presentModalViewController_animated_Imp(UIViewController *self, SEL _cmd, UIViewController *modalViewController, BOOL animated)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        [containerViewController presentModalViewController:modalViewController animated:animated];
    }
    else {
        (*s_UIViewController__presentModalViewController_animated_Imp)(self, @selector(presentModalViewController:animated:), modalViewController, animated);
    }
}

static void swizzled_UIViewController__dismissModalViewControllerAnimated_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        [containerViewController dismissModalViewControllerAnimated:animated];
    }
    else {
        (*s_UIViewController__dismissModalViewControllerAnimated_Imp)(self, @selector(dismissModalViewControllerAnimated:), animated);
    }
}

static UIViewController *swizzled_UIViewController__modalViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        return containerViewController.modalViewController;
    }
    else {
        return (*s_UIViewController__modalViewController_Imp)(self, @selector(modalViewController));
    }
}

static UIViewController *swizzled_UIViewController__presentedViewController_Imp(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, s_containerContentKey);
    if (containerContent
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewController *containerViewController = (UIViewController *)containerContent.containerController;
        return containerViewController.presentedViewController;
    }
    else {
        return (*s_UIViewController__presentedViewController_Imp)(self, @selector(presentedViewController));
    }
}

