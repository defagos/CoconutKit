//
//  HLSStackController.m
//  CoconutKit
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStackController.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSStackPushSegue.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSStackController ()

@property (nonatomic, retain) HLSContainerStack *containerStack;

- (void)setCapacity:(NSUInteger)capacity;

@end

@implementation HLSStackController

#pragma mark Object creation and destruction

- (id)initWithRootViewController:(UIViewController *)rootViewController capacity:(NSUInteger)capacity
{
    if ((self = [super init])) {
        self.containerStack = [[[HLSContainerStack alloc] initWithContainerViewController:self] autorelease];
        [self.containerStack pushViewController:rootViewController 
                            withTransitionStyle:HLSTransitionStyleNone 
                                       duration:0.];
        self.containerStack.capacity = capacity;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController capacity:HLSContainerStackDefaultCapacity];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // A stack controller is not meant to be instantiated in a nib... except if we are using storyboards. In this
    // case, setting the root view controller is performed using segues (must be done when the involved view
    // controllers are available, in -awakeFromNib).
    if ((self = [super initWithCoder:aDecoder])) {
        self.containerStack = [[[HLSContainerStack alloc] initWithContainerViewController:self] autorelease];
        self.containerStack.capacity = HLSContainerStackMinimalCapacity;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)awakeFromNib
{
    // Load the root view controller when using segues. A reserved segue called 'hls_root' must be used for such purposes
    [self performSegueWithIdentifier:HLSStackRootSegueIdentifier sender:self];
    
    // We now must have at least one view controller loaded
    NSAssert([[self.containerStack viewControllers] count] != 0, @"No root view controller has been loaded. Drag a segue called "
             "'%@' in your storyboard file, from the stack controller to the view controller you want to install "
             "as root", HLSStackRootSegueIdentifier);
}

- (void)dealloc
{
    self.containerStack = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    [self.containerStack releaseViews];
}

#pragma mark Accessors and mutators

@synthesize containerStack = m_containerStack;

- (void)setCapacity:(NSUInteger)capacity
{
    self.containerStack.capacity = capacity;
}

- (BOOL)isForwardingProperties
{
    return self.containerStack.forwardingProperties;
}

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    self.containerStack.forwardingProperties = forwardingProperties;
}

@synthesize delegate = m_delegate;

- (UIViewController *)rootViewController
{
    return [[self.containerStack viewControllers] firstObject];
}

- (UIViewController *)topViewController
{
    return [[self.containerStack viewControllers] lastObject];
}

- (NSArray *)viewControllers
{
    return [self.containerStack viewControllers];
}

#pragma mark View lifecycle

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

- (void)loadView
{
    // Take all space available
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    self.view = [[[UIView alloc] initWithFrame:applicationFrame] autorelease];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return [self.containerStack shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
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

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Just to suppress localization warning
}

#pragma mark Pushing view controllers onto the stack

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController withTransitionStyle:HLSTransitionStyleNone];
}

- (void)pushViewController:(UIViewController *)viewController 
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    [self pushViewController:viewController 
         withTransitionStyle:transitionStyle
                    duration:kAnimationTransitionDefaultDuration];
}

- (void)pushViewController:(UIViewController *)viewController
       withTransitionStyle:(HLSTransitionStyle)transitionStyle
                  duration:(NSTimeInterval)duration
{
    [self.containerStack pushViewController:viewController
                        withTransitionStyle:transitionStyle 
                                   duration:duration];
}

#pragma mark Popping view controllers

- (void)popViewController
{
    [self.containerStack popViewController];
}

@end

@implementation UIViewController (HLSStackController)

- (HLSStackController *)stackController
{
    return [HLSContainerContent containerControllerKindOfClass:[HLSStackController class] forViewController:self];
}

@end
