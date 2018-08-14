//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSContainerStack.h"

#import "HLSContainerContent.h"
#import "HLSContainerStackView.h"
#import "HLSLayerAnimationStep.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

// Constants
const NSUInteger HLSContainerStackMinimalCapacity = 1;
const NSUInteger HLSContainerStackDefaultCapacity = 2;
const NSUInteger HLSContainerStackUnlimitedCapacity = NSUIntegerMax;

static NSString * const HLSContainerStackPushAnimationName = @"push_animation";
static NSString * const HLSContainerStackPopAnimationName = @"pop_animation";

@interface HLSContainerStack () <HLSContainerStackViewDelegate>

@property (nonatomic, weak) UIViewController *containerViewController;                  // The container view controller implemented using HLSContainerStack
@property (nonatomic) NSMutableArray<HLSContainerContent *> *containerContents;         // The contents loaded into the stack. The first element corresponds to the root view controller
@property (nonatomic) NSUInteger capacity;                                              // The maximum number of top view controllers loaded / not removed at any time

@end

@implementation HLSContainerStack {
@private
    HLSContainerStackBehavior _behavior;                      // How the container manages its child view controllers
    BOOL _animating;                                          // Set to YES when a transition animation is running
    HLSAutorotationMode _autorotationMode;                    // How the container decides to behave when rotation occurs
    BOOL _topContainerContentMovingToParent;                  // Share information between -viewWillAppear: and -viewDidAppear: calls
}

#pragma mark Class methods

+ (instancetype)singleControllerContainerStackWithContainerViewController:(UIViewController *)containerViewController
{
    return [[[self class] alloc] initWithContainerViewController:containerViewController
                                                        behavior:HLSContainerStackBehaviorRemoving
                                                        capacity:HLSContainerStackMinimalCapacity];
}

#pragma mark Object creation and destruction

- (instancetype)initWithContainerViewController:(UIViewController *)containerViewController
                                       behavior:(HLSContainerStackBehavior)behavior
                                       capacity:(NSUInteger)capacity
{
    NSParameterAssert(containerViewController);
    
    if (self = [super init]) {
        self.containerViewController = containerViewController;
        self.containerContents = [NSMutableArray array];
        _behavior = behavior;
        self.capacity = capacity;
        self.lockingUI = YES;
        _autorotationMode = HLSAutorotationModeContainer;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma clang diagnostic pop

- (void)dealloc
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent.viewController willMoveToParentViewController:nil];
    }
}

#pragma mark Accessors and mutators

- (void)setContainerView:(UIView *)containerView
{
    if (_containerView == containerView) {
        return;
    }
    
    if (containerView) {
        if (! [self.containerViewController isViewLoaded]) {
            HLSLoggerError(@"Cannot set a container view when the container view controller's view has not been loaded");
            return;
        }
        
        if (! [containerView isDescendantOfView:self.containerViewController.view]) {
            HLSLoggerError(@"The container view must be part of the container view controller's view hiearchy");
            return;
        }
        
        // All animations must take place inside the view controller's view
        containerView.clipsToBounds = YES;
        
        // Create the container base view maintaining the whole container view hiearchy
        HLSContainerStackView *containerStackView = [[HLSContainerStackView alloc] initWithFrame:containerView.bounds];
        containerStackView.delegate = self;
        [containerView addSubview:containerStackView];
    }
    
    _containerView = containerView;
}

- (HLSContainerStackView *)containerStackView
{
    return self.containerView.subviews.firstObject;
}

- (void)setCapacity:(NSUInteger)capacity
{
    if (capacity < HLSContainerStackMinimalCapacity) {
        capacity = HLSContainerStackMinimalCapacity;
        HLSLoggerWarn(@"The capacity cannot be smaller than %@; set to this value", @(HLSContainerStackMinimalCapacity));
    }
    
    _capacity = capacity;
}

- (HLSContainerContent *)topContainerContent
{
    return self.containerContents.lastObject;
}

- (HLSContainerContent *)secondTopContainerContent
{
    if (self.containerContents.count < 2) {
        return nil;
    }
    return self.containerContents[self.containerContents.count - 2];
}

- (UIViewController *)rootViewController
{
    HLSContainerContent *rootContainerContent = self.containerContents.firstObject;
    return rootContainerContent.viewController;
}

- (UIViewController *)topViewController
{
    HLSContainerContent *topContainerContent = [self topContainerContent];
    return topContainerContent.viewController;
}

- (NSArray<UIViewController *> *)viewControllers
{
    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];
    for (HLSContainerContent *containerContent in self.containerContents) {
        [viewControllers addObject:containerContent.viewController];
    }
    return [viewControllers copy];
}

- (NSUInteger)count
{
    return self.containerContents.count;
}

- (HLSContainerContent *)containerContentAtDepth:(NSUInteger)depth
{
    if (self.containerContents.count > depth) {
        return self.containerContents[self.containerContents.count - depth - 1];
    }
    else {
        return nil;
    }
}

#pragma mark Adding and removing view controllers

- (void)pushViewController:(UIViewController *)viewController
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated
{
    [self insertViewController:viewController
                       atIndex:self.containerContents.count
           withTransitionClass:transitionClass
                      duration:duration
                      animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self removeViewControllerAtIndex:self.containerContents.count - 1 animated:animated];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController) {
        NSUInteger index = [self.viewControllers indexOfObject:viewController];
        if (index == NSNotFound) {
            HLSLoggerWarn(@"The view controller to pop to does not belong to the container");
            return;
        }
        else if (index == self.containerContents.count - 1) {
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
    if (self.containerContents.count == 0) {
        HLSLoggerInfo(@"Nothing to pop: The view controller container is empty");
        return;
    }
    
    // Pop to a valid index
    NSUInteger firstRemovedIndex = 0;
    if (index != NSUIntegerMax) {
        // Remove in the middle
        if (index < self.containerContents.count - 1) {
            firstRemovedIndex = index + 1;
        }
        // Nothing to do if we pop to the current top view controller
        else if (index == self.containerContents.count - 1) {
            HLSLoggerInfo(@"Nothing to pop: The view controller displayed is already the one you try to pop to");
            return;            
        }
        else {
            HLSLoggerError(@"Invalid index %@. Expected in [0;%@]", @(index), @(self.containerContents.count - 2));
            return;
        }
    }
    // Pop everything
    else {
        if (_behavior == HLSContainerStackBehaviorFixedRoot) {
            HLSLoggerWarn(@"The root view controller is fixed. Cannot pop everything");
            return;
        }
        
        firstRemovedIndex = 0;
    }
    
    // Remove the view controllers until the one we want to pop to (except the topmost one, for which we will play
    // the pop animation if desired)
    NSUInteger i = self.containerContents.count - firstRemovedIndex - 1;
    while (i > 0) {
        // We must call -willMoveToParentViewController: manually right before the containment relationship is removed
        HLSContainerContent *containerContent = self.containerContents[firstRemovedIndex];
        [containerContent.viewController willMoveToParentViewController:nil];
        
        [self.containerContents removeObjectAtIndex:firstRemovedIndex];
        --i;
    }
    
    // Resurrect view controller's views below the view controller we pop to so that the capacity criterium
    // is satisfied
    if (firstRemovedIndex != 0) {
        for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
            NSUInteger index = firstRemovedIndex - 1 - i;
            HLSContainerContent *containerContent = self.containerContents[index];
            [self addViewForContainerContent:containerContent inserting:NO animated:NO];
            
            if (index == 0) {
                break;
            }
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
    NSParameterAssert(viewController);
    
    if (index > self.containerContents.count) {
        HLSLoggerError(@"Invalid index %@. Expected in [0;%@]", @(index), @(self.containerContents.count));
        return;
    }
    
    if (_animating) {
        HLSLoggerWarn(@"Cannot insert a view controller while a transition animation is running");
        return;
    }
    
    if (index == 0) {
        if (_behavior == HLSContainerStackBehaviorFixedRoot && index == 0 && self.rootViewController) {
            HLSLoggerError(@"The root view controller is fixed and cannot be changed anymore once set or after the container "
                           "has been displayed once");
            return;
        }
        else if (_behavior == HLSContainerStackBehaviorRemoving && self.containerContents.count == self.capacity) {
            HLSLoggerError(@"No view controller can be inserted at index 0 since the container is already full and would remove it");
            return;
        }
    }
        
    if (self.containerViewController.viewDisplayed) {
        // Notify the delegate before the view controller is actually installed on top of the stack and associated with the
        // container (see HLSContainerStackDelegate interface contract)
        if (index == self.containerContents.count) {
            if ([self.delegate respondsToSelector:@selector(containerStack:willPushViewController:coverViewController:animated:)]) {
                [self.delegate containerStack:self
                       willPushViewController:viewController
                          coverViewController:self.topViewController
                                     animated:animated];
            }
        }
    }
    
    // If the container removes view controllers and has reached its capacity, inform the bottommost view controller that it
    // will get removed
    if (_behavior == HLSContainerStackBehaviorRemoving && self.containerContents.count == self.capacity) {
        // We must call -willMoveToParentViewController: manually right before the containment relationship is removed
        [self.rootViewController willMoveToParentViewController:nil];
    }
    
    // Associate the new view controller with its container (this increases container.count)
    HLSContainerContent *containerContent = [[HLSContainerContent alloc] initWithViewController:viewController
                                                                        containerViewController:self.containerViewController
                                                                                transitionClass:transitionClass
                                                                                       duration:duration];
    if (! containerContent) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The view controller could not be inserted into the container"
                                     userInfo:nil];
    }
    
    [self.containerContents insertObject:containerContent atIndex:index];

    // If no transition occurs (pre-loading before the container view is displayed, or insertion not at the top while
    // displayed), we must call -didMoveToParentViewController: manually right after the containment relationship has
    // been established
    if (! self.containerViewController.viewDisplayed
            || (index == self.containerContents.count - 1 && ! animated)) {
        [viewController didMoveToParentViewController:self.containerViewController];
    }
    
    // If inserted in the capacity range, must add the view
    if (self.containerViewController.viewDisplayed) {
        // A correction needs to be applied here to account for the container.count increase (since index was relative
        // to the previous value)
        if (self.containerContents.count - index - 1 <= self.capacity) {
            [self addViewForContainerContent:containerContent inserting:YES animated:animated];
        }
    }
}

- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
{
    NSParameterAssert(viewController);
    NSParameterAssert(siblingViewController);
    
    NSUInteger index = [self.viewControllers indexOfObject:siblingViewController];
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
    NSUInteger index = [self.viewControllers indexOfObject:siblingViewController];
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
    if (index >= self.containerContents.count) {
        HLSLoggerError(@"Invalid index %@. Expected in [0;%@]", @(index), @(self.containerContents.count - 1));
        return;
    }
    
    if (_animating) {
        HLSLoggerWarn(@"Cannot remove a view controller while a transition animation is running");
        return;
    }
    
    if (_behavior == HLSContainerStackBehaviorFixedRoot && index == 0 && self.rootViewController) {
        HLSLoggerWarn(@"The root view controller is fixed and cannot be removed once set or after the container has been "
                      "displayed once");
        return;
    }
    
    if (self.containerViewController.viewDisplayed) {
        // Notify the delegate
        if (index == self.containerContents.count - 1) {
            if ([self.delegate respondsToSelector:@selector(containerStack:willPopViewController:revealViewController:animated:)]) {
                [self.delegate containerStack:self
                        willPopViewController:self.topViewController
                         revealViewController:self.secondTopContainerContent.viewController
                                     animated:animated];
            }
        }
    }
    
    HLSContainerContent *containerContent = self.containerContents[index];
    
    // We must call -willMoveToParentViewController: manually right before the containment relationship is removed
    [containerContent.viewController willMoveToParentViewController:nil];
    
    if (containerContent.addedToContainerView) {
        // Load the view controller's view below so that the capacity criterium can be fulfilled (if needed). If we are popping a
        // view controller, we will have capacity + 1 view controller's views loaded during the animation. This ensures that no
        // view controllers magically pops up during animation (which could be noticed depending on the pop animation, or if view
        // controllers on top of it are transparent)
        HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
        if (containerContentAtCapacity) {
            [self addViewForContainerContent:containerContentAtCapacity inserting:NO animated:NO];
        }
        
        HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:containerContent.viewIfLoaded];
        
        HLSAnimation *reverseAnimation = [containerContent.transitionClass reverseAnimationWithAppearingView:groupView.backView
                                                                                            disappearingView:groupView.frontView
                                                                                                      inView:groupView
                                                                                                    duration:containerContent.duration];
        reverseAnimation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
        if (index == self.containerContents.count - 1) {
            // Some more work has to be done for pop animations in the animation begin / end callbacks. To identify such animations,
            // we give them a tag which we can test in those callbacks
            //
            // Same remark as in -addViewForContainerContent:inserting:animated: regarding animations in nested containers
            reverseAnimation.tag = HLSContainerStackPopAnimationName;
            reverseAnimation.lockingUI = self.lockingUI;
            [reverseAnimation playAnimated:animated];
            
            // Check the animation callback implementations for what happens next
        }
        else {
            [reverseAnimation playAnimated:NO];
            [self.containerContents removeObject:containerContent];
        }        
    }
    else {
        [self.containerContents removeObjectAtIndex:index];
    }
}

- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSParameterAssert(viewController);
    
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The view controller to remove does not belong to the container");
        return;
    }
    [self removeViewControllerAtIndex:index animated:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (! self.containerView) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"No container view has been set"
                                     userInfo:nil];
    }
    
    if (_behavior == HLSContainerStackBehaviorFixedRoot && self.containerContents.count == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"The root view controller is fixed but has not been defined when displaying the container"
                                     userInfo:nil];
    }
    
    // If the top container view has not been added to the container yet (i.e. not being revealed), the corresponding view
    // controller must return YES when calling -isMovingToParentViewController. Save this information for later use in
    // -viewDidAppear: implementation
    HLSContainerContent *topContainerContent = [self topContainerContent];
    _topContainerContentMovingToParent = ! topContainerContent.addedToContainerView;
    
    // Create the container view hierarchy with those views required according to the capacity
    for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
        // Never play transitions (we are building the view hierarchy). Only the top view controller receives the animated
        // information
        HLSContainerContent *containerContent = [self containerContentAtDepth:i];
        if (containerContent) {
            [self addViewForContainerContent:containerContent inserting:NO animated:animated];
        }
    }
        
    // Forward events (willShow is sent to the delegate before willAppear is sent to the child)
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
        [self.delegate containerStack:self willShowViewController:topContainerContent.viewController animated:animated];
    }
    
    [topContainerContent viewWillAppear:animated movingToParentViewController:_topContainerContentMovingToParent];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Forward events (didAppear is sent to the child before didShow is sent to the delegate)
    HLSContainerContent *topContainerContent = [self topContainerContent];
    [topContainerContent viewDidAppear:animated movingToParentViewController:_topContainerContentMovingToParent];
    
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
        [self.delegate containerStack:self didShowViewController:topContainerContent.viewController animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Forward events (willHide is sent to the delegate before willDisappear is sent to the child)
    HLSContainerContent *topContainerContent = [self topContainerContent];
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
        [self.delegate containerStack:self willHideViewController:topContainerContent.viewController animated:animated];
    }
    
    [topContainerContent viewWillDisappear:animated movingFromParentViewController:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Forward events (didDisappear is sent to the child before didHide is sent to the delegate)
    HLSContainerContent *topContainerContent = [self topContainerContent];
    [topContainerContent viewDidDisappear:animated movingFromParentViewController:NO];
    
    if (topContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
        [self.delegate containerStack:self didHideViewController:topContainerContent.viewController animated:animated];
    }
}

- (BOOL)shouldAutorotate
{
    // Prevent rotations during animations. Can lead to erroneous animations
    if (_animating) {
        HLSLoggerInfo(@"A transition animation is running. Rotation has been prevented");
        return NO;
    }
    
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (HLSContainerContent *containerContent in [self.containerContents reverseObjectEnumerator]) {
                if (! [containerContent shouldAutorotate]) {
                    return NO;
                }
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            HLSContainerContent *topContainerContent = [self topContainerContent];
            if (topContainerContent && ! [topContainerContent shouldAutorotate]) {
                return NO;
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndNoChildren: {
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
                NSUInteger index = self.containerContents.count - 1 - i;
                HLSContainerContent *containerContent = self.containerContents[index];
                if (! [containerContent shouldAutorotate]) {
                    return NO;
                }
            }
            break;
        }
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    switch (self.autorotationMode) {
        case HLSAutorotationModeContainerAndAllChildren: {
            for (HLSContainerContent *containerContent in [self.containerContents reverseObjectEnumerator]) {
                supportedInterfaceOrientations &= [containerContent supportedInterfaceOrientations];
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndTopChildren: {
            HLSContainerContent *topContainerContent = [self topContainerContent];
            if (topContainerContent) {
                supportedInterfaceOrientations &= [topContainerContent supportedInterfaceOrientations];
            }
            break;
        }
            
        case HLSAutorotationModeContainerAndNoChildren: {
            break;
        }
            
        case HLSAutorotationModeContainer:
        default: {
            for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
                NSUInteger index = self.containerContents.count - 1 - i;
                HLSContainerContent *containerContent = self.containerContents[index];
                supportedInterfaceOrientations &= [containerContent supportedInterfaceOrientations];
            }
            break;
        }
    }
    
    return supportedInterfaceOrientations;
}

// Use UIViewController default values for status bar behavior methods
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.topViewController ? self.topViewController.preferredStatusBarStyle : UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return self.topViewController ? self.topViewController.prefersStatusBarHidden : NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.topViewController ? self.topViewController.preferredStatusBarUpdateAnimation : UIStatusBarAnimationFade;
}

/**
 * Method to add the view for a container content to the stack view hierarchy. The container content parameter is mandatory
 * and must be part of the stack. If the view is added because the container content is being inserted into the container,
 * set inserting to YES, otherwise to NO
 */
- (void)addViewForContainerContent:(HLSContainerContent *)containerContent
                         inserting:(BOOL)inserting
                          animated:(BOOL)animated
{
    NSAssert(containerContent != nil, @"A container content is mandatory");
        
    if (! self.containerViewController.viewDisplayed) {
        return;
    }
        
    if (containerContent.addedToContainerView) {
        return;
    }
    
    NSUInteger index = [self.containerContents indexOfObject:containerContent];
    NSAssert(index != NSNotFound, @"Content not found in the stack");
    
    HLSContainerStackView *stackView = [self containerStackView];
    
    // Last element? Add to top
    if (index == self.containerContents.count - 1) {
        [containerContent addAsSubviewIntoContainerStackView:stackView];
    }
    // Otherwise add below first content above for which a view is available (most probably the nearest neighbor above)
    else {
        // Find which container view above is available. We will insert the new one right below it (usually,
        // this is the one at index + 1, but this might not be the case if we are resurrecting a view controller
        // deep in the stack)
        BOOL inserted = NO;
        for (NSUInteger i = index + 1; i < self.containerContents.count; ++i) {
            HLSContainerContent *aboveContainerContent = self.containerContents[i];
            if (aboveContainerContent.addedToContainerView) {
                [containerContent insertAsSubviewIntoContainerStackView:stackView
                                                                atIndex:[stackView.contentViews indexOfObject:aboveContainerContent.viewIfLoaded]];
                inserted = YES;
                break;
            }
        }
        
        if (! inserted) {
            [containerContent addAsSubviewIntoContainerStackView:stackView];
        }
        
        // Play the corresponding animation to put the view into the correct location
        HLSContainerContent *aboveContainerContent = self.containerContents[index + 1];
        HLSContainerGroupView *aboveGroupView = [[self containerStackView] groupViewForContentView:aboveContainerContent.viewIfLoaded];
        HLSAnimation *aboveAnimation = [aboveContainerContent.transitionClass animationWithAppearingView:nil      /* only play the animation for the view we added */
                                                                                        disappearingView:aboveGroupView.backView
                                                                                                  inView:aboveGroupView
                                                                                                duration:aboveContainerContent.duration];
        aboveAnimation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
        [aboveAnimation playAnimated:NO];
    }
    
    // Play the corresponding animation so that the view controllers are brought into correct positions
    HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:containerContent.viewIfLoaded];
    HLSAnimation *animation = [containerContent.transitionClass animationWithAppearingView:groupView.frontView
                                                                          disappearingView:groupView.backView
                                                                                    inView:groupView
                                                                                  duration:containerContent.duration];
    animation.delegate = self;          // always set a delegate so that the animation is destroyed if the container gets deallocated
    
    // Pushing a view controller onto the stack. Note that the transition can only be animated for the top view controller.
    // Even if the container view controller's view is not currently visible, the transition can still be animated. This is
    // made to allow transition animations to occur in nested containers (e.g. you may want to animate transitions in an
    // HLSPlaceholderViewController nested in an HLSStackController so that, if the placeholder view controller is covered
    // with a transparent view controller, transitions can still be seen underneath)
    if (inserting && index == self.containerContents.count - 1) {
        // Some more work has to be done for push animations in the animation begin / end callbacks. To identify such animations,
        // we give them a tag which we can test in those callbacks
        animation.tag = HLSContainerStackPushAnimationName;
        animation.lockingUI = self.lockingUI;
        [animation playAnimated:animated];
        
        // Check the animation callback implementations for what happens next
    }
    // All other cases (inserting in the middle or instantiating the view for a view controller already in the stack)
    else {
        [animation playAnimated:NO];
    }
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    _animating = YES;
    
    // Extra work needed for push and pop animations
    if ([animation.tag isEqualToString:HLSContainerStackPushAnimationName] || [animation.tag isEqualToString:HLSContainerStackPopAnimationName]) {
        // FIXME: Should be correctly animated for animated status bar changes
        [self.containerViewController setNeedsStatusBarAppearanceUpdate];
        
        HLSContainerContent *appearingContainerContent = nil;
        HLSContainerContent *disappearingContainerContent = nil;
        
        if ([animation.tag isEqualToString:HLSContainerStackPushAnimationName]) {
            appearingContainerContent = [self topContainerContent];
            disappearingContainerContent = [self secondTopContainerContent];        
        }
        else {
            appearingContainerContent = [self secondTopContainerContent];
            disappearingContainerContent = [self topContainerContent];
        }
        
        // Forward events (willHide is sent to the delegate before willDisappear is sent to the view controller)
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willHideViewController:animated:)]) {
            [self.delegate containerStack:self willHideViewController:disappearingContainerContent.viewController animated:animated];
        }
        
        // Containment relationship removal in general occurs during pop animations, but can also happen when a push forces a destructive
        // container with capacity = 1 to remove the disappearing view controller
        BOOL movingFromParentViewController = [animation.tag isEqualToString:HLSContainerStackPopAnimationName]
            || (_behavior == HLSContainerStackBehaviorRemoving && self.capacity == 1 && self.containerContents.count == 2);
        [disappearingContainerContent viewWillDisappear:animated movingFromParentViewController:movingFromParentViewController];
        
        // Forward events (willShow is sent to the delegate before willAppear is sent to the view controller)
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:willShowViewController:animated:)]) {
            [self.delegate containerStack:self willShowViewController:appearingContainerContent.viewController animated:animated];
        }
        [appearingContainerContent viewWillAppear:animated movingToParentViewController:[animation.tag isEqualToString:HLSContainerStackPushAnimationName]];
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    _animating = NO;
    
    // Extra work needed for push and pop animations
    if ([animation.tag isEqualToString:HLSContainerStackPushAnimationName] || [animation.tag isEqualToString:HLSContainerStackPopAnimationName]) {
        HLSContainerContent *appearingContainerContent = nil;
        HLSContainerContent *disappearingContainerContent = nil;
        
        if ([animation.tag isEqualToString:HLSContainerStackPushAnimationName]) {
            appearingContainerContent = [self topContainerContent];
            disappearingContainerContent = [self secondTopContainerContent];
        }
        else {
            appearingContainerContent = [self secondTopContainerContent];
            disappearingContainerContent = [self topContainerContent];
        }
        
        // Forward events (didDisappear is sent to the view controller before didHide is sent to the delegate). For an explanation of
        // movingFromParentViewController value, see -animationWillStart:animated:
        BOOL movingFromParentViewController = [animation.tag isEqualToString:HLSContainerStackPopAnimationName]
            || (_behavior == HLSContainerStackBehaviorRemoving && self.capacity == 1 && self.containerContents.count == 2);
        [disappearingContainerContent viewDidDisappear:animated movingFromParentViewController:movingFromParentViewController];
        if (disappearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didHideViewController:animated:)]) {
            [self.delegate containerStack:self didHideViewController:disappearingContainerContent.viewController animated:animated];
        }
         
        // Forward events (didAppear is sent to the view controller before didShow is sent to the delegate)
        [appearingContainerContent viewDidAppear:animated movingToParentViewController:[animation.tag isEqualToString:HLSContainerStackPushAnimationName]];
        if (appearingContainerContent && [self.delegate respondsToSelector:@selector(containerStack:didShowViewController:animated:)]) {
            [self.delegate containerStack:self didShowViewController:appearingContainerContent.viewController animated:animated];
        }
        
        // Keep the disappearing view controller alive a little bit longer
        UIViewController *disappearingViewController = disappearingContainerContent.viewController;
        UIViewController *appearingViewController = appearingContainerContent.viewController;
        
        if ([animation.tag isEqualToString:HLSContainerStackPushAnimationName]) {
            // Now that the animation is over, get rid of the view or view controller which does not match the capacity criterium
            HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
            if (_behavior == HLSContainerStackBehaviorRemoving) {
                [self.containerContents removeObject:containerContentAtCapacity];
            }
            else {
                // The view is only removed from the view hierarchy, so that blending can be made faster. The view is NOT unloaded
                [containerContentAtCapacity removeViewFromContainerStackView];
            }
                        
            // -didMoveToParentViewController: must be called manually after the push transition has been performed (see
            // UIViewController documentation)
            [appearingViewController didMoveToParentViewController:self.containerViewController];
            
            // Notify the delegate
            if ([self.delegate respondsToSelector:@selector(containerStack:didPushViewController:coverViewController:animated:)]) {
                [self.delegate containerStack:self
                        didPushViewController:appearingViewController
                          coverViewController:disappearingViewController
                                     animated:animated];
            }
        }
        else if ([animation.tag isEqualToString:HLSContainerStackPopAnimationName]) {
            [self.containerContents removeObject:disappearingContainerContent];
            
            // Notify the delegate after the view controller has been removed from the stack and the parent-child containment relationship
            // has been broken (see HLSContainerStackDelegate interface contract)
            if ([self.delegate respondsToSelector:@selector(containerStack:didPopViewController:revealViewController:animated:)]) {
                [self.delegate containerStack:self
                         didPopViewController:disappearingViewController
                         revealViewController:appearingContainerContent.viewController
                                     animated:animated];
            }
        }
    }
    // Insertions: Ensure that view controllers are removed according to the container capacity (if this behavior has been set)
    else if (_behavior == HLSContainerStackBehaviorRemoving) {
        HLSContainerContent *containerContentAtCapacity = [self containerContentAtDepth:self.capacity];
        [self.containerContents removeObject:containerContentAtCapacity];
    }
}

#pragma mark HLSContainerStackViewDelegate protocol implementation

- (void)containerStackViewWillChangeFrame:(HLSContainerStackView *)containerStackView
{
    // Children are pushed with layer animations (i.e. transform animations). Those do not play well wit frame changes.
    // To solve those issues, we reset the children views to their initial state before the frame is changed (the
    // previous state is then restored after the frame has changed, see below)
    for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
        NSUInteger index = self.containerContents.count - 1 - i;
        HLSContainerContent *containerContent = self.containerContents[index];
        
        if (containerContent.viewIfLoaded) {
            HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:containerContent.viewIfLoaded];
            if (! groupView) {
                continue;
            }
            
            HLSAnimation *reverseAnimation = [containerContent.transitionClass animationWithAppearingView:groupView.frontView
                                                                                         disappearingView:groupView.backView
                                                                                                   inView:groupView
                                                                                                 duration:0.].reverseAnimation;
            [reverseAnimation playAnimated:NO];
        }
    }
}

- (void)containerStackViewDidChangeFrame:(HLSContainerStackView *)containerStackView
{
    // See comment in -containerStackViewWillChangeFrame:
    for (NSUInteger i = 0; i < MIN(self.capacity, self.containerContents.count); ++i) {
        NSUInteger index = self.containerContents.count - 1 - i;
        HLSContainerContent *containerContent = self.containerContents[index];
        
        if (containerContent.viewIfLoaded) {
            HLSContainerGroupView *groupView = [[self containerStackView] groupViewForContentView:containerContent.viewIfLoaded];
            if (! groupView) {
                continue;
            }
            
            HLSAnimation *animation = [containerContent.transitionClass animationWithAppearingView:groupView.frontView
                                                                                  disappearingView:groupView.backView
                                                                                            inView:groupView
                                                                                          duration:0.];
            [animation playAnimated:NO];
        }
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
