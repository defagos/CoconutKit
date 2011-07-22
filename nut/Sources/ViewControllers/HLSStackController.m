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

@interface HLSStackController ()

@property (nonatomic, retain) NSArray *viewControllers;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController;
{
    if ((self = [super init])) {
        self.viewControllers = [NSArray arrayWithObject:rootViewController];
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
    self.viewControllers = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewControllers = m_viewControllers;

@synthesize delegate = m_delegate;

- (UIViewController *)topViewController
{
    return [self.viewControllers lastObject];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All animation must take place inside the view controller's view
    self.view.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // View controllers not added in viewDidLoad. Only after viewWillAppear are view dimensions known
    if (! m_viewsAdded) {
        for (UIViewController *viewController in self.viewControllers) {
            [self.view addSubview:viewController.view];
        }
        
        m_viewsAdded = YES;
    }
    
    // Adjust frames to get proper autoresizing behavior. Made before the viewWillAppear: event is forwarded
    // to the top view controller, so that when this event is received dimensions are known
    for (UIViewController *viewController in self.viewControllers) {
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
    
    if (m_viewsAdded) {
        for (UIViewController *viewController in self.viewControllers) {
            viewController.view = nil;
            [viewController viewDidUnload];
        }
        m_viewsAdded = NO;
    }
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // TODO:
    return YES;
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
}

#pragma mark Popping view controllers

- (UIViewController *)popViewController
{
    // TODO:
    return nil;
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
    if ([self.viewControllers count] == 1) {
        HLSLoggerWarn(@"The root view controller cannot be popped");
        return nil;
    }

    // TODO:
    return nil;
}

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    // TODO: Implement using runtime associated objects
    return nil;
}

@end
