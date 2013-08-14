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
#import "HLSPlaceholderInsetSegue.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSPlaceholderViewController ()

@property (nonatomic, retain) NSMutableArray *containerStacks;

@end

@implementation HLSPlaceholderViewController {
@private
    BOOL _loadedOnce;
}

#pragma mark Object creation and destruction

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Load view controllers initially using reserved segue identifiers. We cannot use [self.placeholderViews count]
    // as loop upper limit here since the view is not loaded (and we cannot do this after -loadView has been called). 
    // Checking the first 20 indices should be sufficient
    for (NSUInteger i = 0; i < 20; ++i) {
        @try {
            NSString *segueIdentifier = [NSString stringWithFormat:@"%@%d", HLSPlaceholderPreloadSegueIdentifierPrefix, i];
            [self performSegueWithIdentifier:segueIdentifier sender:self];
        }
        @catch (NSException *exception) {
            HLSLoggerDebug(@"Exception caught but not rethrown: %@", exception);
        }
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

- (UIView *)placeholderViewAtIndex:(NSUInteger)index
{
    if (index >= [self.placeholderViews count]) {
        return nil;
    }
    return [self.placeholderViews objectAtIndex:index];
}

- (UIViewController *)insetViewControllerAtIndex:(NSUInteger)index
{
    if (index >= [self.containerStacks count]) {
        return nil;
    }
    
    HLSContainerStack *containerStack = [self.containerStacks objectAtIndex:index];
    return [containerStack topViewController];
}

#pragma mark View lifecycle

// Deprecated since iOS 6
- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The order of outlets within an IBOutletCollection is sadly not the one defined in the nib file. Expect the user
    // to explictly order them using the UIView tag property, and warn if this was not done properly. This is not an
    // issue if the placeholder views are set programmatically
    // (also see rdar://12121242: This issue seems to affect storyboards only)
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
    if (! _loadedOnce) {
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
        
        // We need to have a stack for each placeholder view
        for (NSUInteger i = [self.containerStacks count]; i < [self.placeholderViews count]; ++i) {
            HLSContainerStack *containerStack = [HLSContainerStack singleControllerContainerStackWithContainerViewController:self];
            containerStack.delegate = self;
            [self.containerStacks addObject:containerStack];
        }
        
        _loadedOnce = YES;
    }
    // If the view has been unloaded, we expect the same number of placeholder views after a reload
    else {
        NSAssert([self.containerStacks count] == [self.placeholderViews count], @"The number of placeholder views has changed");
    }
    
    // Associate stacks and placeholder views
    NSUInteger i = 0;
    for (HLSContainerStack *containerStack in self.containerStacks) {
        containerStack.containerView = [self.placeholderViews objectAtIndex:i];
        ++i;
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

// Remark: -shouldAutorotate and -supportedInterfaceOrientations are NOT implemented by HLSPlaceholderViewController.
//         Since HLSContainerStack can display view controllers in any orientation, this would not make sense. The
//         container orientation is therefore the one it defines (supports all orientations by default)

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
             withTransitionClass:[HLSTransitionNone class]];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass
{
    [self setInsetViewController:insetViewController 
                         atIndex:index
             withTransitionClass:transitionClass
                        duration:kAnimationTransitionDefaultDuration];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
                       atIndex:(NSUInteger)index
           withTransitionClass:(Class)transitionClass
                      duration:(NSTimeInterval)duration
{
    // Grows up the list of stacks as necessary while the container still can be implicitly resized (that is, when
    // it has not been loaded once)
    if (! _loadedOnce) {
        if (! self.containerStacks) {
            self.containerStacks = [NSMutableArray array];
        }
        
        for (NSUInteger i = [self.containerStacks count]; i <= index; ++i) {
            HLSContainerStack *containerStack = [HLSContainerStack singleControllerContainerStackWithContainerViewController:self];
            containerStack.delegate = self;
            [self.containerStacks addObject:containerStack];
        }
    }
    else {
        if (index >= [self.containerStacks count]) {
            HLSLoggerError(@"Invalid index. Must be between 0 and %d", [self.containerStacks count] - 1);
            return;
        }
    }
    
    HLSContainerStack *containerStack = [self.containerStacks objectAtIndex:index];
    if (! insetViewController) {
        if ([containerStack count] > 0) {
            [containerStack popViewControllerAnimated:YES];
        }
        return;
    }
    
    [containerStack pushViewController:insetViewController
                   withTransitionClass:transitionClass
                              duration:duration
                              animated:YES];       
}

#pragma mark HLSContainerStackDelegate protocol implementation

- (void)containerStack:(HLSContainerStack *)containerStack
willPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated
{
    // Not interesting in the present case
}

- (void)containerStack:(HLSContainerStack *)containerStack
willShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated
{
    NSUInteger index = [self.containerStacks indexOfObject:containerStack];
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:atIndex:animated:)]) {
        [self.delegate placeholderViewController:self willShowInsetViewController:viewController atIndex:index animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
 didShowViewController:(UIViewController *)viewController
              animated:(BOOL)animated
{
    NSUInteger index = [self.containerStacks indexOfObject:containerStack];
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:atIndex:animated:)]) {
        [self.delegate placeholderViewController:self didShowInsetViewController:viewController atIndex:index animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
 didPushViewController:(UIViewController *)pushedViewController
   coverViewController:(UIViewController *)coveredViewController
              animated:(BOOL)animated
{
    // Not interesting in the present case
}

- (void)containerStack:(HLSContainerStack *)containerStack
 willPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated
{
    // Not interesting in the present case
}

- (void)containerStack:(HLSContainerStack *)containerStack
willHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated
{
    NSUInteger index = [self.containerStacks indexOfObject:containerStack];
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:willHideInsetViewController:atIndex:animated:)]) {
        [self.delegate placeholderViewController:self willHideInsetViewController:viewController atIndex:index animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
 didHideViewController:(UIViewController *)viewController
              animated:(BOOL)animated
{
    NSUInteger index = [self.containerStacks indexOfObject:containerStack];
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:didHideInsetViewController:atIndex:animated:)]) {
        [self.delegate placeholderViewController:self didHideInsetViewController:viewController atIndex:index animated:animated];
    }
}

- (void)containerStack:(HLSContainerStack *)containerStack
  didPopViewController:(UIViewController *)poppedViewController
  revealViewController:(UIViewController *)revealedViewController
              animated:(BOOL)animated
{
    // Not interesting in the present case
}

@end

@implementation UIViewController (HLSPlaceholderViewController)

- (HLSPlaceholderViewController *)placeholderViewController
{
    return [self containerViewControllerKindOfClass:[HLSPlaceholderViewController class]];
}

@end
