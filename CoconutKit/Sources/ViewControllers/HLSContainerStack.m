//
//  HLSContainerStack.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerStack.h"

#import "HLSAssert.h"
#import "HLSContainerContent.h"
#import "HLSContainerStackView.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// TODO: Document when viewWillAppear... etc. are called, test cases, and when animated = YES / NO

// TODO: Prevent containerView from being changed after the view has been displayed

// TODO: Prevent simultaneous pops / pushes

/**
 * TODO: Mimic behavior of the navigation controller delegate methods?
 * - display as root -> calls will / didShow for the root view controller
 * - push new VC -> calls will / didShow for this new view controller
 * - pop VC -> calls will / didShow for the VC which gets revealed
 * - display and hide modal -> does not call will / didShow
 */

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

+ (HLSAnimation *)transitionAnimationWithClass:(Class)transitionClass
                                 appearingView:(UIView *)appearingView
                              disappearingView:(UIView *)disappearingView
                                        inView:(UIView *)inView
                                      duration:(NSTimeInterval)duration;

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

+ (HLSAnimation *)transitionAnimationWithClass:(Class)transitionClass
                                 appearingView:(UIView *)appearingView
                              disappearingView:(UIView *)disappearingView
                                        inView:(UIView *)view
                                      duration:(NSTimeInterval)duration
{
    NSAssert([transitionClass isSubclassOfClass:[HLSTransition class]], @"Transitions must be subclasses of HLSTransition");
    NSAssert((! appearingView || appearingView.superview == view) && (! disappearingView || disappearingView.superview == view),
             @"Both the appearing and disappearing views must be children of the view in which the transition takes place");
        
    // Calculate the exact frame in which the animations will occur (taking into account the transform applied
    // to the parent view)
    CGRect frame = CGRectApplyAffineTransform(view.frame, CGAffineTransformInvert(view.transform));
    
    // Build the animation with default parameters
    NSArray *animationSteps = [[transitionClass class] animationStepsWithAppearingView:appearingView
                                                                      disappearingView:disappearingView
                                                                               inFrame:frame];
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:animationSteps];
    
    // Generate an animation with the proper duration
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
    }
    else {
        return [animation animationWithDuration:duration];
    }
}

#pragma mark Object creation and destruction

- (id)initWithContainerViewController:(UIViewController *)containerViewController 
                             capacity:(NSUInteger)capacity
                             removing:(BOOL)removing
          rootViewControllerMandatory:(BOOL)rootViewControllerMandatory
{
    if ((self = [super init])) {
        if (! containerViewController) {
            HLSLoggerError(@"Missing container view controller");
            [self release];
            return nil;
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
        
    if ([self.containerViewController isViewVisible]) {
        HLSLoggerError(@"Cannot change the container view when the container view controller is being displayed");
        return;
    }
    
    if (containerView) {
        if (! [self.containerViewController isViewLoaded]) {
            HLSLoggerError(@"Cannot set a container view when the container view controller's view has not been loaded");
            return;
        }
        
        if (! [containerView isDescendantOfView:[self.containerViewController view]]) {
            HLSLoggerError(@"The container view must be part of the container view controller's view hiearchy");
            return;
        }
        
        // All animations must take place inside the view controller's view
        containerView.clipsToBounds = YES;
        
        // Create the container base view maintaining the whole container view hiearchy
        HLSContainerStackView *containerStackView = [[[HLSContainerStackView alloc] initWithFrame:containerView.bounds] autorelease];
        [containerView addSubview:containerStackView];
    }
    
    [m_containerView release];
    m_containerView = [containerView retain];
}

- (HLSContainerStackView *)containerStackView
{
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
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated
{
    [self insertViewController:viewController
                       atIndex:[self.containerContents count] 
           withTransitionClass:transitionClass
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
            HLSLoggerInfo(@"Nothing to pop: The view controller displayed is already the one you try to pop to");
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
    if ([self.containerContents count] == 0) {
        HLSLoggerInfo(@"Nothing to pop: The view controller container is empty");
        return;
    }
    
    // Pop to a valid index
    NSUInteger firstRemovedIndex = 0;
    if (index != NSUIntegerMax) {
        // Remove in the middle
        if (index < [self.containerContents count] - 1) {
            firstRemovedIndex = index + 1;
        }
        // Nothing to do if we pop to the current top view controller
        else if (index == [self.containerContents count] - 1) {
            HLSLoggerInfo(@"Nothing to pop: The view controller displayed is already the one you try to pop to");
            return;            
        }
        else {
            HLSLoggerError(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count] - 2);
            return;
        }
    }
    // Pop everything
    else {
        if (m_rootViewControllerMandatory) {
            HLSLoggerWarn(@"A root view controller is mandatory. Cannot pop everything");
            return;
        }
        
        firstRemovedIndex = 0;
    }
    
    // Remove the view controllers until the one we want to pop to (except the topmost one, for which we will play
    // the pop animation if desired)
    NSUInteger i = [self.containerContents count] - firstRemovedIndex - 1;
    while (i > 0) {
        [self.containerContents removeObjectAtIndex:firstRemovedIndex];
        --i;
    }
    
    // Resurrect view controller's views below the view controller we pop to so that the capacity criterium
    // is satisfied
    for (NSUInteger i = 0; i < MIN(self.capacity, [self.containerContents count]); ++i) {
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
    [self popToViewControllerAtIndex:0 animated:animated];    
}

- (void)popAllViewControllersAnimated:(BOOL)animated
{
    [self popToViewControllerAtIndex:NSUIntegerMax animated:animated];
}

- (void)insertViewController:(UIViewController *)viewController 
                     atIndex:(NSUInteger)index 
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    if (! viewController) {
        HLSLoggerError(@"Cannot push nil into a view controller container");
        return;
    }
    
    if (index > [self.containerContents count]) {
        HLSLoggerError(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count]);
        return;
    }
    
    if (m_animating) {
        HLSLoggerWarn(@"Cannot insert a view controller while a transition animation is running");
        return;
    }
    
    if ([self.containerViewController isViewVisible]) {
        // Check that the view controller to be pushed is compatible with the current orientation
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.containerViewController.interfaceOrientation]) {
            HLSLoggerError(@"The view controller does not support the current view container orientation");
            return;
        }
        
        // Notify the delegate before the view controller is actually installed on top of the stack and associated with the
        // container (see HLSContainerStackDelegate interface contract)
        if (index == [self.containerContents count]) {
            if ([self.delegate respondsToSelector:@selector(containerStack:willPushViewController:coverViewController:animated:)]) {
                [self.delegate containerStack:self
                       willPushViewController:viewController
                          coverViewController:[self topViewController]
                                     animated:animated];
            }
        }
    }
        
    // Associate the new view controller with its container (this increases [container count])
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:viewController
                                                                         containerViewController:self.containerViewController
                                                                                 transitionClass:transitionClass
                                                                                        duration:duration] autorelease];
    [self.containerContents insertObject:containerContent atIndex:index];
    
    // If inserted in the capacity range, must add the view
    if ([self.containerViewController isViewVisible]) {
        // A correction needs to be applied here to account for the [container count] increase (since index was relative
        // to the previous value)
        if ([self.containerContents count] - index - 1 <= self.capacity) {
            [self addViewForContainerContent:containerContent playingTransition:YES animated:animated];
        }
    }
}

- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
{
    NSUInteger index = [[self viewControllers] indexOfObject:siblingViewController];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The given sibling view controller does not belong to the container");
        return;
    }
    [self insertViewController:viewController 
                       atIndex:index 
           withTransitionClass:transitionClass
                      duration:duration
                      animated:NO /* irrelevant since this method can never be used for pushing a view controller */];
}

- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
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
           withTransitionClass:transitionClass
                      duration:duration
                      animated:animated];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= [self.containerContents count]) {
        HLSLoggerError(@"Invalid index %d. Expected in [0;%d]", index, [self.containerContents count] - 1);
        return;
    }
    
    if (m_animating) {
        HLSLoggerWarn(@"Cannot remove a view controller while a transition animation is running");
        return;
    }
    
    if (m_rootViewControllerMandatory && [self.containerContents count] == 1) {
        HLSLoggerWarn(@"A root view controller is mandatory. Cannot pop the only one which remains");
        return;
    }
    
    if ([self.containerViewController isViewVisible]) {
        // Notify the delegate before the view controller is actually removed from the top of the stack (see HLSContainerStackDelegate
        // interface contract)
        if (index == [self.containerContents count] - 1) {
            if ([self.delegate respondsToSelector:@selector(containerStack:willPopViewController:revealViewController:animated:)]) {
                [self.delegate containerStack:self
                        willPopViewController:[self topViewController]
                         revealViewController:self.secondTopContainerContent.viewController
                                     animated:animated];
            }
        }
    }
        
    HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
    if ([self.containerViewController isViewVisible] && containerContent.addedToContainerView) {
        // Load the view controller'sview below so that the capacity criterium can be fulfilled (if needed). If we are popping a
        // view controller, we will have capacity + 1 view controller's views loaded during the animation. This ensures that no
        // view controllers magically pops up during animation (which could be noticed depending on the pop animation, or if view
        // controllers on top of it are transparent)
        HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
        if (containerContentAtCapacity) {
            [self addViewForContainerContent:containerContentAtCapacity playingTransition:NO animated:NO];
        }
        
        HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:[containerContent viewIfLoaded]];
        HLSAnimation *animation = [[HLSContainerStack transitionAnimationWithClass:containerContent.transitionClass
                                                                     appearingView:groupView.frontView
                                                                  disappearingView:groupView.backGroupView
                                                                            inView:groupView
                                                                          duration:containerContent.duration] reverseAnimation];
        animation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
        if (index == [self.containerContents count] - 1) {
            animation.tag = @"pop_animation";
            animation.lockingUI = YES;
            
            [animation playAnimated:animated];
            
            // The code then resumes in the animation end callback
        }
        else {
            [animation playAnimated:NO];
            [self.containerContents removeObject:containerContent];
        }        
    }
    else {
        [self.containerContents removeObjectAtIndex:index];
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

- (void)releaseViews
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent releaseViews];
    }
    
    self.containerView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (! self.containerView) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"No container view has been set"
                                     userInfo:nil];
    }
    
    if (m_rootViewControllerMandatory && [self.containerContents count] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                       reason:@"A root view controller is mandatory"
                                     userInfo:nil];
    }
    
    // Create the container view hierarchy with those views required according to the capacity
    for (NSUInteger i = 0; i < MIN(self.capacity, [self.containerContents count]); ++i) {
        // Never play transitions (we are building the view hierarchy). Only the top view controller receives
        // the animated information
        HLSContainerContent *containerContent = [self containerContentAtDepth:i];
        if (containerContent) {
            [self addViewForContainerContent:containerContent playingTransition:NO animated:i == 0];
        }
    }
        
    // Forward events to the top view controller
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if ([topContainerContent.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
            [self.delegate containerStack:self willShowViewController:topContainerContent.viewController animated:animated];
        }
        
        if ([self.containerViewController respondsToSelector:@selector(isMovingToParentViewController)]) {
            [topContainerContent viewWillAppear:animated movingToParentViewController:[self.containerViewController isMovingToParentViewController]];
        }
        else {
            [topContainerContent viewWillAppear:animated movingToParentViewController:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if ([topContainerContent.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        
        if ([self.containerViewController respondsToSelector:@selector(isMovingToParentViewController)]) {
            [topContainerContent viewDidAppear:animated movingToParentViewController:[self.containerViewController isMovingToParentViewController]];
        }
        else {
            [topContainerContent viewDidAppear:animated movingToParentViewController:NO];
        }
        
        if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
            [self.delegate containerStack:self didShowViewController:topContainerContent.viewController animated:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if ([topContainerContent.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
            [self.delegate containerStack:self willHideViewController:topContainerContent.viewController animated:animated];
        }
        
        if ([self.containerViewController respondsToSelector:@selector(isMovingFromParentViewController)]) {
            [topContainerContent viewWillDisappear:animated movingFromParentViewController:[self.containerViewController isMovingFromParentViewController]];
        }
        else {
            [topContainerContent viewWillDisappear:animated movingFromParentViewController:NO];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if ([topContainerContent.viewController isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        if ([self.containerViewController respondsToSelector:@selector(isMovingFromParentViewController)]) {
            [topContainerContent viewDidDisappear:animated movingFromParentViewController:[self.containerViewController isMovingFromParentViewController]];
        }
        else {
            [topContainerContent viewDidDisappear:animated movingFromParentViewController:NO];
        }
        
        if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
            [self.delegate containerStack:self didHideViewController:topContainerContent.viewController animated:animated];
        }
    }
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
    
    // Prevent rotations during animations. Can yields to erroneous animations
    if (m_animating) {
        HLSLoggerInfo(@"A transition animation is running. Rotation has been prevented");
        return NO;
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.containerContents count] != 0) {
        for (NSUInteger i = 0; i < MIN(self.capacity, [self.containerContents count]); ++i) {
            NSUInteger index = [self.containerContents count] - 1 - i;
            HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
            
            // To avoid issues when pushing - rotating - popping view controllers (which can lead to blurry views depending
            // on the animation properties, most notably when scaling is involved), we negate each animation (this is made
            // here since the frame is still the one prior to the rotation). Those will be replayed for the new orientation
            // right afterwards, when the animation, so that this trick stays invisible
            HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:[containerContent viewIfLoaded]];
            HLSAnimation *reverseAnimation = [[HLSContainerStack transitionAnimationWithClass:containerContent.transitionClass
                                                                                appearingView:groupView.frontView
                                                                             disappearingView:groupView.backGroupView
                                                                                       inView:groupView
                                                                                     duration:0.] reverseAnimation];
            [reverseAnimation playAnimated:NO];
            
            // Only view controllers potentially visible (i.e. not unloaded according to the capacity) receive rotation
            // events. This matches UINavigationController behavior, for which only the top view controller receives
            // such events
            [containerContent willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
            
            if (index == 0) {
                break;
            }
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.containerContents count] != 0) {
        for (NSUInteger i = 0; i < MIN(self.capacity, [self.containerContents count]); ++i) {
            NSUInteger index = [self.containerContents count] - 1 - i;
            HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
            
            // See comment in -willRotateToInterfaceOrientation:duration:. The container view frame is here the final one
            // obtained after the rotation completes
            HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:[containerContent viewIfLoaded]];
            HLSAnimation *animation = [HLSContainerStack transitionAnimationWithClass:containerContent.transitionClass
                                                                        appearingView:groupView.frontView
                                                                     disappearingView:groupView.backGroupView
                                                                               inView:groupView
                                                                             duration:0.];
            [animation playAnimated:NO];
            
            // Same remark as in -willRotateToInterfaceOrientation:duration:
            [containerContent willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
            
            if (index == 0) {
                break;
            }
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Same remark as above
    if ([self.containerContents count] != 0) {
        for (NSUInteger i = 0; i < MIN(self.capacity, [self.containerContents count]); ++i) {
            NSUInteger index = [self.containerContents count] - 1 - i;
            HLSContainerContent *containerContent = [self.containerContents objectAtIndex:index];
            [containerContent didRotateFromInterfaceOrientation:fromInterfaceOrientation];
            
            if (index == 0) {
                break;
            }
        }   
    }
}

// The containerContent object must already reside in containerContents. This method is namely intended to be used
// when pushing a view controller, e.g., but also when creating a hierarchy with pre-loaded or unloaded view
// controllers

/**
 * Method to add the view for a container content to the stack view hierarchy. The container content parameter is mandatory
 * and must belong to the stack
 */
- (void)addViewForContainerContent:(HLSContainerContent *)containerContent 
                 playingTransition:(BOOL)playingTransition
                          animated:(BOOL)animated
{
    NSAssert(containerContent != nil, @"A container content is mandatory");
        
    if (! [self.containerViewController isViewVisible]) {
        return;
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
                                                                atIndex:[stackView.contentViews indexOfObject:[aboveContainerContent viewIfLoaded]]];
                inserted = YES;
                break;
            }
        }
        
        if (! inserted) {
            [containerContent addAsSubviewIntoContainerStackView:stackView];
        }
        
        // Play the corresponding animation to put the view into the correct location
        HLSContainerContent *aboveContainerContent = [self.containerContents objectAtIndex:index + 1];
        HLSContainerGroupView *aboveGroupView = [[self containerStackView] groupViewForContentView:[aboveContainerContent viewIfLoaded]];
        HLSAnimation *aboveAnimation = [HLSContainerStack transitionAnimationWithClass:aboveContainerContent.transitionClass
                                                                         appearingView:nil      /* only play the animation for the view we added */
                                                                      disappearingView:aboveGroupView.backGroupView
                                                                                inView:aboveGroupView
                                                                              duration:aboveContainerContent.duration];
        aboveAnimation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
        [aboveAnimation playAnimated:NO];
    }
    
    // Play the corresponding animation so that the view controllers are brought into correct positions
    HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:[containerContent viewIfLoaded]];
    HLSAnimation *animation = [HLSContainerStack transitionAnimationWithClass:containerContent.transitionClass
                                                                appearingView:groupView.frontView
                                                             disappearingView:groupView.backGroupView
                                                                       inView:groupView
                                                                     duration:containerContent.duration];
    animation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
    if (playingTransition && index == [self.containerContents count] - 1) {
        animation.tag = @"push_animation";
        animation.lockingUI = YES;
        
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
    if (animated) {
        m_animating = YES;
    }
    
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
                
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
            [self.delegate containerStack:self willHideViewController:disappearingContainerContent.viewController animated:animated];
        }
        [disappearingContainerContent viewWillDisappear:animated movingFromParentViewController:YES];
        
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
            [self.delegate containerStack:self willShowViewController:appearingContainerContent.viewController animated:animated];
        }
        [appearingContainerContent viewWillAppear:animated movingToParentViewController:YES];
    }    
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (animated) {
        m_animating = NO;
    }
    
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
        
        [disappearingContainerContent viewDidDisappear:animated movingFromParentViewController:YES];
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
            [self.delegate containerStack:self didHideViewController:disappearingContainerContent.viewController animated:animated];
        }
                
        [appearingContainerContent viewDidAppear:animated movingToParentViewController:YES];
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
            [self.delegate containerStack:self didShowViewController:appearingContainerContent.viewController animated:animated];
        }
        
        // Keep the disappearing view controller alive a little bit longer
        UIViewController *disappearingViewController = [disappearingContainerContent.viewController retain];
        
        if ([animation.tag isEqualToString:@"push_animation"]) {
            // Now that the animation is over, get rid of the view or view controller which does not match the capacity criterium
            HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
            if (! m_removing) {
                [containerContentAtCapacity releaseViews];
            }
            else {
                [self.containerContents removeObject:containerContentAtCapacity];
            }
            
            if ([self.delegate respondsToSelector:@selector(containerStack:didPushViewController:coverViewController:animated:)]) {
                [self.delegate containerStack:self
                        didPushViewController:appearingContainerContent.viewController
                          coverViewController:disappearingViewController
                                     animated:animated];
            }
        }
        else if ([animation.tag isEqualToString:@"pop_animation"]) {
            
            [self.containerContents removeObject:disappearingContainerContent];
            
            if ([self.delegate respondsToSelector:@selector(containerStack:didPopViewController:revealViewController:animated:)]) {
                [self.delegate containerStack:self
                         didPopViewController:disappearingViewController
                         revealViewController:appearingContainerContent.viewController
                                     animated:animated];
            }
        }
    
        [disappearingViewController release];
    }    
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; containerViewController: %@; containerContents: %@; containerView: %@>",
            [self class],
            self,
            self.containerViewController,
            self.containerContents,
            self.containerView];
}

@end

@implementation UIViewController (HLSContainerStack)

- (id)containerViewControllerKindOfClass:(Class)containerViewControllerClass
{
    return [HLSContainerContent containerViewControllerKindOfClass:containerViewControllerClass
                                                 forViewController:self];
}

@end
