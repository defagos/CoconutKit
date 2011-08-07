//
//  HLSPlaceholderViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import "HLSAnimation.h"
#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "NSArray+HLSExtensions.h"

@interface HLSPlaceholderViewController () <HLSAnimationDelegate>

- (void)initialize;

@property (nonatomic, retain) HLSContainerContent *containerContent;
@property (nonatomic, retain) HLSContainerContent *oldContainerContent;

- (HLSAnimation *)createAnimation;

- (UIViewController *)emptyViewController;

@end

@implementation HLSPlaceholderViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // Crate a dummy view controller with a transparent view; HLSContainerContent objects cannot manage nil
    self.containerContent = [[[HLSContainerContent alloc] initWithViewController:[self emptyViewController]
                                                             containerController:self
                                                                 transitionStyle:HLSTransitionStyleNone
                                                                        duration:kAnimationTransitionDefaultDuration]
                             autorelease];
}

- (void)dealloc
{
    self.containerContent = nil;
    self.oldContainerContent = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    [self.containerContent releaseViews];
    
    self.placeholderView = nil;
}

#pragma mark Accessors and mutators

@synthesize containerContent = m_containerContent;

@synthesize oldContainerContent = m_oldContainerContent;

@synthesize placeholderView = m_placeholderView;

@synthesize stretchingContent = m_stretchingContent;

@synthesize forwardingProperties = m_forwardingProperties;

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    if (m_forwardingProperties == forwardingProperties) {
        return;
    }
    
    m_forwardingProperties = forwardingProperties;
    
    self.containerContent.forwardingProperties = m_forwardingProperties;
}

@synthesize delegate = m_delegate;

- (UIViewController *)insetViewController
{
    return self.containerContent.viewController;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // All animations must take place within the placeholder area, even those which move views outside it. We
    // do not want views in the placeholder view to overlap with views outside it, so we clip views to match
    // the placeholder area
    self.placeholderView.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If an inset has been defined but not displayed yet, display it
    if ([self.containerContent addViewToContainerView:self.placeholderView
                                              stretch:self.stretchingContent 
                                     blockInteraction:NO 
                              inContainerContentStack:nil]) {
        // Push non-animated
        HLSAnimation *pushAnimation = [self createAnimation];
        [pushAnimation playAnimated:NO];
    }
    
    // Forward events to the inset view controller
    UIViewController *insetViewController = [self insetViewController];
    if (insetViewController && [self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
        [self.delegate placeholderViewController:self willShowInsetViewController:insetViewController animated:animated];
    }
    
    [insetViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIViewController *insetViewController = [self insetViewController];
    if (insetViewController && [self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
        [self.delegate placeholderViewController:self didShowInsetViewController:insetViewController animated:animated];
    }
    
    [insetViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIViewController *insetViewController = [self insetViewController];
    [insetViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    UIViewController *insetViewController = [self insetViewController];
    [insetViewController viewDidDisappear:animated];
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // If a rotation occurs during a transition, do not let rotate. Could lead to complications
    if (m_animationCount != 0) {
        HLSLoggerWarn(@"A transition animation is running; rotation aborted");
        return NO;
    }
    
    UIViewController *insetViewController = [self insetViewController];
    return [insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
    || [insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)];    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If the view controller can rotate by cloning, clone it. Since we use 1-step rotation (smoother, default since iOS3),
    // we cannot swap it in the middle of the animation. Instead, we use a cross-dissolve transition so that the change
    // happens smoothly during the rotation
    UIViewController *insetViewController = [self insetViewController];
    [insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *cloneableInsetViewController = (UIViewController<HLSOrientationCloner> *)insetViewController;
        UIViewController *clonedInsetViewController = [cloneableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        [self setInsetViewController:clonedInsetViewController 
                 withTransitionStyle:HLSTransitionStyleCrossDissolve
                            duration:duration];
        [clonedInsetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    UIViewController *insetViewController = [self insetViewController];
    [insetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    UIViewController *insetViewController = [self insetViewController];
    [insetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark Setting the inset view controller

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    [self setInsetViewController:insetViewController withTransitionStyle:HLSTransitionStyleNone];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    [self setInsetViewController:insetViewController 
             withTransitionStyle:transitionStyle
                        duration:kAnimationTransitionDefaultDuration];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration
{
    // Not changed; nothing to do
    if (insetViewController == [self insetViewController]) {
        return;
    }
    
    // If no inset set, put an empty view controller instead
    if (! insetViewController) {
        // Only some transition styles are allowed
        if (transitionStyle != HLSTransitionStyleNone) {
            HLSLoggerWarn(@"Transition style not available when removing an inset; set to none");
            transitionStyle = HLSTransitionStyleNone;
        }
        
        insetViewController = [self emptyViewController];   
    }
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if (! [insetViewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
        HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
        return;
    }
    
    // Keep a strong ref to the previous inset to keep it alive during the swap
    self.oldContainerContent = self.containerContent;
    
    // Associate the new view controller with its container (does not swap with current one yet; will be
    // done in the animation end callback)
    self.containerContent = [[[HLSContainerContent alloc] initWithViewController:insetViewController
                                                             containerController:self 
                                                                 transitionStyle:transitionStyle 
                                                                        duration:duration]
                             autorelease];
    self.containerContent.forwardingProperties = self.forwardingProperties;
    
    if ([self isViewLoaded]) {
        // Install the new view
        [self.containerContent addViewToContainerView:self.placeholderView 
                                              stretch:self.stretchingContent 
                                     blockInteraction:NO 
                              inContainerContentStack:[NSArray arrayWithObjects:self.oldContainerContent, self.containerContent, nil]];
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously
        HLSAnimation *addAnimation = [self createAnimation];
        if ([self isViewVisible]) {
            [addAnimation playAnimated:YES];
        }
        else {
            [addAnimation playAnimated:NO];
        }
    }        
}

#pragma mark Animation

- (HLSAnimation *)createAnimation
{
    NSMutableArray *containerContentStack = [NSMutableArray array];
    [containerContentStack safelyAddObject:self.oldContainerContent];
    [containerContentStack addObject:self.containerContent];
    
    HLSAnimation *animation = [self.containerContent animationWithContainerContentStack:[NSArray arrayWithArray:containerContentStack]
                                                                          containerView:self.placeholderView];
    animation.tag = @"add_animation";
    animation.lockingUI = YES;
    animation.bringToFront = YES;
    animation.delegate = self;
    return animation;
}

#pragma mark Creating an empty view controller for use when no inset is displayed

- (UIViewController *)emptyViewController
{
    // HLSViewController (supports all orientations out of the box)
    HLSViewController *emptyViewController = [[[HLSViewController alloc] init] autorelease];
    emptyViewController.view.frame = [UIScreen mainScreen].applicationFrame;
    emptyViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    emptyViewController.view.backgroundColor = [UIColor clearColor];
    return emptyViewController;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (! [animation.tag isEqual:@"add_animation"]) {
        return;
    }
    
    ++m_animationCount;
    
    if ([self isViewVisible]) {
        UIViewController *appearingViewController = self.containerContent.viewController;
        UIViewController *disappearingViewController = self.oldContainerContent.viewController;
        
        [disappearingViewController viewWillDisappear:animated];
        [appearingViewController viewWillAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                         willShowInsetViewController:appearingViewController
                                            animated:animated];
        }
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (! [animation.tag isEqual:@"add_animation"]) {
        return;
    }
    
    if ([self isViewVisible]) {
        UIViewController *appearingViewController = self.containerContent.viewController;
        UIViewController *disappearingViewController = self.oldContainerContent.viewController;
        
        // Remove the old view controller
        [self.oldContainerContent removeViewFromContainerView];
        
        [disappearingViewController viewDidDisappear:animated];
        [appearingViewController viewDidAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                          didShowInsetViewController:appearingViewController
                                            animated:animated];
        }
    }
    
    // Discard the old view controller
    if ([animation.tag isEqual:@"add_animation"]) {
        self.oldContainerContent = nil;
    }
    
    --m_animationCount;
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    UIViewController *insetViewController = [self insetViewController];
    if ([insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = (UIViewController<HLSReloadable> *)insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

@end

@implementation UIViewController (HLSPlaceholderViewController)

- (HLSPlaceholderViewController *)placeholderViewController
{
    return [HLSContainerContent containerControllerKindOfClass:[HLSPlaceholderViewController class] forViewController:self];
}

@end
