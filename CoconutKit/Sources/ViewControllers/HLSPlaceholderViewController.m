//
//  HLSPlaceholderViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import "HLSLogger.h"
#import "HLSPlaceholderInsetSegue.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSPlaceholderViewController ()

- (void)hlsPlaceholderViewControllerInit;

@property (nonatomic, retain) NSMutableArray *containerStacks;

- (NSArray *)insetViewControllers;

- (HLSContainerStack *)containerStackAtIndex:(NSUInteger)index;

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
    self.containerStacks = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack releaseViews];
    }
    
    self.placeholderViews = nil;
}

#pragma mark Accessors and mutators

@synthesize containerStacks = m_containerStacks;

@synthesize placeholderViews = m_placeholderViews;

- (BOOL)isForwardingProperties
{
    HLSContainerStack *firstContainerStack = [self.containerStacks firstObject];
    return firstContainerStack.forwardingProperties;
}

@synthesize forwardingProperties = m_forwardingProperties;

- (void)setForwardingProperties:(BOOL)forwardingProperties
{
    HLSContainerStack *firstContainerStack = [self.containerStacks firstObject];
    firstContainerStack.forwardingProperties = forwardingProperties;
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
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [insetViewControllers addObject:[containerStack topViewController]];
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

- (HLSContainerStack *)containerStackAtIndex:(NSUInteger)index
{
    if (index >= [self.containerStacks count]) {
        return nil;
    }
    
    return [self.containerStacks objectAtIndex:index];
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
        if (self.containerStacks) {
            if ([self.placeholderViews count] < [self.containerStacks count]) {
                NSString *reason = [NSString stringWithFormat:@"Not enough placeholder views (%d) to hold preloaded view controllers (%d)", 
                                    [self.placeholderViews count], [self.containerStacks count]];
                @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                               reason:reason
                                             userInfo:nil];
            }            
        }
        // No preloading
        else {
            self.containerStacks = [NSMutableArray array];
        }
        
        // We need to have a view controller in each placeholder (even if no preloading was made)
        for (NSUInteger i = [self.containerStacks count]; i < [self.placeholderViews count]; ++i) {
            HLSContainerStack *containerStack = [[[HLSContainerStack alloc] initWithContainerViewController:self] autorelease];
            [containerStack pushViewController:[self emptyViewController] withTransitionStyle:HLSTransitionStyleNone duration:0.f];
            containerStack.containerView = [self.placeholderViews objectAtIndex:i];
            [self.containerStacks addObject:containerStack];
        }
        
        m_loadedOnce = YES;
    }
    // If the view has been unloaded, we expect the same number of placeholder views after a reload
    else {
        NSAssert([self.containerStacks count] == [self.placeholderViews count], @"The number of placeholder views has changed");
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack viewWillAppear:animated];
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack viewDidDisappear:animated];
    }
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        if (! [containerStack shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
        
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        [containerStack didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
    // TODO: If two and not displayed, pop then push. Works!
    
    
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
        [self animateAppearanceAtIndex:index animated:[self isViewVisible]];
    }        
}

#pragma mark Animation

- (void)animateAppearanceAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    HLSContainerContent *containerContent = [self containerContentAtIndex:index];
    HLSContainerContent *oldContainerContent = [self oldContainerContentAtIndex:index];
    
    NSMutableArray *containerContentStack = [NSMutableArray array];
    if (oldContainerContent) {
        [containerContentStack addObject:oldContainerContent];
    }
    [containerContentStack addObject:containerContent];
    
    UIView *placeholderView = [self.placeholderViews objectAtIndex:index];
    [containerContent pushViewControllerAnimated:animated
                       intoContainerContentStack:[NSArray arrayWithArray:containerContentStack] 
                                   containerView:placeholderView
                                        userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:index] forKey:@"index"]];
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
