//
//  HLSStackController.m
//  CoconutKit
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

@interface HLSStackController () <HLSAnimationDelegate>

@property (nonatomic, retain) NSMutableArray *containerContentStack;

- (HLSContainerContent *)topContainerContent;
- (HLSContainerContent *)secondTopContainerContent;

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

@synthesize forwardingProperties = m_forwardingProperties;

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    if (m_forwardingProperties == forwardingProperties) {
        return;
    }
    
    m_forwardingProperties = forwardingProperties;
    
    HLSContainerContent *topContainerContent = [self topContainerContent];
    topContainerContent.forwardingProperties = m_forwardingProperties;
}

@synthesize delegate = m_delegate;

- (UIViewController *)rootViewController
{
    HLSContainerContent *containerContent = [self.containerContentStack firstObject];
    return containerContent.viewController;
}

- (UIViewController *)topViewController
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    return topContainerContent.viewController;
}

- (HLSContainerContent *)topContainerContent
{
    return [self.containerContentStack lastObject];
}

- (HLSContainerContent *)secondTopContainerContent
{
    if ([self.containerContentStack count] < 2) {
        return nil;
    }
    return [self.containerContentStack objectAtIndex:[self.containerContentStack count] - 2];
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
    else {
        // The top view controller must be the one that forwards its content (if forwarding enabled)
        HLSContainerContent *secondTopContainerContent = [self secondTopContainerContent];
        secondTopContainerContent.forwardingProperties = NO;
        
        containerContent.forwardingProperties = self.forwardingProperties;
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
        HLSContainerContent *topContainerContent = [self topContainerContent];
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
        
        // The top view controller must be the one that forwards its content (if forwarding enabled)
        HLSContainerContent *topContainerContent = [self topContainerContent];
        topContainerContent.forwardingProperties = self.forwardingProperties;
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
    
    HLSContainerContent *appearingContainerContent = nil;
    HLSContainerContent *disappearingContainerContent = nil;
    
    if ([animation.tag isEqual:@"push_animation"]) {
        appearingContainerContent = [self topContainerContent];
        disappearingContainerContent = [self secondTopContainerContent];        
    }
    else if ([animation.tag isEqual:@"reverse_push_animation"]) {
        appearingContainerContent = [self secondTopContainerContent];
        disappearingContainerContent = [self topContainerContent];
    }
    else {
        return;
    }
    
    // During the time the animation is running, we ensure that if forwarding is enabled the two top view controllers forward their
    // properties. This is made on purpose: This way, implementers of viewWill* and viewDid* methods will still get access to the 
    // correct properties through forwarding. Only at the end of the animation will the top view controller be the only one
    // forwarding properties
    appearingContainerContent.forwardingProperties = self.forwardingProperties;
    
    if ([self isViewVisible]) {        
        [disappearingContainerContent.viewController viewWillDisappear:animated];
        [appearingContainerContent.viewController viewWillAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
            [self.delegate stackController:self
                    willShowViewController:appearingContainerContent.viewController 
                                  animated:animated];
        }
    }    
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    --m_animationCount;
    
    HLSContainerContent *appearingContainerContent = nil;
    HLSContainerContent *disappearingContainerContent = nil;
    
    if ([animation.tag isEqual:@"push_animation"]) {
        appearingContainerContent = [self topContainerContent];
        disappearingContainerContent = [self secondTopContainerContent];
    }
    else if ([animation.tag isEqual:@"reverse_push_animation"]) {
        appearingContainerContent = [self secondTopContainerContent];
        disappearingContainerContent = [self topContainerContent];
        
        // At the end of the pop animation, the popped view controller's view is removed
        [disappearingContainerContent removeViewFromContainerView];
    }
    else {
        return;
    }
    
    if ([self isViewVisible]) {
        [disappearingContainerContent.viewController viewDidDisappear:animated];
    }
    
    // Only the view controller which appears must remain forwarding properties (if enabled) after the animation
    // has ended. Note that disabling forwarding for the disappearing view controller is made after viewDidDisappear:
    // has been called for it. This way, implementations of viewDidDisappear: could still access the forwarded
    // properties
    disappearingContainerContent.forwardingProperties = NO;
    
    if ([self isViewVisible]) {
        [appearingContainerContent.viewController viewDidAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
            [self.delegate stackController:self
                     didShowViewController:appearingContainerContent.viewController 
                                  animated:animated];
        }
    }
    
    if ([animation.tag isEqual:@"reverse_push_animation"]) {
        [self.containerContentStack removeLastObject];
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
    return [HLSContainerContent containerControllerKindOfClass:[HLSStackController class] forViewController:self];
}

@end
