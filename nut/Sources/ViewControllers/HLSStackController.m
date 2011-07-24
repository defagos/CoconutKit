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

// TODO: When pushing a view controller, insert an invisible view just below it for preventing
//       user interaction with the views below in the stack.

// TODO: Must be able to push view controllers before the view controller is displayed. In such cases, no animation
//       will occur, but the animation will be saved for use during pop

// TODO: Factor out the code creating twoStepAnimations for HLSTransitionStyles in HLSTransitionStyle
//       or HLSTwoStepAnimationDefinition. Use it from both HLSPlaceholderViewController and
//       HLSStackController

static void *HLSStackControllerKey = &HLSStackControllerKey;

@interface HLSStackController ()

@property (nonatomic, retain) NSMutableArray *contentViewControllers;
@property (nonatomic, retain) NSMutableArray *addedAsSubviewFlags;
@property (nonatomic, retain) NSMutableArray *viewAnimationStepDefinitions;

- (UIViewController *)secondTopViewController;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        self.contentViewControllers = [NSMutableArray arrayWithObject:rootViewController];
        self.addedAsSubviewFlags = [NSMutableArray arrayWithObject:[NSNumber numberWithBool:NO]];
        self.viewAnimationStepDefinitions = [NSMutableArray arrayWithObject:[NSNull null]];
        NSAssert(! objc_getAssociatedObject(rootViewController, HLSStackControllerKey), @"A view controller can only be inserted into one stack controller");
        objc_setAssociatedObject(rootViewController, HLSStackControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
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
    self.contentViewControllers = nil;
    self.addedAsSubviewFlags = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize contentViewControllers = m_contentViewControllers;

@synthesize addedAsSubviewFlags = m_addedAsSubviewFlags;

@synthesize viewAnimationStepDefinitions = m_viewAnimationStepDefinitions;

@synthesize adjustingContent = m_adjustingContent;

@synthesize delegate = m_delegate;

- (UIViewController *)topViewController
{
    return [self.contentViewControllers lastObject];
}

- (UIViewController *)secondTopViewController
{
    if ([self.contentViewControllers count] < 2) {
        return nil;
    }
    return [self.contentViewControllers objectAtIndex:[self.contentViewControllers count] - 2];
}

- (NSArray *)viewControllers
{
    return [NSArray arrayWithArray:self.contentViewControllers];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All animation must take place inside the view controller's view
    self.view.clipsToBounds = YES;
    
    // Take all space available. Parent container view controllers should be responsible of adjusting
    // the view size properly
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add those view controller views which have not been added yet
    NSUInteger i = 0;
    for (UIViewController *viewController in self.contentViewControllers) {
        BOOL addedAsSubview = [[self.addedAsSubviewFlags objectAtIndex:i] boolValue];
        if (! addedAsSubview) {
            [self.view addSubview:viewController.view];
        }
        [self.addedAsSubviewFlags replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        ++i;
    }
    
    // Adjust frames to get proper autoresizing behavior. Made before the viewWillAppear: event is forwarded
    // to the top view controller, so that when this event is received view controller dimensions are known
    if (self.adjustingContent) {
        for (UIViewController *viewController in self.contentViewControllers) {
            viewController.view.frame = self.view.bounds;
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
    
    NSUInteger i = 0;
    for (UIViewController *viewController in self.contentViewControllers) {
        BOOL addedAsSubview = [[self.addedAsSubviewFlags objectAtIndex:i] boolValue];
        if (addedAsSubview) {
            viewController.view = nil;
            [viewController viewDidUnload];
            [self.addedAsSubviewFlags replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
        ++i;
    }
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // If one view controller in the stack does not support the orientation, neither will the container
    for (UIViewController *viewController in self.contentViewControllers) {
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
    
    // TODO:
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

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Code    
}

#pragma mark Pushing view controllers onto the stack

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:nil];
}

- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    NSArray *animationStepDefinitions = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle 
                                                                                                            disappearingView:[self topViewController].view
                                                                                                               appearingView:viewController.view
                                                                                                               inCommonFrame:self.view.frame];
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:animationStepDefinitions];
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    NSArray *animationStepDefinitions = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinitionsForTransitionStyle:transitionStyle 
                                                                                                            disappearingView:[self topViewController].view
                                                                                                               appearingView:viewController.view
                                                                                                               inCommonFrame:self.view.frame
                                                                                                                    duration:duration];
    [self pushViewController:viewController withTwoViewAnimationStepDefinitions:animationStepDefinitions];    
}

- (void)pushViewController:(UIViewController *)viewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
{
    HLSAssertObjectsInEnumerationAreKindOfClass(twoViewAnimationStepDefinitions, HLSTwoViewAnimationStepDefinition);
    NSAssert(viewController != nil, @"Cannot push nil");
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
        if (! [viewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
            HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
            return;
        }
    }
    
    // Notify disappearance of previous top view controller if visible
    if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
        UIViewController *topViewController = [self topViewController];
        // Animated
        if ([twoViewAnimationStepDefinitions count] != 0) {
            [topViewController viewWillDisappear:YES];
        }
        // Not animated
        else {
            [topViewController viewWillDisappear:NO];            
            [topViewController viewDidDisappear:NO];
        }        
    }
    
    // Associate the view controller with its container
    NSAssert(! objc_getAssociatedObject(viewController, HLSStackControllerKey), @"A view controller can only be inserted into one stack controller");
    objc_setAssociatedObject(viewController, HLSStackControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    // Push the new view controller
    [self.contentViewControllers addObject:viewController];
    [self.addedAsSubviewFlags addObject:[NSNumber numberWithBool:NO]];
    if (twoViewAnimationStepDefinitions) {
        [self.viewAnimationStepDefinitions addObject:twoViewAnimationStepDefinitions];
    }
    else {
        [self.viewAnimationStepDefinitions addObject:[NSNull null]];
    }
    
    // Add the view if the container view has been loaded
    if ([self lifeCyclePhase] >= HLSViewControllerLifeCyclePhaseViewDidLoad && [self lifeCyclePhase] < HLSViewControllerLifeCyclePhaseViewDidUnload) {
        // Instantiate the view lazily
        UIView *view = viewController.view;
        
        // If container already visible, resize and forward events
        if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
            if (self.adjustingContent) {
                view.frame = self.view.bounds;
            }
            
            // Animated
            if ([twoViewAnimationStepDefinitions count] != 0) {
                if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
                    [self.delegate stackController:self
                            willShowViewController:viewController 
                                          animated:YES];
                }

                [viewController viewWillAppear:YES];
                [self.addedAsSubviewFlags replaceObjectAtIndex:[self.addedAsSubviewFlags count] - 1
                                                    withObject:[NSNumber numberWithBool:YES]];
                
                [self.view addSubview:viewController.view];             
            }
            // Not animated
            else {
                if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
                    [self.delegate stackController:self
                            willShowViewController:viewController 
                                          animated:NO];
                }
                
                [viewController viewWillAppear:NO];
                [self.addedAsSubviewFlags replaceObjectAtIndex:[self.addedAsSubviewFlags count] - 1
                                                    withObject:[NSNumber numberWithBool:YES]];
                
                [self.view addSubview:viewController.view];
                
                if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
                    [self.delegate stackController:self
                             didShowViewController:viewController 
                                          animated:NO];
                }
                
                [viewController viewDidAppear:NO];
            }            
        }
        // Not visible or disappearing
        else {
            [self.view addSubview:view];
            [self.addedAsSubviewFlags replaceObjectAtIndex:[self.addedAsSubviewFlags count] - 1
                                                withObject:[NSNumber numberWithBool:YES]];            
        }
    }
    
    // Create the animation if any
    if ([twoViewAnimationStepDefinitions count] != 0) {
        UIView *topView = [self topViewController].view;
        UIView *previousTopView = [self secondTopViewController].view;
        
        NSMutableArray *animationSteps = [NSMutableArray array];
        for (HLSTwoViewAnimationStepDefinition *animationStepDefinition in twoViewAnimationStepDefinitions) {
            HLSAnimationStep *animationStep = [animationStepDefinition animationStepWithFirstView:previousTopView 
                                                                                       secondView:topView];
            [animationSteps addObject:animationStep];
        }
        
        HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
        animation.tag = @"push_animation";
        animation.lockingUI = YES;
        animation.bringToFront = YES;
        animation.delegate = self;
        
        // Animation occurs if the container is visible
        if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
            [animation playAnimated:YES];
        }
        else {
            [animation playAnimated:NO];
        }
    }
}

#pragma mark Popping view controllers

- (UIViewController *)popViewController
{
    // Cannot pop if only one view controller remains
    if ([self.contentViewControllers count] == 1) {
        HLSLoggerWarn(@"The root view controller cannot be popped");
        return nil;
    }
    
    // If the top view controller is visible, notify disappearance
    UIViewController *previousTopViewController = [self topViewController];
    if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
        // TODO: Animated case!
        [previousTopViewController viewWillDisappear:NO];
    }
    
    [previousTopViewController.view removeFromSuperview];
    
    // TODO: Will be replace later by a property (because we need to retain the view controller during animation); will let the view
    //       controller live a little bit longer
    [[previousTopViewController retain] autorelease];
    
    // Remove the view controller association with its container
    NSAssert(objc_getAssociatedObject(previousTopViewController, HLSStackControllerKey), @"The view controller was not inserted into a stack controller");
    objc_setAssociatedObject(previousTopViewController, HLSStackControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    [self.contentViewControllers removeLastObject];
    [self.addedAsSubviewFlags removeLastObject];
    [self.viewAnimationStepDefinitions removeLastObject];
    
    if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
        // TODO: Animated case!
        [previousTopViewController viewDidDisappear:NO];
        
        UIViewController *topViewController = [self topViewController];
        
        if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
            [self.delegate stackController:self
                    willShowViewController:topViewController
                                  animated:NO];
        }
        
        [topViewController viewWillAppear:NO];
        
        if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
            [self.delegate stackController:self
                     didShowViewController:topViewController
                                  animated:NO];
        }
        
        [topViewController viewDidAppear:NO];
    }
    
    return previousTopViewController;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    // TODO: Restore original view properties
    // TODO: Remove associated object after pop animation
    
    if ([animation.tag isEqual:@"push_animation"]) {
        UIViewController *previousTopViewController = [self secondTopViewController];
        [previousTopViewController viewDidDisappear:YES];
        
        UIViewController *topViewController = [self topViewController];
        if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
            [self.delegate stackController:self
                     didShowViewController:topViewController 
                                  animated:YES];
        }
        
        [topViewController viewDidAppear:NO];
    }
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{

}

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    return objc_getAssociatedObject(self, HLSStackControllerKey);
}

@end
