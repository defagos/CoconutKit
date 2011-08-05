//
//  HLSStackController.m
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSAnimation.h"
#import "HLSAssert.h"
#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

const NSUInteger kStackMinimalCapacity = 2;
const NSUInteger kStackDefaultCapacity = 2;
const NSUInteger kStackUnlimitedCapacity = NSUIntegerMax;

// TODO: Bug: self.interfaceOrientation always returns portrait. WTF?

@interface HLSStackController () <HLSAnimationDelegate>

@property (nonatomic, retain) NSMutableArray *containerContentStack;

- (UIViewController *)secondTopViewController;

- (HLSAnimation *)animationForContainerContent:(HLSContainerContent *)containerContent;

- (BOOL)isContainerContentVisible:(HLSContainerContent *)containerContent;
- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController capacity:(NSUInteger)capacity
{
    if ((self = [super init])) {
        if (capacity < kStackMinimalCapacity) {
            capacity = kStackMinimalCapacity;
            HLSLoggerWarn(@"Capacity cannot be smaller than minimal value %d; set to this value", kStackMinimalCapacity);
        }
        
        HLSContainerContent *rootContainerContent = [[[HLSContainerContent alloc] initWithViewController:rootViewController 
                                                                                     containerController:self 
                                                                                         transitionStyle:HLSTransitionStyleNone 
                                                                                                duration:kAnimationTransitionDefaultDuration]
                                                     autorelease];
        self.containerContentStack = [NSMutableArray arrayWithObject:rootContainerContent];
        m_capacity = capacity;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController capacity:kStackDefaultCapacity];
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.containerContentStack = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    for (HLSContainerContent *containerContent in self.containerContentStack) {
        // Release views and forward events to the attached view controllers
        [containerContent releaseViews];
    }
}

#pragma mark Accessors and mutators

@synthesize containerContentStack = m_containerContentStack;

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
    
    // Take all space available. Parent container view controllers are responsible of stretching the view size properly
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Display those views required by the capacity
    for (HLSContainerContent *containerContent in [self.containerContentStack reverseObjectEnumerator]) {
        if ([self isContainerContentVisible:containerContent]) {
            if ([containerContent addViewToContainerView:self.view 
                                                 stretch:self.stretchingContent 
                                        blockInteraction:YES 
                                 inContainerContentStack:self.containerContentStack]) {        
            }
        }
        // Otherwise remove them (if loaded; should be quite rare here)
        else {
            [containerContent releaseViews];
        }
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

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // If a rotation occurs during a transition, do not let rotate. Could lead to complications
    if (m_animationCount != 0) {
        HLSLoggerWarn(@"A transition animation is running; rotation aborted");
        return NO;
    }
    
    // TODO: Support for HLSOrientationCloner is NOT trivial. Not implemented currently, maybe someday... The easiest
    //       way is probably not to rotate all view, but only the visible one. If it is an HLSOrientationCloner,
    //       swap it just before it will appear (if a view controller on top of it is popped) or in place (if it
    //       is at the top of the stack). Maybe this is not so difficult to implement after all, but this means
    //       that some calls to will...rotate / did...rotate will probably be made directly from viewWillAppear:
    
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
    [self pushViewController:viewController 
         withTransitionStyle:transitionStyle
                    duration:kAnimationTransitionDefaultDuration];
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
    
    // Can release the view not needed according to the capacity
    HLSContainerContent *newlyInvisibleContainerContent = [self containerContentAtDepth:m_capacity - 1];
    [newlyInvisibleContainerContent releaseViews];
    
    // Associate the view controller with its container
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:viewController 
                                                                             containerController:self
                                                                                 transitionStyle:transitionStyle 
                                                                                        duration:duration]
                                             autorelease];
    [self.containerContentStack addObject:containerContent];
    
    if ([self isViewLoaded]) {        
        // Install the view
        [containerContent addViewToContainerView:self.view
                                         stretch:self.stretchingContent 
                                blockInteraction:YES 
                         inContainerContentStack:self.containerContentStack];
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously
        HLSAnimation *pushAnimation = [self animationForContainerContent:containerContent];
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
        // A view being popped, we need one more view to be visible so that the capacity criterium can be fulfilled (if stack deep enough)
        HLSContainerContent *newlyVisibleContainerContent = [self containerContentAtDepth:m_capacity];
        if (newlyVisibleContainerContent) {
            [newlyVisibleContainerContent addViewToContainerView:self.view 
                                                         stretch:self.stretchingContent 
                                                blockInteraction:YES 
                                         inContainerContentStack:self.containerContentStack];
        }
        
        // Pop animation = reverse push animation
        HLSContainerContent *topContainerContent = [self.containerContentStack lastObject];
        HLSAnimation *popAnimation = [[self animationForContainerContent:topContainerContent] reverseAnimation];
        if ([self isViewVisible]) {
            [popAnimation playAnimated:YES];
        }
        else {
            [popAnimation playAnimated:NO];
        }        
    }
    // If the view is not loaded, we can unregister the popped view controller on the spot
    else {        
        [self.containerContentStack removeLastObject];
    }
}

#pragma mark Capacity

- (BOOL)isContainerContentVisible:(HLSContainerContent *)containerContent
{
    NSUInteger index = [self.containerContentStack indexOfObject:containerContent];
    return [self.containerContentStack count] - index <= m_capacity;
}

- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth
{
    if ([self.containerContentStack count] > depth) {
        return [self.containerContentStack objectAtIndex:[self.containerContentStack count] - depth - 1];
    }
    else {
        return nil;
    }
}

#pragma mark Animation

- (HLSAnimation *)animationForContainerContent:(HLSContainerContent *)containerContent
{
    // Apply the same effect to all disappearing views; much better (we see all views below the added one as a single one). This is
    // a lot better with push or fade animations
    NSAssert([self.containerContentStack indexOfObject:containerContent] != NSNotFound, @"Content not found in the container");
    HLSAnimation *animation = [containerContent animationWithContainerContentStack:self.containerContentStack containerView:self.view];
    animation.tag = @"push_animation";
    animation.lockingUI = YES;
    animation.bringToFront = YES;
    animation.delegate = self;
    return animation;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{    
    ++m_animationCount;
    
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
            
            // Remove the popped view controller's view
            HLSContainerContent *disappearingContainerContent = [self.containerContentStack lastObject];
            [disappearingContainerContent removeViewFromContainerView];
        }
        else {
            --m_animationCount;
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
        [self.containerContentStack removeLastObject];
    }
    
    --m_animationCount;
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
    
    return [HLSContainerContent containerControllerForViewController:self];
}

@end
