//
//  HLSStackController.m
//  CoconutKit
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "HLSStackPushSegue.h"
#import "NSArray+HLSExtensions.h"
#import "UIView+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSStackController ()

@property (nonatomic, strong) HLSContainerStack *containerStack;
@property (nonatomic, assign) NSUInteger capacity;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController capacity:(NSUInteger)capacity
{
    if (self = [super init]) {
        self.autorotationMode = HLSAutorotationModeContainer;
        
        self.containerStack = [[HLSContainerStack alloc] initWithContainerViewController:self
                                                                                behavior:HLSContainerStackBehaviorFixedRoot
                                                                                capacity:capacity];
        self.containerStack.autorotationMode = self.autorotationMode;
        self.containerStack.delegate = self;
        [self.containerStack pushViewController:rootViewController 
                            withTransitionClass:[HLSTransitionNone class]
                                       duration:0.
                                       animated:NO];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController capacity:HLSContainerStackDefaultCapacity];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.capacity = HLSContainerStackDefaultCapacity;
        self.autorotationMode = HLSAutorotationModeContainer;
    }
    return self;
}

#pragma clang diagnostic pop

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.containerStack = [[HLSContainerStack alloc] initWithContainerViewController:self
                                                                            behavior:HLSContainerStackBehaviorFixedRoot
                                                                            capacity:self.capacity];
    self.containerStack.autorotationMode = self.autorotationMode;
    self.containerStack.delegate = self;
    
    // Load the root view controller when using segues. A reserved segue called 'hls_root' must be used for such purposes
    @try {
        [self performSegueWithIdentifier:HLSStackRootSegueIdentifier sender:self];
    }
    @catch (NSException *exception) {
        HLSLoggerDebug(@"Exception caught but not rethrown: %@", exception);
    }
    
    if ([self.containerStack count] == 0) {
        NSString *reason = [NSString stringWithFormat: @"No root view controller has been loaded. Drag a segue called '%@' "
                            "in your storyboard file, from the stack controller to the view controller you want to install "
                            "as root", HLSStackRootSegueIdentifier];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:reason
                                     userInfo:nil];
    }
}

#pragma mark Accessors and mutators

- (void)setCapacity:(NSUInteger)capacity
{
    if (self.containerStack) {
        HLSLoggerWarn(@"The capacity cannot be altered once the stack controller has been created");
        return;
    }
    
    _capacity = capacity;
}

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{
    if (autorotationMode == _autorotationMode) {
        return;
    }
    
    _autorotationMode = autorotationMode;
    
    // If the container stack has not been instantiated (which can happen when using storyboards, since in this case
    // it gets intantiated in -awakeFromNimb), the following does nothing. This is why the autorotation mode value
    // also has to be stored as an ivar, so that the container stack autorotation mode can be correctly set even
    // in this case
    self.containerStack.autorotationMode = autorotationMode;
}

- (UIViewController *)rootViewController
{
    return [self.containerStack rootViewController];
}

- (UIViewController *)topViewController
{
    return [self.containerStack topViewController];
}

- (NSArray *)viewControllers
{
    return [self.containerStack viewControllers];
}

- (NSUInteger)count
{
    return [self.containerStack count];
}

- (void)setLockingUI:(BOOL)lockingUI
{
    self.containerStack.lockingUI = lockingUI;
}

- (BOOL)lockingUI
{
    return self.containerStack.lockingUI;
}

#pragma mark View lifecycle

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return NO;
}

- (void)loadView
{
    // Take all space available
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    self.view = [[UIView alloc] initWithFrame:applicationFrame];
    self.view.autoresizingMask = HLSViewAutoresizingAll;
    
    self.containerStack.containerView = self.view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.containerStack viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    [self.containerStack viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.containerStack viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.containerStack viewDidDisappear:animated];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return [self.containerStack shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & [self.containerStack supportedInterfaceOrientations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.containerStack willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.containerStack willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.containerStack didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark Inserting or removing view controllers

- (void)pushViewController:(UIViewController *)viewController 
       withTransitionClass:(Class)transitionClass
                  animated:(BOOL)animated
{
    [self pushViewController:viewController 
         withTransitionClass:transitionClass
                    duration:kAnimationTransitionDefaultDuration
                    animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionClass:(Class)transitionClass
                  duration:(NSTimeInterval)duration
                  animated:(BOOL)animated
{
    [self.containerStack pushViewController:viewController
                        withTransitionClass:transitionClass
                                   duration:duration
                                   animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated
{    
    [self.containerStack popViewControllerAnimated:animated];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.containerStack popToViewController:viewController animated:animated];
}

- (void)popToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.containerStack popToViewControllerAtIndex:index animated:animated];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    [self.containerStack popToRootViewControllerAnimated:animated];
}

- (void)insertViewController:(UIViewController *)viewController
                     atIndex:(NSUInteger)index
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    [self.containerStack insertViewController:viewController
                                      atIndex:index
                          withTransitionClass:transitionClass
                                     duration:duration
                                     animated:animated];
}

- (void)insertViewController:(UIViewController *)viewController
         belowViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
{
    [self.containerStack insertViewController:viewController
                          belowViewController:siblingViewController
                          withTransitionClass:transitionClass
                                     duration:duration];
}

- (void)insertViewController:(UIViewController *)viewController
         aboveViewController:(UIViewController *)siblingViewController
         withTransitionClass:(Class)transitionClass
                    duration:(NSTimeInterval)duration
                    animated:(BOOL)animated
{
    [self.containerStack insertViewController:viewController
                          aboveViewController:siblingViewController
                          withTransitionClass:transitionClass
                                     duration:duration
                                     animated:animated];
}

- (void)removeViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.containerStack removeViewControllerAtIndex:index animated:animated];
}

- (void)removeViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.containerStack removeViewController:viewController animated:animated];
}

#pragma mark HLSContainerStackDelegate protocol implementation

- (void)containerStack:(HLSContainerStack *)containerStack
willPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:willPushViewController:coverViewController:animated:)]) {
        [self.delegate stackController:self
                willPushViewController:pushedViewController
                   coverViewController:coveredViewController
                              animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
        [self.delegate stackController:self willShowViewController:viewController animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
        [self.delegate stackController:self didShowViewController:viewController animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
 didPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:didPushViewController:coverViewController:animated:)]) {
        [self.delegate stackController:self
                 didPushViewController:pushedViewController
                   coverViewController:coveredViewController
                              animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
 willPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:willPopViewController:revealViewController:animated:)]) {
        [self.delegate stackController:self
                 willPopViewController:poppedViewController
                  revealViewController:revealedViewController
                              animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack willHideViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:willHideViewController:animated:)]) {
        [self.delegate stackController:self willHideViewController:viewController animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack didHideViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:didHideViewController:animated:)]) {
        [self.delegate stackController:self didHideViewController:viewController animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
  didPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stackController:didPopViewController:revealViewController:animated:)]) {
        [self.delegate stackController:self
                  didPopViewController:poppedViewController
                  revealViewController:revealedViewController
                              animated:animated];
    }
}

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    return [self containerViewControllerKindOfClass:[HLSStackController class]];
}

@end
