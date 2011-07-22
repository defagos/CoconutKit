//
//  HLSStackController.m
//  nut
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSAssert.h"

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
    
    // Code
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Code
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    // Code
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Code
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Code
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Code
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
