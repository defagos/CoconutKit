//
//  HLSStackController.m
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import <objc/runtime.h>
#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

// TODO: Replace separate addedAsSubViewFlag / transitionStyle / originalViewFrame / (+ add originalViewAlpha)
//       by an class ContainedViewControllerDescription. Use it to track  view controller's view properties
//       and to restore them when the view controller is released (this is currently not properly done
//       in HLSStackController). Use the same class to track content view controllers in HLSPlaceholderViewController

static void *HLSStackControllerKey = &HLSStackControllerKey;

@interface HLSStackController ()

@property (nonatomic, retain) NSMutableArray *viewControllerStack;
@property (nonatomic, retain) NSMutableArray *addedAsSubviewFlagStack;
@property (nonatomic, retain) NSMutableArray *blockingViewStack;
@property (nonatomic, retain) NSMutableArray *transitionStyleStack;
@property (nonatomic, retain) NSMutableArray *durationStack;
@property (nonatomic, retain) NSMutableArray *pushAnimationStack;
@property (nonatomic, retain) NSMutableArray *originalViewFrameStack;

- (UIViewController *)secondTopViewController;

- (void)registerViewController:(UIViewController *)viewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration;
- (void)unregisterViewController:(UIViewController *)viewController;
- (HLSAnimation *)createAndCacheAnimationForViewController:(UIViewController *)viewController;

- (void)pushViewForViewController:(UIViewController *)viewController;
- (void)removeViewForViewController:(UIViewController *)viewController;

- (BOOL)addedAsSubviewFlagForViewController:(UIViewController *)viewController;
- (UIView *)blockingViewForViewController:(UIViewController *)viewController;
- (HLSTransitionStyle)transitionStyleForViewController:(UIViewController *)viewController;
- (NSTimeInterval)durationForViewController:(UIViewController *)viewController;
- (CGRect)originalViewFrameForViewController:(UIViewController *)viewController;

- (HLSAnimation *)pushAnimationForViewController:(UIViewController *)viewController;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        self.viewControllerStack = [NSMutableArray array];
        self.addedAsSubviewFlagStack = [NSMutableArray array];
        self.blockingViewStack = [NSMutableArray array];
        self.transitionStyleStack = [NSMutableArray array];
        self.durationStack = [NSMutableArray array];
        self.pushAnimationStack = [NSMutableArray array];
        self.originalViewFrameStack = [NSMutableArray array];
        
        [self registerViewController:rootViewController withTransitionStyle:HLSTransitionStyleNone duration:kAnimationTransitionDefaultDuration];
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
    // Must cleanup view controller registrations properly (cannot call unregisterViewController:, would mutate arrays
    // while iterating)
    for (UIViewController *viewController in self.viewControllerStack) {
        // Remove the view controller association with its container
        NSAssert(objc_getAssociatedObject(viewController, HLSStackControllerKey), @"The view controller was not inserted into a stack controller");
        objc_setAssociatedObject(viewController, HLSStackControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    self.viewControllerStack = nil;
    self.addedAsSubviewFlagStack = nil;
    self.blockingViewStack = nil;
    self.transitionStyleStack = nil;
    self.durationStack = nil;
    self.pushAnimationStack = nil;
    self.originalViewFrameStack = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewControllerStack = m_viewControllerStack;

@synthesize addedAsSubviewFlagStack = m_addedAsSubviewFlagStack;

@synthesize blockingViewStack = m_blockingViewStack;

@synthesize transitionStyleStack = m_transitionStyleStack;

@synthesize durationStack = m_durationStack;

@synthesize pushAnimationStack = m_pushAnimationStack;

@synthesize originalViewFrameStack = m_originalViewFrameStack;

@synthesize stretchingContent = m_stretchingContent;

@synthesize delegate = m_delegate;

- (UIViewController *)rootViewController
{
    return [self.viewControllerStack firstObject];
}

- (UIViewController *)topViewController
{
    return [self.viewControllerStack lastObject];
}

- (UIViewController *)secondTopViewController
{
    if ([self.viewControllerStack count] < 2) {
        return nil;
    }
    return [self.viewControllerStack objectAtIndex:[self.viewControllerStack count] - 2];
}

- (NSArray *)viewControllers
{
    return [NSArray arrayWithArray:self.viewControllerStack];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All animation must take place inside the view controller's view
    self.view.clipsToBounds = YES;
    
    // Take all space available. Parent container view controllers should be responsible of StretchingContentg
    // the view size properly
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add those view controller views which have not been added yet
    for (UIViewController *viewController in self.viewControllerStack) {
        if (! [self addedAsSubviewFlagForViewController:viewController]) {
            [self pushViewForViewController:viewController];
        }        
    }
    
    // Forward events for the top view controller
    UIViewController *topViewController = [self topViewController];
    if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
        [self.delegate stackController:self willShowViewController:topViewController animated:animated];
    }
    
    [topViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    UIViewController *topViewController = [self topViewController];
    if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
        [self.delegate stackController:self didShowViewController:topViewController animated:animated];
    }
    
    [topViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIViewController *topViewController = [self topViewController];
    [topViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    UIViewController *topViewController = [self topViewController];
    [topViewController viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    for (UIViewController *viewController in self.viewControllerStack) {
        if ([self addedAsSubviewFlagForViewController:viewController]) {
            [self removeViewForViewController:viewController];
            viewController.view = nil;
            [viewController viewDidUnload];
        }
    }
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // TODO: Support for HLSOrientationCloner is NOT trivial. Not implemented currently
    
    // If one view controller in the stack does not support the orientation, neither will the container
    for (UIViewController *viewController in self.viewControllerStack) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (UIViewController *viewController in self.viewControllerStack) {
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (UIViewController *viewController in self.viewControllerStack) {
        // Create the animation again: The frames have changed!
        [self createAndCacheAnimationForViewController:viewController];
        
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for (UIViewController *viewController in self.viewControllerStack) {
        [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

#pragma mark Pushing view controllers onto the stack

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController withTransitionStyle:HLSTransitionStyleNone];
}

- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    [self pushViewController:viewController withTransitionStyle:transitionStyle duration:kAnimationTransitionDefaultDuration];
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    NSAssert(viewController != nil, @"Cannot push nil");
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if ([self isViewVisible]) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
            HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
            return;
        }
    }
    
    // Associate the view controller with its container
    [self registerViewController:viewController withTransitionStyle:transitionStyle duration:duration];
    
    if ([self isViewLoaded]) {
        // The view controllers involved in the animation
        UIViewController *topViewController = [self topViewController];
        
        // Install the view
        [self pushViewForViewController:topViewController];        
    }    
}

#pragma mark Popping view controllers

- (void)popViewController
{
    // Cannot pop if only one view controller remains
    if ([self.viewControllerStack count] == 1) {
        HLSLoggerWarn(@"The root view controller cannot be popped");
        return;
    }
    
    // If the view is loaded, the popped view controller will be unregistered at the end of the animation
    UIViewController *topViewController = [self topViewController];
    if ([self isViewLoaded]) {
        // Pop animation = reverse push animation
        HLSAnimation *popAnimation = [[self pushAnimationForViewController:topViewController] reverseAnimation];
        if ([self isViewVisible]) {
            [popAnimation playAnimated:YES];
        }
        else {
            [popAnimation playAnimated:NO];
        }
    }
    // If the view is not loaded, we can unregister the popped view controller on the spot
    else {
        [self unregisterViewController:topViewController];
    }
}

#pragma mark Managing view controllers

- (void)registerViewController:(UIViewController *)viewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration
{
    // Associate the view controller with its container
    NSAssert(! objc_getAssociatedObject(viewController, HLSStackControllerKey), @"A view controller can only be inserted into one stack controller");
    objc_setAssociatedObject(viewController, HLSStackControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    // Add the new view controller
    [self.viewControllerStack addObject:viewController];
    [self.addedAsSubviewFlagStack addObject:[NSNumber numberWithBool:NO]];
    [self.blockingViewStack addObject:[NSNull null]];
    [self.transitionStyleStack addObject:[NSNumber numberWithInt:transitionStyle]];
    [self.durationStack addObject:[NSNumber numberWithDouble:duration]];
    // Put placeholders for objects depending on the view frame, which might not be known at the moment a view controller is registered (most
    // notably when this occurs before the stack controller is actually displayed). Ths information will be filled when the view gets actually
    // displayed
    [self.pushAnimationStack addObject:[NSNull null]];
    [self.originalViewFrameStack addObject:[NSNull null]];
}

- (void)unregisterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"The view controller was not registered with this stack controller");
        return;
    }
    
    // Remove the view controller association with its container
    NSAssert(objc_getAssociatedObject(viewController, HLSStackControllerKey), @"The view controller was not inserted into a stack controller");
    objc_setAssociatedObject(viewController, HLSStackControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self.viewControllerStack removeObjectAtIndex:index];
    [self.addedAsSubviewFlagStack removeObjectAtIndex:index];
    [self.blockingViewStack removeObjectAtIndex:index];
    [self.transitionStyleStack removeObjectAtIndex:index];
    [self.durationStack removeObjectAtIndex:index];
    [self.pushAnimationStack removeObjectAtIndex:index];
    [self.originalViewFrameStack removeObjectAtIndex:index];
}

- (HLSAnimation *)createAndCacheAnimationForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"The view controller was not registered with this stack controller");
        return nil;
    }
    
    // Apply the same effect to all disappearing views; much better (we see all views below the added one as a single one). This is
    // a lot better with push or fade animations
    NSMutableArray *disappearingViews = [NSMutableArray array];
    for (NSUInteger i = 0; i < index; i++) {
        UIViewController *belowViewController = [self.viewControllerStack objectAtIndex:i];
        [disappearingViews addObject:belowViewController.view];
    }
        
    HLSTransitionStyle transitionStyle = [self transitionStyleForViewController:viewController];
    NSTimeInterval duration = [self durationForViewController:viewController];
    HLSAnimation *pushAnimation = [HLSAnimation animationForTransitionStyle:transitionStyle
                                                      withDisappearingViews:[NSArray arrayWithArray:disappearingViews]
                                                             appearingViews:[NSArray arrayWithObject:viewController .view]
                                                                commonFrame:self.view.frame
                                                                   duration:duration];
    pushAnimation.tag = @"push_animation";
    pushAnimation.lockingUI = YES;
    pushAnimation.bringToFront = YES;
    pushAnimation.delegate = self;
    [self.pushAnimationStack replaceObjectAtIndex:index
                                       withObject:pushAnimation];
    
    return pushAnimation;
}

- (void)pushViewForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return;
    }
    
    // This triggers lazy view cration
    [self.view addSubview:viewController.view];
    
    [self.addedAsSubviewFlagStack replaceObjectAtIndex:index
                                            withObject:[NSNumber numberWithBool:YES]];
    
    // Add a transparent stretchable view just below to prevent the user from interacting with view controllers below in the stack
    UIView *blockingView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
    blockingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blockingViewStack replaceObjectAtIndex:index
                                      withObject:blockingView];
    [self.view insertSubview:blockingView belowSubview:viewController.view];
    
    // Now that the view has not been unnecessarily created, update original frame information
    [self.originalViewFrameStack replaceObjectAtIndex:index
                                           withObject:[NSValue valueWithCGRect:viewController.view.frame]];
    
    // Adjust size if enabled
    if (self.stretchingContent) {
        viewController.view.frame = self.view.bounds;
    }
    
    // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
    // expect it to occur animated, even if instantaneously. The root view controller is never pushed
    if (index != 0) {
        HLSAnimation *pushAnimation = [self createAndCacheAnimationForViewController:viewController];
        if ([self isViewVisible]) {
            [pushAnimation playAnimated:YES];
        }
        else {
            [pushAnimation playAnimated:NO];
        }        
    }    
}

- (void)removeViewForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return;
    }
    
    [viewController.view removeFromSuperview];
    [self.addedAsSubviewFlagStack replaceObjectAtIndex:index
                                            withObject:[NSNumber numberWithBool:NO]];
    
    UIView *blockingView = [self blockingViewForViewController:viewController];
    [blockingView removeFromSuperview];
    [self.blockingViewStack replaceObjectAtIndex:index
                                      withObject:[NSNull null]];
    
    [self.originalViewFrameStack replaceObjectAtIndex:index
                                           withObject:[NSNull null]];
    
    // Remove the corresponding push animation (if any)
    [self.pushAnimationStack replaceObjectAtIndex:index
                                       withObject:[NSNull null]];
}

- (BOOL)addedAsSubviewFlagForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return NO;
    }
    
    return [[self.addedAsSubviewFlagStack objectAtIndex:index] boolValue];
}
     
- (UIView *)blockingViewForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return NO;
    }
    
    return [self.blockingViewStack objectAtIndex:index];
}

- (HLSTransitionStyle)transitionStyleForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return HLSTransitionStyleNone;
    }
    
    return (HLSTransitionStyle)[[self.transitionStyleStack objectAtIndex:index] intValue];
}

- (NSTimeInterval)durationForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return HLSTransitionStyleNone;
    }
    
    return [[self.durationStack objectAtIndex:index] doubleValue];
}

- (CGRect)originalViewFrameForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return CGRectZero;
    }
    
    return [[self.originalViewFrameStack objectAtIndex:index] CGRectValue];
}

#pragma mark Animation

- (HLSAnimation *)pushAnimationForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == 0) {
        HLSLoggerError(@"Cannot push the root view controller");
        return nil;
    }
    
    return [self.pushAnimationStack objectAtIndex:index];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{    
    if ([self isViewVisible]) {
        UIViewController *appearingViewController = nil;
        UIViewController *disappearingViewController = nil;
        
        if ([animation.tag isEqual:@"push_animation"]) {
            appearingViewController = [self topViewController];
            disappearingViewController = [self secondTopViewController];
        }
        else if ([animation.tag isEqual:@"reverse_push_animation"]) {
            appearingViewController = [self secondTopViewController];
            disappearingViewController = [self topViewController];
        }
        else {
            HLSLoggerWarn(@"Other animation; nothing to do");
            return;
        }
        
        [disappearingViewController viewWillDisappear:animated];
        [appearingViewController viewWillAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
            [self.delegate stackController:self
                    willShowViewController:appearingViewController 
                                  animated:animated];
        }
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    UIViewController *disappearingViewController = nil;
    
    if ([self isViewVisible]) {
        UIViewController *appearingViewController = nil;
        
        if ([animation.tag isEqual:@"push_animation"]) {
            appearingViewController = [self topViewController];
            disappearingViewController = [self secondTopViewController];
        }
        else if ([animation.tag isEqual:@"reverse_push_animation"]) {
            appearingViewController = [self secondTopViewController];
            disappearingViewController = [self topViewController];
            
            // Remove the popped view controller's view
            [self removeViewForViewController:disappearingViewController];
        }
        else {
            HLSLoggerWarn(@"Other animation; nothing to do");
            return;
        }
        
        [disappearingViewController viewDidDisappear:animated];      
        [appearingViewController viewDidAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
            [self.delegate stackController:self
                     didShowViewController:appearingViewController 
                                  animated:animated];
        }
    }
    
    // At the end of the pop animation, we must always remove the popped view controller from the stack
    if ([animation.tag isEqual:@"reverse_push_animation"]) {
        [self unregisterViewController:disappearingViewController];
    }
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    UIViewController *topViewController = [self topViewController];
    if ([topViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableTopViewController = (UIViewController<HLSReloadable> *)topViewController;
        [reloadableTopViewController reloadData];
    }
}

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    return objc_getAssociatedObject(self, HLSStackControllerKey);
}

@end
