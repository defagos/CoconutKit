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
#import "HLSOrientationCloner.h"
#import "NSArray+HLSExtensions.h"

// TODO: When pushing a view controller, insert an invisible view just below it for preventing
//       user interaction with the views below in the stack.

static void *HLSStackControllerKey = &HLSStackControllerKey;

@interface HLSStackController ()

// TODO: Could be replaced by a dictionary pointing at an object encapsulating this information. Lookup would be better.
//       But this should not be a bottleneck
@property (nonatomic, retain) NSMutableArray *viewControllerStack;
@property (nonatomic, retain) NSMutableArray *addedAsSubviewFlagStack;
@property (nonatomic, retain) NSMutableArray *twoViewAnimationStepDefinitionsStack;
@property (nonatomic, retain) NSMutableArray *originalViewFrameStack;

- (UIViewController *)secondTopViewController;

- (void)registerViewController:(UIViewController *)viewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions;
- (void)unregisterViewController:(UIViewController *)viewController;

- (void)pushViewForViewController:(UIViewController *)viewController;
- (void)removeViewForViewController:(UIViewController *)viewController;

- (BOOL)addedAsSubviewFlagForViewController:(UIViewController *)viewController;
- (NSArray *)twoViewAnimationStepDefinitionsForViewController:(UIViewController *)viewController;
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
        self.twoViewAnimationStepDefinitionsStack = [NSMutableArray array];
        self.originalViewFrameStack = [NSMutableArray array];
        
        [self registerViewController:rootViewController withTwoViewAnimationStepDefinitions:nil];
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
    self.twoViewAnimationStepDefinitionsStack = nil;
    self.originalViewFrameStack = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewControllerStack = m_viewControllerStack;

@synthesize addedAsSubviewFlagStack = m_addedAsSubviewFlagStack;

@synthesize twoViewAnimationStepDefinitionsStack = m_twoViewAnimationStepDefinitionsStack;

@synthesize originalViewFrameStack = m_originalViewFrameStack;

@synthesize stretchingContent = m_stretchingContent;

- (void)setStretchingContent:(BOOL)stretchingContent
{
    if (m_stretchingContent == stretchingContent) {
        return;
    }
    
    m_stretchingContent = stretchingContent;
    
    if ([self isViewVisible]) {
        for (UIViewController *viewController in self.viewControllerStack) {
            if ([self addedAsSubviewFlagForViewController:viewController]) {
                if (m_stretchingContent) {
                    viewController.view.frame = self.view.bounds;
                }
                else {
                    viewController.view.frame = [self originalViewFrameForViewController:viewController];
                }            
            }
        }        
    }
}

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
    
    // If one view controller in the stack does not support the orientation, neither will the container
    for (UIViewController *viewController in self.viewControllerStack) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
            && ! [viewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // TODO: Not trivial. Since transparency can occur, we must rotate all view controllers. This means we might need
    //       to rebuild the whole stack if some (or all!) view controllers support rotation by cloning. In HLSPlaceholderViewController,
    //       we could reuse the setter to achieve this elegantly. Here we might be able to do the same, but this is more difficult
    //       (and probably expensive). The easiest solution would be that all view controllers deal with their rotation
    //       themselves, but is this possible? In such cases, containers would not need to change the view controllers
    //       (since they stay the same), the view controller itself would update its view. But I don't think this is
    //       feasible...
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // TODO:
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // TODO:
}

#pragma mark Pushing view controllers onto the stack

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:nil];
}

- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    // Cannot use self.view.frame here! Would trigger lazy creation, but pushViewController:withTransitionStyle: must also be callable before
    // the view is actually created!
    CGRect viewFrame = [UIScreen mainScreen].applicationFrame;
    NSArray *twoViewAnimationStepDefinitions = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle 
                                                                                                                   disappearingView:[self topViewController].view
                                                                                                                      appearingView:viewController.view
                                                                                                                      inCommonFrame:viewFrame];
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:twoViewAnimationStepDefinitions];    
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    // Cannot use self.view.frame here! Would trigger lazy creation, but pushViewController:withTransitionStyle: must also be callable before
    // the view is actually created!
    CGRect viewFrame = [UIScreen mainScreen].applicationFrame;
    NSArray *twoViewAnimationStepDefinitions = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle 
                                                                                                                   disappearingView:[self topViewController].view
                                                                                                                      appearingView:viewController.view
                                                                                                                      inCommonFrame:viewFrame
                                                                                                                           duration:duration];
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:twoViewAnimationStepDefinitions];    
}

- (void)pushViewController:(UIViewController *)viewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
{
    HLSAssertObjectsInEnumerationAreKindOfClass(twoViewAnimationStepDefinitions, HLSTwoViewAnimationStepDefinition);
    NSAssert(viewController != nil, @"Cannot push nil");
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if ([self isViewVisible]) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
            HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
            return;
        }
    }
    
    // Associate the view controller with its container
    [self registerViewController:viewController withTwoViewAnimationStepDefinitions:twoViewAnimationStepDefinitions];
    
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
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
{
    // Associate the view controller with its container
    NSAssert(! objc_getAssociatedObject(viewController, HLSStackControllerKey), @"A view controller can only be inserted into one stack controller");
    objc_setAssociatedObject(viewController, HLSStackControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    // Add the new view controller
    [self.viewControllerStack addObject:viewController];
    [self.addedAsSubviewFlagStack addObject:[NSNumber numberWithBool:NO]];
    if ([twoViewAnimationStepDefinitions count] != 0) {
        [self.twoViewAnimationStepDefinitionsStack addObject:twoViewAnimationStepDefinitions];
    }
    else {
        [self.twoViewAnimationStepDefinitionsStack addObject:[NSArray array]];
    }
    // Put a placeholder. Will be filled when displaying the view (we do not want to access the view property too early since this triggers
    // lazy view creation)
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
    [self.twoViewAnimationStepDefinitionsStack removeObjectAtIndex:index];
    [self.originalViewFrameStack removeObjectAtIndex:index];
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
    
    // Now that the view has not been unnecessarily created, save its original frame
    [self.originalViewFrameStack replaceObjectAtIndex:index
                                           withObject:[NSValue valueWithCGRect:viewController.view.frame]];
    
    // Adjust size if enabled
    if (self.stretchingContent) {
        viewController.view.frame = self.view.bounds;
    }
    
    // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
    // expect it to occur animated, even if instantaneously. The root view controller is never pushed
    if (index != 0) {
        HLSAnimation *pushAnimation = [self pushAnimationForViewController:viewController];
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
    [self.originalViewFrameStack replaceObjectAtIndex:index
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

- (NSArray *)twoViewAnimationStepDefinitionsForViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllerStack indexOfObject:viewController];
    if (index == NSNotFound) {
        HLSLoggerError(@"View controller %@ not found in stack", viewController);
        return nil;
    }

    return [self.twoViewAnimationStepDefinitionsStack objectAtIndex:index];
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
    
    UIViewController *belowViewController = [self.viewControllerStack objectAtIndex:index - 1];
    
    NSMutableArray *animationSteps = [NSMutableArray array];
    NSArray *animationStepDefinitions = [self twoViewAnimationStepDefinitionsForViewController:viewController];
    for (HLSTwoViewAnimationStepDefinition *animationStepDefinition in animationStepDefinitions) {
        HLSAnimationStep *animationStep = [animationStepDefinition animationStepWithFirstView:belowViewController.view 
                                                                                   secondView:viewController.view];
        [animationSteps addObject:animationStep];
    }
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
    animation.tag = @"push_animation";
    animation.lockingUI = YES;
    animation.bringToFront = YES;
    animation.delegate = self;
    
    return animation;
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
