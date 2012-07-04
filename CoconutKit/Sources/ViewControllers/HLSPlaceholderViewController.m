//
//  HLSPlaceholderViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSPlaceholderInsetSegue.h"
#import "NSArray+HLSExtensions.h"
#import "NSMutableArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSPlaceholderViewController ()

@property (nonatomic, retain) NSMutableArray *containerContents;
@property (nonatomic, retain) NSMutableArray *oldContainerContents;

- (NSArray *)insetViewControllers;

- (HLSContainerContent *)containerContentAtIndex:(NSUInteger)index;
- (HLSContainerContent *)oldContainerContentAtIndex:(NSUInteger)index;

- (HLSAnimation *)createAnimationForIndex:(NSUInteger)index;

- (UIViewController *)emptyViewController;

@end

@implementation HLSPlaceholderViewController

#pragma mark Object creation and destruction

- (void)awakeFromNib
{
    // Load view controllers initially using reserved segue identifiers. We cannot use [self.placeholderViews count]
    // as loop upper limit here since the view is not loaded (and we cannot do this after -loadView has been called). 
    // Checking the first 20 indices should be sufficient
    for (NSUInteger i = 0; i < 20; ++i) {
        @try {
            NSString *segueIdentifier = [NSString stringWithFormat:@"%@%d", HLSPlaceholderPreloadSegueIdentifierPrefix, i];
            [self performSegueWithIdentifier:segueIdentifier sender:self];
        }
        @catch (NSException *exception) {}
    }
}

- (void)dealloc
{
    self.containerContents = nil;
    self.oldContainerContents = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent releaseViews];
    }
    
    self.placeholderViews = nil;
}

#pragma mark Accessors and mutators

@synthesize containerContents = m_containerContents;

@synthesize oldContainerContents = m_oldContainerContents;

@synthesize placeholderViews = m_placeholderViews;

@synthesize forwardingProperties = m_forwardingProperties;

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    if (m_forwardingProperties == forwardingProperties) {
        return;
    }
    
    m_forwardingProperties = forwardingProperties;
    
    HLSContainerContent *firstContainerContent = [self.containerContents firstObject];
    firstContainerContent.forwardingProperties = m_forwardingProperties;    
}

@synthesize delegate = m_delegate;

- (UIView *)placeholderViewAtIndex:(NSUInteger)index
{
    if (index >= [self.placeholderViews count]) {
        return nil;
    }
    return [self.placeholderViews objectAtIndex:index];
}

- (NSArray *)insetViewControllers
{
    NSMutableArray *insetViewControllers = [NSMutableArray array];
    for (HLSContainerContent *containerContent in self.containerContents) {
        [insetViewControllers addObject:containerContent.viewController];
    }
    return [NSArray arrayWithArray:insetViewControllers];
}

- (UIViewController *)insetViewControllerAtIndex:(NSUInteger)index
{
    NSArray *insetViewControllers = [self insetViewControllers];
    if (index >= [insetViewControllers count]) {
        return nil;
    }
    return [insetViewControllers objectAtIndex:index];
}

- (HLSContainerContent *)containerContentAtIndex:(NSUInteger)index
{
    if (index >= [self.containerContents count]) {
        return nil;
    }
    
    return [self.containerContents objectAtIndex:index];
}

- (HLSContainerContent *)oldContainerContentAtIndex:(NSUInteger)index
{
    if (index >= [self.oldContainerContents count]) {
        return nil;
    }
    
    HLSContainerContent *oldContainerContent = [self.oldContainerContents objectAtIndex:index];
    if ([oldContainerContent isEqual:[NSNull null]]) {
        return nil;
    }
    else {
        return oldContainerContent;
    }
}

#pragma mark View lifecycle

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The order of outlets within an IBOutletCollection is sadly not the one defined in the nib file. Expect the user
    // to explictly order them using the UIView tag property, and warn if this was not done properly. This is not an
    // issue if the placeholder views are set programmatically
    if ([self nibName]) {
        NSMutableSet *tags = [NSMutableSet set];
        for (UIView *placeholderView in self.placeholderViews) {
            [tags addObject:[NSNumber numberWithInteger:placeholderView.tag]];
        }
        if ([tags count] != [self.placeholderViews count]) {
            HLSLoggerWarn(@"Duplicate placeholder view tags found. The order of the placeholder view collection is "
                          "unreliable. Please set a different tag for each placeholder view, the one with the lowest "
                          "tag will be the first one in the collection");
        }
    }
    
    NSSortDescriptor *tagSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES];
    self.placeholderViews = [self.placeholderViews sortedArrayUsingDescriptor:tagSortDescriptor];
    
    // The first time the view is loaded, guess which number of placeholder views have been defined
    if (! m_loadedOnce) {
        // View controllers have been preloaded
        if (self.containerContents) {
            if ([self.placeholderViews count] < [self.containerContents count]) {
                NSString *reason = [NSString stringWithFormat:@"Not enough placeholder views (%d) to hold preloaded view controllers (%d)", 
                                    [self.placeholderViews count], [self.containerContents count]];
                @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                               reason:reason
                                             userInfo:nil];
            }            
        }
        // No preloading
        else {
            self.containerContents = [NSMutableArray array];
            self.oldContainerContents = [NSMutableArray array];
        }
        
        // We need to have a view controller in each placeholder (even if no preloading was made)
        for (NSUInteger i = [self.containerContents count]; i < [self.placeholderViews count]; ++i) {
            HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:[self emptyViewController]
                                                                                     containerController:self
                                                                                         transitionStyle:HLSTransitionStyleNone
                                                                                                duration:kAnimationTransitionDefaultDuration] autorelease];
            
            [self.containerContents addObject:containerContent];
            [self.oldContainerContents addObject:[NSNull null]];
        }
        
        m_loadedOnce = YES;
    }
    // If the view has been unloaded, we expect the same number of placeholder views after a reload
    else {
        NSAssert([self.containerContents count] == [self.placeholderViews count], @"The number of placeholder views has changed");
    }
        
    // All animations must take place within the placeholder areas, even those which move views outside it. We
    // do not want views in the placeholder view to overlap with views outside it, so we clip views to match
    // the placeholder area
    for (UIView *placeholderView in self.placeholderViews) {
        placeholderView.clipsToBounds = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If an inset has been defined but not displayed yet, display it
    NSUInteger index = 0;
    for (HLSContainerContent *containerContent in self.containerContents) {
        UIView *placeholderView = [self.placeholderViews objectAtIndex:index];
        if ([containerContent addViewToContainerView:placeholderView 
                             inContainerContentStack:nil]) {
            // Push non-animated
            HLSAnimation *pushAnimation = [self createAnimationForIndex:index];
            [pushAnimation playAnimated:NO];
        }
        
        // Forward events to the inset view controller
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:atIndex:animated:)]) {
            [self.delegate placeholderViewController:self 
                         willShowInsetViewController:containerContent.viewController 
                                             atIndex:index
                                            animated:animated];
        }
        [containerContent viewWillAppear:animated];
        
        ++index;
    }   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUInteger index = 0;
    for (HLSContainerContent *containerContent in self.containerContents) {
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:atIndex:animated:)]) {
            [self.delegate placeholderViewController:self 
                          didShowInsetViewController:containerContent.viewController 
                                             atIndex:index
                                            animated:animated];
        }
        [containerContent viewDidAppear:animated];
        
        ++index;
    }    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent viewDidDisappear:animated];
    }
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        UIViewController *insetViewController = containerContent.viewController;
        if (! [insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
                && ! [insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If a view controller can rotate by cloning, clone it. Since we use 1-step rotation (smoother, default since iOS3),
    // we cannot swap it in the middle of the animation. Instead, we use a cross-dissolve transition so that the change
    // happens smoothly during the rotation
    NSUInteger index = 0;
    for (HLSContainerContent *containerContent in self.containerContents) {
        UIViewController *insetViewController = containerContent.viewController;
        [insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        if ([insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
            UIViewController<HLSOrientationCloner> *cloneableInsetViewController = (UIViewController<HLSOrientationCloner> *)insetViewController;
            UIViewController *clonedInsetViewController = [cloneableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
            [self setInsetViewController:clonedInsetViewController 
                                 atIndex:index
                     withTransitionStyle:HLSTransitionStyleCrossDissolve
                                duration:duration];
            [clonedInsetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
        ++index;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent.viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for (HLSContainerContent *containerContent in self.containerContents) {
        [containerContent.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

#pragma mark Setting the inset view controller

- (void)setInsetViewController:(UIViewController *)insetViewController 
                       atIndex:(NSUInteger)index
{
    [self setInsetViewController:insetViewController 
                         atIndex:index
             withTransitionStyle:HLSTransitionStyleNone];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    [self setInsetViewController:insetViewController 
                         atIndex:index
             withTransitionStyle:transitionStyle
                        duration:kAnimationTransitionDefaultDuration];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration
{    
    // If no inset set, put an empty view controller instead
    if (! insetViewController) {
        // Only some transition styles are allowed
        if (transitionStyle != HLSTransitionStyleNone) {
            HLSLoggerWarn(@"Transition style not available when removing an inset; set to none");
            transitionStyle = HLSTransitionStyleNone;
        }
        
        insetViewController = [self emptyViewController];   
    }
    
    // Pre-loading: Resize the container content arrays as needed to match the number of preloaded view controllers
    if (! m_loadedOnce) {
        if (! self.containerContents) {
            self.containerContents = [NSMutableArray array];
            self.oldContainerContents = [NSMutableArray array];
        }
        
        // Resize as needed so that all view controllers fit
        for (NSUInteger i = [self.containerContents count]; i <= index; ++i) {
            // We must have view controllers in all slots (even if empty)
            HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:[self emptyViewController]
                                                                                     containerController:self
                                                                                         transitionStyle:HLSTransitionStyleNone
                                                                                                duration:kAnimationTransitionDefaultDuration] autorelease];

            [self.containerContents addObject:containerContent];
            
            [self.oldContainerContents addObject:[NSNull null]];
        }
    }
    
    // Not changed; nothing to do
    if (insetViewController == [self insetViewControllerAtIndex:index]) {
        return;
    }
    
    // Check that the view controller to be pushed is compatible with the current orientation
    if (! [insetViewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
        HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
        return;
    }
    
    // Keep a strong ref to the previous inset to keep it alive during the swap
    HLSContainerContent *oldContainerContent = [self containerContentAtIndex:index];
    [self.oldContainerContents replaceObjectAtIndex:index withObject:oldContainerContent];
    
    // Associate the new view controller with its container (does not swap with current one yet; will be
    // done in the animation end callback)
    HLSContainerContent *containerContent = [[[HLSContainerContent alloc] initWithViewController:insetViewController
                                                                             containerController:self 
                                                                                 transitionStyle:transitionStyle 
                                                                                        duration:duration] autorelease];
    if (index == 0) {
        containerContent.forwardingProperties = self.forwardingProperties;
    }
    [self.containerContents replaceObjectAtIndex:index withObject:containerContent];
    if ([self isViewLoaded]) {
        // Install the new view
        UIView *placeholderView = [self.placeholderViews objectAtIndex:index];
        [containerContent addViewToContainerView:placeholderView  
                         inContainerContentStack:[NSArray arrayWithObjects:oldContainerContent, containerContent, nil]];
        
        // If visible, always plays animated (even if no animation steps are defined). This is a transition, and we
        // expect it to occur animated, even if instantaneously
        HLSAnimation *addAnimation = [self createAnimationForIndex:index];
        if ([self isViewVisible]) {
            [addAnimation playAnimated:YES];
        }
        else {
            [addAnimation playAnimated:NO];
        }
    }        
}

#pragma mark Animation

- (HLSAnimation *)createAnimationForIndex:(NSUInteger)index
{
    HLSContainerContent *containerContent = [self containerContentAtIndex:index];
    HLSContainerContent *oldContainerContent = [self oldContainerContentAtIndex:index];
    
    NSMutableArray *containerContentStack = [NSMutableArray array];
    if (oldContainerContent) {
        [containerContentStack addObject:oldContainerContent];
    }
    [containerContentStack addObject:containerContent];
    
    UIView *placeholderView = [self.placeholderViews objectAtIndex:index];
    HLSAnimation *animation = [containerContent animationWithContainerContentStack:[NSArray arrayWithArray:containerContentStack]
                                                                     containerView:placeholderView];
    animation.tag = @"add_animation";
    animation.delegate = self;
    animation.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:index] forKey:@"index"];
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
    if (! [animation.tag isEqualToString:@"add_animation"]) {
        return;
    }
    
    if ([self isViewVisible]) {
        NSUInteger index = [[animation.userInfo objectForKey:@"index"] unsignedIntValue];
        HLSContainerContent *containerContent = [self containerContentAtIndex:index];
        HLSContainerContent *oldContainerContent = [self oldContainerContentAtIndex:index];
        
        [oldContainerContent viewWillDisappear:animated];
        [containerContent viewWillAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:atIndex:animated:)]) {
            [self.delegate placeholderViewController:self
                         willShowInsetViewController:containerContent.viewController
                                             atIndex:index
                                            animated:animated];
        }
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (! [animation.tag isEqualToString:@"add_animation"]) {
        return;
    }
    
    NSUInteger index = [[animation.userInfo objectForKey:@"index"] unsignedIntValue];
    HLSContainerContent *oldContainerContent = [self oldContainerContentAtIndex:index];
    
    // Remove the old view controller
    [oldContainerContent removeViewFromContainerView];
    
    if ([self isViewVisible]) {
        HLSContainerContent *containerContent = [self containerContentAtIndex:index];
        
        [oldContainerContent viewDidDisappear:animated];
        [containerContent viewDidAppear:animated];
        
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:atIndex:animated:)]) {
            [self.delegate placeholderViewController:self
                          didShowInsetViewController:containerContent.viewController
                                             atIndex:index
                                            animated:animated];
        }
    }
    
    // Discard the old view controller
    [self.oldContainerContents replaceObjectAtIndex:index withObject:[NSNull null]];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    for (HLSContainerContent *containerContent in self.containerContents) {
        UIViewController *insetViewController = containerContent.viewController;
        if ([insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
            UIViewController<HLSReloadable> *reloadableInsetViewController = (UIViewController<HLSReloadable> *)insetViewController;
            [reloadableInsetViewController reloadData];
        }
    }
}

@end

@implementation UIViewController (HLSPlaceholderViewController)

- (HLSPlaceholderViewController *)placeholderViewController
{
    return [HLSContainerContent containerControllerKindOfClass:[HLSPlaceholderViewController class] forViewController:self];
}

@end
