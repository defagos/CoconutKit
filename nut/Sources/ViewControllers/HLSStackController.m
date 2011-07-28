//
//  HLSStackController.m
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSAssert.h"
#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

// TODO: Bug: self.interfaceOrientation always returns portrait. WTF?

@interface HLSStackController ()

@property (nonatomic, retain) NSMutableArray *containerContentStack;

- (UIViewController *)secondTopViewController;

- (HLSAnimation *)createAnimationForContainerContent:(HLSContainerContent *)containerContent;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        HLSContainerContent *rootContainerContent = [[[HLSContainerContent alloc] initWithViewController:rootViewController 
                                                                                     containerController:self 
                                                                                         transitionStyle:HLSTransitionStyleNone 
                                                                                                duration:kAnimationTransitionDefaultDuration]
                                                     autorelease];
        self.containerContentStack = [NSMutableArray arrayWithObject:rootContainerContent];
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
    self.containerContentStack = nil;
    self.delegate = nil;
    
    [super dealloc];
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
                                         stretch:self.stretchingContent
                                blockInteraction:YES];
        
        // Push non-animated
        HLSAnimation *pushAnimation = [self createAnimationForContainerContent:containerContent];
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
        [containerContent removeViewFromContainerView];
        
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
        [self createAnimationForContainerContent:containerContent];
        
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
                                blockInteraction:YES];
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously. The root view controller is never pushed
        HLSAnimation *pushAnimation = [self createAnimationForContainerContent:containerContent];
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
        HLSContainerContent *topContainerContent = [self.containerContentStack lastObject];
        HLSAnimation *popAnimation = [topContainerContent reverseAnimation];
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

#pragma mark Managing view controllers

- (HLSAnimation *)createAnimationForContainerContent:(HLSContainerContent *)containerContent
{
    // Apply the same effect to all disappearing views; much better (we see all views below the added one as a single one). This is
    // a lot better with push or fade animations    
    NSUInteger index = [self.containerContentStack indexOfObject:containerContent];
    NSAssert(index != NSNotFound, @"Content not found in the container");
    HLSAnimation *animation = [containerContent createAnimationWithDisappearingContainerContents:[self.containerContentStack subarrayWithRange:NSMakeRange(0, index)] 
                                                                                     commonFrame:self.view.frame];    
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
            HLSContainerContent *disappearingContainerContent = [self.containerContentStack lastObject];
            [disappearingContainerContent removeViewFromContainerView];
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
    
    return [HLSContainerContent containerControllerForViewController:self];
}

@end
