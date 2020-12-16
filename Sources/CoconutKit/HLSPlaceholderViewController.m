//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSPlaceholderViewController.h"

#import "HLSContainerContent.h"
#import "HLSLogger.h"
#import "HLSPlaceholderInsetSegue.h"
#import "NSArray+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSPlaceholderViewController ()

@property (nonatomic) NSMutableArray<HLSContainerStack *> *containerStacks;

@end

@implementation HLSPlaceholderViewController {
@private
    BOOL _loadedOnce;
}

#pragma mark Object creation and destruction

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self hlsPlaceholderViewControllerInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self hlsPlaceholderViewControllerInit];
    }
    return self;
}

- (void)hlsPlaceholderViewControllerInit
{
    self.autorotationMode = HLSAutorotationModeContainer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Load view controllers initially using reserved segue identifiers. We cannot use self.placeholderViews.count
    // as loop upper limit here since the view is not loaded (and we cannot do this after -loadView has been called). 
    // Checking the first 20 indices should be sufficient
    for (NSUInteger i = 0; i < 20; ++i) {
        @try {
            NSString *segueIdentifier = [NSString stringWithFormat:@"%@%@", HLSPlaceholderPreloadSegueIdentifierPrefix, @(i)];
            [self performSegueWithIdentifier:segueIdentifier sender:nil];
        }
        @catch (NSException *exception) {
            HLSLoggerDebug(@"Exception caught but not rethrown: %@", exception);
        }
    }
}

#pragma mark Accessors and mutators

- (void)setAutorotationMode:(HLSAutorotationMode)autorotationMode
{    
    _autorotationMode = autorotationMode;
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        containerStack.autorotationMode = autorotationMode;
    }
}

- (UIView *)placeholderViewAtIndex:(NSUInteger)index
{
    if (index >= self.placeholderViews.count) {
        return nil;
    }
    return self.placeholderViews[index];
}

- (UIViewController *)insetViewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.containerStacks.count) {
        return nil;
    }
    
    HLSContainerStack *containerStack = self.containerStacks[index];
    return containerStack.topViewController;
}

- (void)setLockingUI:(BOOL)lockingUI
{
    for (HLSContainerStack *containerStack in self.containerStacks) {
        containerStack.lockingUI = lockingUI;
    }
}

- (BOOL)lockingUI
{
    // This property is consistently set for all container stacks. Return what the first says
    HLSContainerStack *firstContainerStack = self.containerStacks.firstObject;
    return firstContainerStack.lockingUI;
}

#pragma mark View lifecycle

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The first time the view is loaded, guess which number of placeholder views have been defined
    if (! _loadedOnce) {
        // View controllers have been preloaded
        if (self.containerStacks) {
            if (self.placeholderViews.count < self.containerStacks.count) {
                NSString *reason = [NSString stringWithFormat:@"Not enough placeholder views (%@) to hold preloaded view controllers (%@)",
                                    @(self.placeholderViews.count), @(self.containerStacks.count)];
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
        for (NSUInteger i = self.containerStacks.count; i < self.placeholderViews.count; ++i) {
            HLSContainerStack *containerStack = [HLSContainerStack singleControllerContainerStackWithContainerViewController:self];
            containerStack.autorotationMode = self.autorotationMode;
            containerStack.delegate = self;
            [self.containerStacks addObject:containerStack];
        }
        
        _loadedOnce = YES;
    }
    // If the view has been unloaded, we expect the same number of placeholder views after a reload
    else {
        NSAssert(self.containerStacks.count == self.placeholderViews.count, @"The number of placeholder views has changed");
    }
    
    // Associate stacks and placeholder views
    NSUInteger i = 0;
    for (HLSContainerStack *containerStack in self.containerStacks) {
        containerStack.containerView = self.placeholderViews[i];
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

- (BOOL)shouldAutorotate
{
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    for (HLSContainerStack *containerStack in self.containerStacks) {
        if (! [containerStack shouldAutorotate]) {
            return NO;
        }
    }
    
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask supportedInterfaceOrientations = [super supportedInterfaceOrientations];
    for (HLSContainerStack *containerStack in self.containerStacks) {
        supportedInterfaceOrientations &= [containerStack supportedInterfaceOrientations];
    }
    return supportedInterfaceOrientations;
}

// Remark: The status bar is not controlled by child view controllers, no explicit calls to the underlying container
//         stack methods

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
        
        for (NSUInteger i = self.containerStacks.count; i <= index; ++i) {
            HLSContainerStack *containerStack = [HLSContainerStack singleControllerContainerStackWithContainerViewController:self];
            containerStack.autorotationMode = self.autorotationMode;
            containerStack.delegate = self;
            [self.containerStacks addObject:containerStack];
        }
    }
    else {
        if (index >= self.containerStacks.count) {
            HLSLoggerError(@"Invalid index. Must be between 0 and %@", @(self.containerStacks.count - 1));
            return;
        }
    }
    
    HLSContainerStack *containerStack = self.containerStacks[index];
    if (! insetViewController) {
        if (containerStack.count > 0) {
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
