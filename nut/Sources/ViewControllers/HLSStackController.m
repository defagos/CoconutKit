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
#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

static void *HLSStackControllerKey = &HLSStackControllerKey;

@interface HLSStackController ()

@property (nonatomic, retain) NSMutableArray *containerContentStack;
@property (nonatomic, retain) NSMutableArray *pushAnimationStack;

- (UIViewController *)secondTopViewController;

- (HLSContainerContent *)registerViewController:(UIViewController *)viewController
                            withTransitionStyle:(HLSTransitionStyle)transitionStyle
                                       duration:(NSTimeInterval)duration;
- (void)unregisterTopViewController;
- (HLSAnimation *)createAndCacheAnimationForContainerContent:(HLSContainerContent *)containerContent;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        self.containerContentStack = [NSMutableArray array];        
        self.pushAnimationStack = [NSMutableArray array];
        
        [self registerViewController:rootViewController 
                 withTransitionStyle:HLSTransitionStyleNone 
                            duration:kAnimationTransitionDefaultDuration];
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
    // Must cleanup view controller registrations properly (cannot call unregisterTopViewController:, this would mutate
    // the collection while iterating over it)
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        // Remove the view controller association with its container
        UIViewController *viewController = containerContent.viewController;
        NSAssert(objc_getAssociatedObject(viewController, HLSStackControllerKey), @"The view controller was not inserted into a stack controller");
        objc_setAssociatedObject(viewController, HLSStackControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    self.containerContentStack = nil;
    self.pushAnimationStack = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize containerContentStack = m_containerContentStack;

@synthesize pushAnimationStack = m_pushAnimationStack;

@synthesize stretchingContent = m_stretchingContent;

@synthesize delegate = m_delegate;

- (UIViewController *)rootViewController
{
    HLSContainerContent *containerContent = [self.containerContentStack firstObject];
    return containerContent.viewController;
}

- (UIViewController *)topViewController
{
    HLSContainerContent *containerContent = [self.containerContentStack lastObject];
    return containerContent.viewController;
}

- (UIViewController *)secondTopViewController
{
    if ([self.containerContentStack count] < 2) {
        return nil;
    }
    HLSContainerContent *containerContent = [self.containerContentStack objectAtIndex:[self.containerContentStack count] - 2];
    return containerContent.viewController;
}

- (NSArray *)viewControllers
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        [viewControllers addObject:containerContent.viewController];
    }
    return [NSArray arrayWithArray:viewControllers];
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
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        [containerContent addViewToContainerView:self.view
                                         blockInteraction:YES];
        
        // Adjust size if enabled
        if (self.stretchingContent) {
            UIView *view = [containerContent view];
            view.frame = self.view.bounds;
        }
        
        // Push non-animated
        HLSAnimation *pushAnimation = [self createAndCacheAnimationForContainerContent:containerContent];
        [pushAnimation playAnimated:NO];
    }
    
    // Forward events to the top view controller
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
    
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        [containerContent removeViewFromSuperview];
        
        // Release views and forward events to the attached view controllers
        [containerContent releaseView];
        [containerContent.viewController viewDidUnload];
    }    
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // TODO: Support for HLSOrientationCloner is NOT trivial. Not implemented currently, maybe someday...
    
    // If one view controller in the stack does not support the orientation, neither will the container
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        UIViewController *viewController = containerContent.viewController;
        if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }        
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        UIViewController *viewController = containerContent.viewController;
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (HLSContainerContent *containerContent in self.containerContentStack) {        
        // Generate the animation again: The view frames have been changed by the rotation!
        [self createAndCacheAnimationForContainerContent:containerContent];
        
        UIViewController *viewController = containerContent.viewController;
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        UIViewController *viewController = containerContent.viewController;
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
    HLSContainerContent *containerContent = [self registerViewController:viewController 
                                                     withTransitionStyle:transitionStyle
                                                                duration:duration];
    
    if ([self isViewLoaded]) {        
        // Install the view
        [containerContent addViewToContainerView:self.view
                                         blockInteraction:YES];
        
        // Frame reliable only after viewWillAppear
        if ([self lifeCyclePhase] >= HLSViewControllerLifeCyclePhaseViewWillAppear) {
            // Adjust size if enabled
            if (self.stretchingContent) {
                UIView *view = [containerContent view];
                view.frame = self.view.bounds;
            }
        }
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously. The root view controller is never pushed
        HLSAnimation *pushAnimation = [self createAndCacheAnimationForContainerContent:containerContent];
        if ([self isViewVisible]) {
            [pushAnimation playAnimated:YES];
        }
        else {
            [pushAnimation playAnimated:NO];
        }
    }    
}

#pragma mark Popping view controllers

- (void)popViewController
{
    // Cannot pop if only one view controller remains
    if ([self.containerContentStack count] == 1) {
        HLSLoggerWarn(@"The root view controller cannot be popped");
        return;
    }
    
    // If the view is loaded, the popped view controller will be unregistered at the end of the animation
    if ([self isViewLoaded]) {
        // Pop animation = reverse push animation
        HLSAnimation *popAnimation = [[self.pushAnimationStack lastObject] reverseAnimation];
        if ([self isViewVisible]) {
            [popAnimation playAnimated:YES];
        }
        else {
            [popAnimation playAnimated:NO];
        }
    }
    // If the view is not loaded, we can unregister the popped view controller on the spot
    else {
        [self unregisterTopViewController];
    }
}

#pragma mark Managing view controllers

- (HLSContainerContent *)registerViewController:(UIViewController *)viewController
                            withTransitionStyle:(HLSTransitionStyle)transitionStyle
                                       duration:(NSTimeInterval)duration
{
    // Associate the view controller with its container
    NSAssert(! objc_getAssociatedObject(viewController, HLSStackControllerKey), @"A view controller can only be inserted into one stack controller");
    objc_setAssociatedObject(viewController, HLSStackControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:viewController
                                                                                 transitionStyle:transitionStyle
                                                                                        duration:duration]
                                             autorelease];
    [self.containerContentStack addObject:containerContent];
    // Just a placeholder currently. We will create the animation when needed (because the contained view controller's view frame must be
    // known, and registerViewController:withTransitionStyle:duration: might be called before the container is actually displayed
    [self.pushAnimationStack addObject:[NSNull null]];
    
    return containerContent;
}

- (void)unregisterTopViewController
{
    HLSContainerContent *topContainerContent = [self.containerContentStack lastObject];
    UIViewController *topViewController = topContainerContent.viewController;
    
    // Remove the view controller association with its container
    NSAssert(objc_getAssociatedObject(topViewController, HLSStackControllerKey), @"The view controller was not inserted into a stack controller");
    objc_setAssociatedObject(topViewController, HLSStackControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self.containerContentStack removeLastObject];
    [self.pushAnimationStack removeLastObject];
}

- (HLSAnimation *)createAndCacheAnimationForContainerContent:(HLSContainerContent *)containerContent
{
    // Apply the same effect to all disappearing views; much better (we see all views below the added one as a single one). This is
    // a lot better with push or fade animations    
    NSUInteger index = [self.containerContentStack indexOfObject:containerContent];
    NSAssert(index != NSNotFound, @"Content not found in the container");
    HLSAnimation *pushAnimation = [HLSContainerContent animationForTransitionStyle:containerContent.transitionStyle
                                                 withDisappearingContainerContents:[self.containerContentStack subarrayWithRange:NSMakeRange(0, index)]
                                                        appearingContainerContents:[NSArray arrayWithObject:containerContent] 
                                                                       commonFrame:self.view.frame
                                                                          duration:containerContent.duration];
    pushAnimation.tag = @"push_animation";
    pushAnimation.lockingUI = YES;
    pushAnimation.bringToFront = YES;
    pushAnimation.delegate = self;
    [self.pushAnimationStack replaceObjectAtIndex:index
                                       withObject:pushAnimation];
    
    return pushAnimation;
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
            HLSContainerContent *disappearingContainerContent = [self.containerContentStack lastObject];
            [disappearingContainerContent removeViewFromSuperview];
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
        [self unregisterTopViewController];
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
