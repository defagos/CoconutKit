//
//  HLSContainerStack.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerStack.h"

#import "HLSAssert.h"
#import "HLSContainerAnimation.h"
#import "HLSContainerContent.h"
#import "HLSContainerStackView.h"
#import "HLSConverters.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// TODO: Document when viewWillAppear... etc. are called, test cases, and when animated = YES / NO

/**
 * TODO: Mimic behavior of the navigation controller delegate methods?
 * - display as root -> calls will / didShow for the root view controller
 * - push new VC -> calls will / didShow for this new view controller
 * - pop VC -> calls will / didShow for the VC which gets revealed
 * - display and hide modal -> does not call will / didShow
 */

// TODO: Tester la capacité minimale

/**
 * Some view controller containers might display several view controllers simultaneously in the same content view. In
 * such cases, the corresponding stack of container content objects can be provided (the receiver must be part of it).
 * This allows the view to be inserted at the proper location in the view hierarchy. If this parameter is nil, the
 * view is simply added on top.
 * The first element in the stack array is interpreted as the bottommost one.
 */

// TODO: No requirement about the number of view controllers in an HLSContainerStack. HLSStackController, however, must always
//       have a root view controller (prevent pops, check that one has been defined when displayed for the first time)

// Constants
const NSUInteger HLSContainerStackMinimalCapacity = 1;
const NSUInteger HLSContainerStackDefaultCapacity = 2;
const NSUInteger HLSContainerStackUnlimitedCapacity = NSUIntegerMax;

@interface HLSContainerStack ()

@property (nonatomic, assign) UIViewController *containerViewController;
@property (nonatomic, retain) NSMutableArray *containerContents;
@property (nonatomic, assign) NSUInteger capacity;

- (HLSContainerContent *)topContainerContent;
- (HLSContainerContent *)secondTopContainerContent;

- (void)addViewForContainerContent:(HLSContainerContent *)containerContent
                 playingTransition:(BOOL)playingTransition
                          animated:(BOOL)animated;

- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth;

@end

@implementation HLSContainerStack

#pragma mark Class methods

+ (id)singleControllerContainerStackWithContainerViewController:(UIViewController *)containerViewController
{
    return [[[[self class] alloc] initWithContainerViewController:containerViewController
                                                         capacity:HLSContainerStackMinimalCapacity 
                                                         removing:YES
                                      rootViewControllerMandatory:NO] autorelease];
}

#pragma mark Object creation and destruction

- (id)initWithContainerViewController:(UIViewController *)containerViewController 
                             capacity:(NSUInteger)capacity
                             removing:(BOOL)removing
          rootViewControllerMandatory:(BOOL)rootViewControllerMandatory
{
    if ((self = [super init])) {
        if (! containerViewController) {
            [self release];
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"Missing container view controller"
                                         userInfo:nil];
        }
                
        self.containerViewController = containerViewController;
        self.containerContents = [NSMutableArray array];
        self.capacity = capacity;
        m_removing = removing;
        m_rootViewControllerMandatory = rootViewControllerMandatory;
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
    self.containerView = nil;
    self.delegate = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize containerViewController = m_containerViewController;

@synthesize containerContents = m_containerContents;

@synthesize containerView = m_containerView;

- (void)setContainerView:(UIView *)containerView
{
    if (m_containerView == containerView) {
        return;
    }
    
    if (containerView) {
        if (! [containerView isDescendantOfView:[self.containerViewController view]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException 
                                           reason:@"The container view must be part of the view controller's view hierarchy"
                                         userInfo:nil];
        }
        
        // All animations must take place inside the view controller's view
        containerView.clipsToBounds = YES;
    }
    
    m_containerView = containerView;
    
    HLSContainerStackView *containerStackView = [[[HLSContainerStackView alloc] initWithFrame:containerView.bounds] autorelease];
    [containerView addSubview:containerStackView];
}

- (HLSContainerStackView *)containerStackView
{
    NSAssert([[self.containerView.subviews firstObject] isKindOfClass:[HLSContainerStackView class]], @"Expected a container view as first subview");
    return [self.containerView.subviews firstObject];
}

@synthesize capacity = m_capacity;

- (void)setCapacity:(NSUInteger)capacity
{
    if (capacity < HLSContainerStackMinimalCapacity) {
        capacity = HLSContainerStackMinimalCapacity;
        HLSLoggerWarn(@"The capacity cannot be smaller than %d; set to this value", HLSContainerStackMinimalCapacity);
    }
    
    m_capacity = capacity;
}

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
                  animated:(BOOL)animated
{
    [self insertViewController:viewController
                       atIndex:[self.containerContents count] 
           withTransitionStyle:transitionStyle
                      duration:duration
                      animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self removeViewControllerAtIndex:[self.containerContents count] - 1 animated:animated];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController) {
        NSUInteger index = [[self viewControllers] indexOfObject:viewController];
        if (index == NSNotFound) {
            HLSLoggerWarn(@"The view controller to pop to does not belong to the container");
            return;
        }
        else if (index == [self.containerContents count] - 1) {
            HLSLoggerWarn(@"Nothing to pop: The view controller displayed is already the one you try to pop to");
            return;
        }
        [self popToViewControllerAtIndex:index animated:animated];
    }
    else {        
        // Pop everything
        [self popToViewControllerAtIndex:NSUIntegerMax animated:animated];
    }
}

- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSUInteger firstRemovedIndex = 0;
    if (index != NSUIntegerMax) {
        if (index < [self.containerContents count] - 1) {
            firstRemovedIndex = index + 1;
        }
        else if (index == [self.containerContents count] - 1) {
            HLSLoggerWarn(@"Nothing to pop: The view controller displayed is already the one you try to pop to");
            return;            
        }
        else {
            HLSLoggerWarn(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count] - 2);
            return;
        }
    }
    else {
        if (m_rootViewControllerMandatory) {
            HLSLoggerWarn(@"A root view controller is mandatory. Cannot pop everything");
            return;
        }
        
        firstRemovedIndex = 0;
    }
    
    // Remove the view controllers up to the one we want to pop to (except the topmost one)
    NSUInteger i = [self.containerContents count] - firstRemovedIndex - 1;
    while (i > 0) {
        [self.containerContents removeObjectAtIndex:firstRemovedIndex];
        --i;
    }
    
    // Resurrect view controller's views below the view controller we pop to so that the capacity criterium
    // is satisfied
    for (NSUInteger i = 0; i < self.capacity; ++i) {        
        NSUInteger index = firstRemovedIndex - 1 - i;
        HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
        [self addViewForContainerContent:containerContent playingTransition:NO animated:NO];
        
        if (index == 0) {
            break;
        }
    }
    
    // Now pop the top view controller
    [self popViewControllerAnimated:animated]; 
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self.containerContents count] != 0) {
        [self popToViewControllerAtIndex:0 animated:animated];
    }
    else {
        HLSLoggerWarn(@"No root view controller has been loaded");
    }    
}

- (void)popAllViewControllersAnimated:(BOOL)animated
{
    [self popToViewControllerAtIndex:NSUIntegerMax animated:animated];
}

- (void)insertViewController:(UIViewController *)viewController 
                     atIndex:(NSUInteger)index 
         withTransitionStyle:(HLSTransitionStyle)transitionStyle 
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    if (! viewController) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Cannot push nil into a view controller container"
                                     userInfo:nil];
    }
    
    if (index > [self.containerContents count]) {
        HLSLoggerWarn(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count]);
        return;
    }
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if ([self.containerViewController isViewVisible]) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.containerViewController.interfaceOrientation]) {
            HLSLoggerError(@"The view controller does not support the current view container orientation");
            return;
        }
    }
    
    // Associate the new view controller with its container (this increases the containerContents array size)
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:viewController
                                                                         containerViewController:self.containerViewController
                                                                                 transitionStyle:transitionStyle
                                                                                        duration:duration] autorelease];
    [self.containerContents insertObject:containerContent atIndex:index];
    
    // If inserted in the capacity range, must add the view
    if ([self.containerViewController isViewVisible]) {
        if ([self.containerContents count] - index - 1 <= self.capacity) {
            [self addViewForContainerContent:containerContent playingTransition:YES animated:animated];
        }
    }
}

- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    NSUInteger index = [[self viewControllers] indexOfObject:siblingViewController];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The given sibling view controller does not belong to the container");
        return;
    }
    [self insertViewController:viewController 
                       atIndex:index 
           withTransitionStyle:transitionStyle 
                      duration:duration
                      animated:animated];
}

- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    NSUInteger index = [[self viewControllers] indexOfObject:siblingViewController];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The given sibling view controller does not belong to the container");
        return;
    }
    [self insertViewController:viewController 
                       atIndex:index + 1 
           withTransitionStyle:transitionStyle 
                      duration:duration
                      animated:animated];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= [self.containerContents count]) {
        HLSLoggerWarn(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count] - 1);
        return;
    }
    
    if (m_rootViewControllerMandatory && [self.containerContents count] == 1) {
        HLSLoggerWarn(@"A root view controller is mandatory. Cannot pop the only one which remains");
        return;
    }
    
    HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
    if ([self.containerViewController isViewVisible] && containerContent.addedToContainerView) {
        // Load the view below so that the capacity criterium can be fulfilled (if needed). During the animation we will
        // have capacity + 1 view controller's views loaded, this ensures that no view controllers magically pop up during
        // animation
        HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
        if (containerContentAtCapacity) {
            [self addViewForContainerContent:containerContentAtCapacity playingTransition:NO animated:NO];
        }
                
        HLSAnimation *animation = [[HLSContainerAnimation animationWithTransitionStyle:containerContent.transitionStyle
                                                                                inView:[containerContent viewIfLoaded].superview
                                                                              duration:containerContent.duration] reverseAnimation];
        if (index == [self.containerContents count] - 1 && [self.containerViewController isViewVisible]) {
            animation.tag = @"pop_animation";
            animation.lockingUI = YES;
            animation.delegate = self;
            
            [animation playAnimated:animated];
        }
        else {
            [animation playAnimated:NO];
            [self.containerContents removeObject:containerContent];
        }        
    }
    else {
        [self.containerContents removeObjectAtIndex:index];
        
        [self topContainerContent].forwardingProperties = YES;
    }
}

- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSUInteger index = [[self viewControllers] indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The view controller to remove does not belong to the container");
        return;
    }
    [self removeViewControllerAtIndex:index animated:animated];
}

- (void)rotateWithDuration:(NSTimeInterval)duration
{
    HLSAnimation *animation = [HLSContainerAnimation rotationAnimationWithContainerContents:self.containerContents 
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
    
    self.containerView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (m_rootViewControllerMandatory && [self.containerContents count] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                       reason:@"A root view controller is mandatory"
                                     userInfo:nil];
    }
    
    // Display those views required according to the capacity
    for (NSUInteger i = 0; i < self.capacity; ++i) {
        // Never play transitions (we are building the view hierarchy). Only the top view controller receives
        // the animated information
        HLSContainerContent *containerContent = [self containerContentAtDepth:i];
        if (containerContent) {
            [self addViewForContainerContent:containerContent playingTransition:NO animated:i == 0];
        }
    }
        
    // Forward events to the top view controller
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
        [self.delegate containerStack:self willShowViewController:topContainerContent.viewController animated:animated];
    }
        
    [topContainerContent viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
        [self.delegate containerStack:self didShowViewController:topContainerContent.viewController animated:animated];
    }
        
    [topContainerContent viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
        [self.delegate containerStack:self willHideViewController:topContainerContent.viewController animated:animated];
    }
    
    [topContainerContent viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
        [self.delegate containerStack:self didHideViewController:topContainerContent.viewController animated:animated];
    }
    
    [topContainerContent viewDidDisappear:animated];
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

// The containerContent object must already reside in containerContents. This method is namely intended to be used
// when pushing a view controller, e.g., but also when creating a hierarchy with pre-loaded or unloaded view
// controllers
- (void)addViewForContainerContent:(HLSContainerContent *)containerContent 
                 playingTransition:(BOOL)playingTransition
                          animated:(BOOL)animated
{
    if (! containerContent) {
        HLSLoggerError(@"Missing container content parameter");
        return;
    }
    
    if (! [self.containerViewController isViewVisible]) {
        return;
    }
    
    if (! self.containerView) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The view controller container view has been loaded, but no container view has been set"
                                     userInfo:nil];
    }
    
    if (containerContent.addedToContainerView) {
        return;
    }
    
    NSUInteger index = [self.containerContents indexOfObject:containerContent];
    NSAssert(index != NSNotFound, @"Content not found in the stack");
    
    HLSContainerStackView *stackView = [self containerStackView];
    
    // Last element? Add to top
    if (index == [self.containerContents count] - 1) {
        [containerContent addAsSubviewIntoContainerStackView:stackView];
    }
    // Otherwise add below first content above for which a view is available (most probably the nearest neighbor above)
    else {
        // Find which container view above is available. We will insert the new one right below it (usually,
        // this is the one at index + 1, but this might not be the case if we are resurrecting a view controller
        // deep in the stack)
        BOOL inserted = NO;
        for (NSUInteger i = index + 1; i < [self.containerContents count]; ++i) {
            HLSContainerContent *aboveContainerContent = [self.containerContents objectAtIndex:i];
            if (aboveContainerContent.isAddedToContainerView) {
                [containerContent insertAsSubviewIntoContainerStackView:stackView
                                                                atIndex:[stackView.subviews indexOfObject:[aboveContainerContent viewIfLoaded]]];
                inserted = YES;
                break;
            }
        }
        
        if (! inserted) {
            [containerContent addAsSubviewIntoContainerStackView:stackView];
        }
    }
    
    // Play the corresponding animation so that the view controllers are brought into correct positions
    HLSContainerGroupView *groupView = [[self containerStackView] groupViewForSubview:[containerContent viewIfLoaded]];
    HLSAnimation *animation = [HLSContainerAnimation animationWithTransitionStyle:containerContent.transitionStyle
                                                                           inView:groupView
                                                                         duration:containerContent.duration];    
    if (playingTransition && index == [self.containerContents count] - 1 && [self.containerViewController isViewVisible]) {
        animation.tag = @"push_animation";
        animation.lockingUI = YES;
        animation.delegate = self;
        
        [animation playAnimated:animated];
    }
    else {
        [animation playAnimated:NO];
    }
}

#pragma mark Capacity

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

// Called for any push / pop animation, whether animated or not
- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"push_animation"] || [animation.tag isEqualToString:@"pop_animation"]) {
        HLSContainerContent *appearingContainerContent = nil;
        HLSContainerContent *disappearingContainerContent = nil;
        
        if ([animation.tag isEqualToString:@"push_animation"]) {
            appearingContainerContent = [self topContainerContent];
            disappearingContainerContent = [self secondTopContainerContent];        
        }
        else {
            appearingContainerContent = [self secondTopContainerContent];
            disappearingContainerContent = [self topContainerContent];
        }
        
        // During the time the animation is running, we ensure that if forwarding is enabled the two top view controllers forward their
        // properties. This is made on purpose: This way, implementers of viewWill* and viewDid* methods will still get access to the 
        // correct properties through forwarding. Only at the end of the animation will the top view controller be the only one
        // forwarding properties
        appearingContainerContent.forwardingProperties = self.forwardingProperties;
        
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
            [self.delegate containerStack:self willHideViewController:disappearingContainerContent.viewController animated:animated];
        }
        [disappearingContainerContent viewWillDisappear:animated];
        
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
            [self.delegate containerStack:self willShowViewController:appearingContainerContent.viewController animated:animated];
        }
        [appearingContainerContent viewWillAppear:animated];
    }    
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"push_animation"] || [animation.tag isEqualToString:@"pop_animation"]) {
        HLSContainerContent *appearingContainerContent = nil;
        HLSContainerContent *disappearingContainerContent = nil;
        
        if ([animation.tag isEqualToString:@"push_animation"]) {
            appearingContainerContent = [self topContainerContent];
            disappearingContainerContent = [self secondTopContainerContent];
        }
        else {
            appearingContainerContent = [self secondTopContainerContent];
            disappearingContainerContent = [self topContainerContent];
        }
        
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
            [self.delegate containerStack:self didHideViewController:disappearingContainerContent.viewController animated:animated];
        }
        [disappearingContainerContent viewDidDisappear:animated];
        
        // Only the view controller which appears must remain forwarding properties (if enabled) after the animation
        // has ended. Note that disabling forwarding for the disappearing view controller is made after viewDidDisappear:
        // has been called for it. This way, implementations of viewDidDisappear: could still access the forwarded
        // properties
        disappearingContainerContent.forwardingProperties = NO;
        
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
            [self.delegate containerStack:self didShowViewController:appearingContainerContent.viewController animated:animated];
        }
        [appearingContainerContent viewDidAppear:animated];
        
        if ([animation.tag isEqualToString:@"push_animation"]) {
            // Now that the animation is over, get rid of the view or view controller which does not match the capacity criterium
            HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
            if (! m_removing) {
                [containerContentAtCapacity releaseViews];
            }
            else {
                [self.containerContents removeObject:containerContentAtCapacity];
            }
        }
        else if ([animation.tag isEqualToString:@"pop_animation"]) {
            [self.containerContents removeObject:disappearingContainerContent];
        }
    }
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; containerViewController: %@; containerContents: %@; containerView: %@; forwardingProperties: %@>", 
            [self class],
            self,
            self.containerViewController,
            self.containerContents,
            self.containerView,
            HLSStringFromBool(self.forwardingProperties)];
}

@end

@implementation UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass
{
    return [HLSContainerContent containerViewControllerKindOfClass:containerViewControllerClass
                                                 forViewController:self];
}

@end
