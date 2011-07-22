//
//  HLSStackController.m
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSOrientationCloner.h"

// TODO: When pushing a view controller, insert an invisible view just below it for preventing
//       user interaction with the views below in the stack. Could maybe just be a screenshot of
//       the content below, so that we can avoid always having the view hierarchy loaded (would
//       not be good when memory gets low)
//       See http://developer.apple.com/library/ios/#qa/qa1703/_index.html

@interface HLSStackController ()

@property (nonatomic, retain) NSMutableArray *contentViewControllers;
@property (nonatomic, retain) NSMutableArray *addedAsSubviewFlags;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        self.contentViewControllers = [NSMutableArray arrayWithObject:rootViewController];
        self.addedAsSubviewFlags = [NSMutableArray arrayWithObject:[NSNumber numberWithBool:NO]];
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

@synthesize delegate = m_delegate;

- (UIViewController *)topViewController
{
    return [self.contentViewControllers lastObject];
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
    for (UIViewController *viewController in self.contentViewControllers) {
        viewController.view.frame = self.view.bounds;
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
    
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    
}

- (void)pushViewController:(UIViewController *)viewController
withTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
{
    // TODO: Must be able to push view controllers before the view controller is displayed. In such cases, no animation
    //       will occur, but the animation will be registered for the pop
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
        // TODO: Animated case!
        UIViewController *topViewController = [self topViewController];
        [topViewController viewWillDisappear:NO];
        [topViewController viewDidDisappear:NO];
    }
    
    // Push the new view controller
    [self.contentViewControllers addObject:viewController];
    [self.addedAsSubviewFlags addObject:[NSNumber numberWithBool:NO]];
    
    // Add the view if the container view has been loaded
    if ([self lifeCyclePhase] >= HLSViewControllerLifeCyclePhaseViewDidLoad && [self lifeCyclePhase] < HLSViewControllerLifeCyclePhaseViewDidUnload) {
        // Instantiate the view lazily
        UIView *view = viewController.view;
        
        // If container already visible, resize and forward events
        if ([self lifeCyclePhase] == HLSViewControllerLifeCyclePhaseViewDidAppear) {
            view.frame = self.view.bounds;
            
            // TODO: Animated case!
            if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
                [self.delegate stackController:self
                        willShowViewController:viewController 
                                      animated:NO];
            }
            
            [viewController viewWillAppear:NO];
            [self.addedAsSubviewFlags replaceObjectAtIndex:[self.addedAsSubviewFlags count] -1
                                                withObject:[NSNumber numberWithBool:YES]];
            
            [self.view addSubview:viewController.view];
            
            if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
                [self.delegate stackController:self
                         didShowViewController:viewController 
                                      animated:NO];
            }
            
            [viewController viewDidAppear:NO];
        }
        // Not visible or disappearing
        else {
            [self.view addSubview:view];
            [self.addedAsSubviewFlags replaceObjectAtIndex:[self.addedAsSubviewFlags count] -1
                                                withObject:[NSNumber numberWithBool:YES]];            
        }
    }
}

#pragma mark Popping view controllers

- (UIViewController *)popViewController
{
    // TODO: Must retrieve the animation used when pushed to play it backwards
    return [self popViewControllerWithTwoViewAnimationStepDefinitions:nil];
}

- (UIViewController *)popViewControllerWithTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    // TODO:
    return nil;
}

- (UIViewController *)popViewControllerWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                                                  duration:(NSTimeInterval)duration
{
    // TODO:
    return nil;
}

- (UIViewController *)popViewControllerWithTwoViewAnimationStepDefinitions:(NSArray *)twoViewAnimationStepDefinitions
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
    
    [self.contentViewControllers removeLastObject];
    [self.addedAsSubviewFlags removeLastObject];
    
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

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    // TODO: Implement using runtime associated objects
    return nil;
}

@end
