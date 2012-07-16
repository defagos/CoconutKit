//
//  HLSContainerStack.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerStack.h"

#import "HLSAssert.h"
#import "HLSContainerAnimations.h"
#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "HLSZeroingWeakRef.h"
#import "NSArray+HLSExtensions.h"

// TODO: No requirement about the number of view controllers in an HLSContainerStack. HLSStackController, however, must always
//       have a root view controller (prevent pops, check that one has been defined when displayed for the first time)

const NSUInteger HLSContainerStackMinimalCapacity = 2;
const NSUInteger HLSContainerStackDefaultCapacity = 2;
const NSUInteger HLSContainerStackUnlimitedCapacity = NSUIntegerMax;

@interface HLSContainerStack ()

@property (nonatomic, assign) UIViewController *containerViewController;
@property (nonatomic, retain) NSMutableArray *containerContents;
@property (nonatomic, retain) HLSZeroingWeakRef *containerViewZeroingWeakRef;

- (HLSContainerContent *)topContainerContent;
- (HLSContainerContent *)secondTopContainerContent;

- (void)addViewForContainerContent:(HLSContainerContent *)containerContent;

- (BOOL)isContainerContentVisible:(HLSContainerContent *)containerContent;
- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth;

@end

@implementation HLSContainerStack

#pragma mark Object creation and destruction

- (id)initWithContainerViewController:(UIViewController *)containerViewController
{
    if ((self = [super init])) {
        if (! containerViewController) {
            HLSLoggerError(@"A container view controller must be provided");
            [self release];
            return nil;
        }
                
        self.containerViewController = containerViewController;
        self.containerContents = [NSMutableArray array];
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
    self.containerViewController = nil;
    self.containerContents = nil;
    self.containerViewZeroingWeakRef = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize containerViewController = m_containerViewController;

@synthesize containerContents = m_containerContents;

@synthesize containerViewZeroingWeakRef = m_containerViewZeroingWeakRef;

@synthesize capacity = m_capacity;

@synthesize forwardingProperties = m_forwardingProperties;

@synthesize removeInvisibleViewControllers = m_removeInvisibleViewControllers;

// TODO: Prevent changes when the stack has been displayed once
- (void)setCapacity:(NSUInteger)capacity
{
    if (self.containerContents) {
        HLSLoggerError(@"The capacity must be set early using user-defined runtime attributes");
        return;
    }
    
    if (capacity < HLSContainerStackMinimalCapacity) {
        capacity = HLSContainerStackMinimalCapacity;
        HLSLoggerWarn(@"The capacity cannot be smaller than %d; set to this value", HLSContainerStackMinimalCapacity);
    }
    
    m_capacity = capacity;
}

- (UIView *)containerView
{
    return self.containerViewZeroingWeakRef.object;
}

- (void)setContainerView:(UIView *)containerView
{
    if (self.containerViewZeroingWeakRef.object == containerView) {
        return;
    }
    
    if (! [containerView isDescendantOfView:[self.containerViewController view]]) {
        HLSLoggerError(@"The container view must be part of the view controller's view hierarchy");
        return;
    }
    
    self.containerViewZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:containerView] autorelease];
    
    // All animations must take place inside the view controller's view
    containerView.clipsToBounds = YES;
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
}

- (HLSContainerContent *)topContainerContent
{
    return [self.containerContents lastObject];
}

- (HLSContainerContent *)secondTopContainerContent
{
    if ([self.containerContents count] < 2) {
        return nil;
    }
    return [self.containerContents objectAtIndex:[self.containerContents count] - 2];
}

- (UIViewController *)rootViewController
{
    HLSContainerContent *rootContainerContent = [self.containerContents firstObject];
    return rootContainerContent.viewController;
}

- (UIViewController *)topViewController
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    return topContainerContent.viewController;
}

- (NSArray *)viewControllers
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (HLSContainerContent *containerContent in self.containerContents) {
        [viewControllers addObject:containerContent.viewController];
    }
    return [NSArray arrayWithArray:viewControllers];
}

- (NSUInteger)count
{
    return [self.containerContents count];
}

#pragma mark Adding and removing view controllers

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    NSAssert(viewController != nil, @"Cannot push nil");
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if ([self.containerViewController isViewVisible]) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.containerViewController.interfaceOrientation]) {
            HLSLoggerError(@"The view controller does not support the current view container orientation");
            return;
        }
    }
    
    // Can release the view not needed according to the capacity
    NSUInteger newlyInvisibleContainerContentIndex = self.capacity - 1;
    HLSContainerContent *newlyInvisibleContainerContent = [self containerContentAtDepth:newlyInvisibleContainerContentIndex];
    if (self.removeInvisibleViewControllers) {
        [self removeViewControllerAtIndex:newlyInvisibleContainerContentIndex];
    }
    else {
        [newlyInvisibleContainerContent releaseViews];
    }
    
    // If no view controller has been loaded yet, create the objects required to store it. The root view controller has always none
    // as transition style
    if (! self.containerContents) {
        self.containerContents = [NSMutableArray array];
        transitionStyle = HLSTransitionStyleNone;
    }
    
    // Associate the view controller with its container
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:viewController 
                                                                         containerViewController:self.containerViewController
                                                                                 transitionStyle:transitionStyle 
                                                                                        duration:duration] autorelease];
    [self.containerContents addObject:containerContent];
    
    if ([self.containerViewController isViewLoaded]) {
        [self addViewForContainerContent:containerContent];
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously
        HLSAnimation *pushAnimation = [HLSContainerAnimations animationWithTransitionStyle:transitionStyle 
                                                                 appearingContainerContent:containerContent 
                                                             disappearingContainerContents:[self.containerContents subarrayWithRange:NSMakeRange(0, [self.containerContents count] - 1)] 
                                                                             containerView:self.containerView 
                                                                                  duration:duration];
        pushAnimation.tag = @"push_animation";
        pushAnimation.lockingUI = YES;
        [pushAnimation playAnimated:[self.containerViewController isViewVisible]];
    }
    else {
        // The top view controller must be the one that forwards its content (if forwarding enabled)
        HLSContainerContent *secondTopContainerContent = [self secondTopContainerContent];
        secondTopContainerContent.forwardingProperties = NO;
        
        containerContent.forwardingProperties = self.forwardingProperties;
    }
}

- (void)popViewController
{
    [self removeViewControllerAtIndex:[self.containerContents count] - 1];
}

- (void)popToViewController:(UIViewController *)viewController
{
    NSUInteger index = [[self viewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"The view controller to pop to does not belong to the container");
        return;
    }
    
    for (NSUInteger i = index + 1; i < [self.containerContents count]; ++i) {
        [self removeViewControllerAtIndex:i];
    }
}

- (void)popToRootViewController
{
    [self popToViewController:[self rootViewController]];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index
{
    if (index >= [self.containerContents count]) {
        HLSLoggerError(@"Invalid index");
        return;
    }
    
    if ([self.containerViewController isViewLoaded]) {
        HLSContainerContent *removedContainerContent = [self.containerContents objectAtIndex:index];
        
        // If visible, then we need to load a view controller below so that the capacity criterium can be fulfilled
        if ([self isContainerContentVisible:removedContainerContent]) {
            HLSContainerContent *newlyVisibleContainerContent = [self containerContentAtDepth:self.capacity];
            if (newlyVisibleContainerContent && ! newlyVisibleContainerContent.addedToContainerView) {
                [self addViewForContainerContent:newlyVisibleContainerContent];
            }
        }
        
        // Pop animation
        HLSAnimation *popAnimation = [[HLSContainerAnimations animationWithTransitionStyle:removedContainerContent.transitionStyle
                                                                 appearingContainerContent:removedContainerContent
                                                             disappearingContainerContents:[self.containerContents subarrayWithRange:NSMakeRange(0, index)]
                                                                             containerView:self.containerView 
                                                                                  duration:removedContainerContent.duration] reverseAnimation];
        popAnimation.tag = @"pop_animation";
        popAnimation.lockingUI = YES;
        if (index == [self.containerContents count] - 1 && [self.containerViewController isViewVisible]) {
            [popAnimation playAnimated:YES];
        }
        else {
            [popAnimation playAnimated:NO];
        }
    }
    // If the view is not loaded, we can unregister the popped view controller on the spot
    else {
        [self.containerContents removeObjectAtIndex:index];
        
        // The top view controller must be the one that forwards its content (if forwarding enabled). If the top view controller
        // has been removed, this ensures the new top one has this property
        HLSContainerContent *topContainerContent = [self topContainerContent];
        topContainerContent.forwardingProperties = self.forwardingProperties;
    }
}

- (void)rotateWithDuration:(NSTimeInterval)duration
{
    HLSAnimation *animation = [HLSContainerAnimations rotationAnimationWithContainerContents:self.containerContents 
                                                                               containerView:[self containerView]
                                                                                    duration:duration];
    animation.lockingUI = YES;
    [animation playAnimated:YES];
}

- (void)releaseViews
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent releaseViews];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSAssert([self.containerContents count] != 0, @"At least one view controller must be loaded");
    
    // Display those views required according to the capacity
    for (HLSContainerContent *containerContent in [self.containerContents reverseObjectEnumerator]) {
        if ([self isContainerContentVisible:containerContent]) {
            [self addViewForContainerContent:containerContent];
        }
        // Otherwise remove them (if loaded; should be quite rare here)
        else {
            [containerContent releaseViews];
        }
    }
    
    // Forward events to the top view controller
    HLSContainerContent *topContainerContent = [self topContainerContent];
#if 0
    if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
        [self.delegate stackController:self willShowViewController:topContainerContent.viewController animated:animated];
    }
#endif
    
    [topContainerContent viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
#if 0
    if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
        [self.delegate stackController:self didShowViewController:topContainerContent.viewController animated:animated];
    }
#endif
    
    [topContainerContent viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self topContainerContent] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self topContainerContent] viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // TODO: Support for HLSOrientationCloner is NOT trivial. Not implemented currently, maybe someday... The easiest
    //       way is probably not to rotate all view, but only the visible one. If it is an HLSOrientationCloner,
    //       swap it just before it will appear (if a view controller on top of it is popped) or in place (if it
    //       is at the top of the stack). Maybe this is not so difficult to implement after all, but this means
    //       that some calls to will...rotate / did...rotate will probably be made directly from viewWillAppear:
    
    // If one view controller in the stack does not support the orientation, neither will the container
    for (HLSContainerContent *containerContent in self.containerContents) {
        if (! [containerContent shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self rotateWithDuration:duration];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

#pragma mark Managing contents

- (void)addViewForContainerContent:(HLSContainerContent *)containerContent
{
    NSAssert(self.containerView != nil, @"A container view must have been defined");
    
    if (containerContent.addedToContainerView) {
        return;
    }
    
    NSUInteger index = [self.containerContents indexOfObject:containerContent];
    NSAssert(index != NSNotFound, @"Content not found in the stack");
        
    // Last element? Add to top
    if (index == [self.containerContents count] - 1) {
        [containerContent addAsSubviewIntoContainerView:self.containerView];
    }
    // Otherwise add below first content above for which a view is available (most probably the nearest neighbour above)
    else {
        BOOL added = NO;
        for (NSUInteger i = index + 1; i < [self.containerContents count]; ++i) {
            HLSContainerContent *aboveContainerContent = [self.containerContents objectAtIndex:i];
            if ([aboveContainerContent view]) {
                [containerContent insertAsSubviewIntoContainerView:self.containerView atIndex:i];
                added = YES;
                break;
            }
        }
        
        if (! added) {
            HLSLoggerError(@"Could not insert the view; no view found above in the stack");
            return;
        }            
    }
    
    // The transitions of the contents above in the stack might move views below in the stack. To account for this
    // effect, we must replay them so that the view we have inserted is put at the proper location
    if ([self.containerContents count] != 0) {
        for (NSUInteger i = index + 1; i < [self.containerContents count]; ++i) {
            HLSContainerContent *aboveContainerContent = [self.containerContents objectAtIndex:i];
            HLSAnimation *animation = [HLSContainerAnimations animationWithTransitionStyle:aboveContainerContent.transitionStyle
                                                                 appearingContainerContent:nil
                                                             disappearingContainerContents:[NSArray arrayWithObject:containerContent]
                                                                             containerView:self.containerView 
                                                                                  duration:0.];
            animation.lockingUI = YES;
            [animation playAnimated:NO];
        }
    }    
}

#pragma mark Capacity

- (BOOL)isContainerContentVisible:(HLSContainerContent *)containerContent
{
    NSUInteger index = [self.containerContents indexOfObject:containerContent];
    return [self.containerContents count] - index <= self.capacity;
}

- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth
{
    if ([self.containerContents count] > depth) {
        return [self.containerContents objectAtIndex:[self.containerContents count] - depth - 1];
    }
    else {
        return nil;
    }
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSContainerContent *appearingContainerContent = nil;
    HLSContainerContent *disappearingContainerContent = nil;
    
    if ([animation.tag isEqualToString:@"push_animation"]) {
        appearingContainerContent = [self topContainerContent];
        disappearingContainerContent = [self secondTopContainerContent];        
    }
    else if ([animation.tag isEqualToString:@"pop_animation"]) {
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
    
    if ([self.containerViewController isViewVisible]) {
        [disappearingContainerContent viewWillDisappear:animated];
        [appearingContainerContent viewWillAppear:animated];
        
#if 0
        if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
            [self.delegate stackController:self
                    willShowViewController:appearingContainerContent.viewController 
                                  animated:animated];
        }
#endif
    }    
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    HLSContainerContent *appearingContainerContent = nil;
    HLSContainerContent *disappearingContainerContent = nil;
    
    if ([animation.tag isEqualToString:@"push_animation"]) {
        appearingContainerContent = [self topContainerContent];
        disappearingContainerContent = [self secondTopContainerContent];
    }
    else if ([animation.tag isEqualToString:@"pop_animation"]) {
        appearingContainerContent = [self secondTopContainerContent];
        disappearingContainerContent = [self topContainerContent];
        
        // At the end of the pop animation, the popped view controller's view is removed
        [disappearingContainerContent removeViewFromContainerView];
    }
    else {
        return;
    }
    
    if ([self.containerViewController isViewVisible]) {
        [disappearingContainerContent viewDidDisappear:animated];
    }
    
    // Only the view controller which appears must remain forwarding properties (if enabled) after the animation
    // has ended. Note that disabling forwarding for the disappearing view controller is made after viewDidDisappear:
    // has been called for it. This way, implementations of viewDidDisappear: could still access the forwarded
    // properties
    disappearingContainerContent.forwardingProperties = NO;
    
    if ([self.containerViewController isViewVisible]) {
        [appearingContainerContent viewDidAppear:animated];
        
#if 0
        if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
            [self.delegate stackController:self
                     didShowViewController:appearingContainerContent.viewController 
                                  animated:animated];
        }
#endif
    }
    
    if ([animation.tag isEqualToString:@"pop_animation"]) {
        [self.containerContents removeLastObject];
    }
}

@end


@implementation UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass
{
    return [HLSContainerContent containerViewControllerKindOfClass:containerViewControllerClass
                                                 forViewController:self];
}

@end
