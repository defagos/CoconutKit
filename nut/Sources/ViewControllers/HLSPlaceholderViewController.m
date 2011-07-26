//
//  HLSPlaceholderViewController.m
//  nut
//
//  Created by Samuel Défago on 10/8/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSPlaceholderViewController.h"

#import <objc/runtime.h>
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSOrientationCloner.h"
#import "HLSTransform.h"

// TODO: Implement stretching when property is updated as well (see setStretchingContent in HLSStackController)

// TODO: As in HLSStackController, call some unregister method when deallocating (must cleanup associated objects)

@interface HLSPlaceholderViewController ()

@property (nonatomic, retain) UIViewController *oldInsetViewController;

@end

@implementation HLSPlaceholderViewController

#pragma mark Inset View Controller properties forwarding

static void *HLSPlaceholderViewControllerKey = &HLSPlaceholderViewControllerKey;

static id(*UIViewController__navigationController)(id, SEL) = NULL;
static id(*UIViewController__navigationItem)(id, SEL) = NULL;
static id(*UIViewController__title)(id, SEL) = NULL;

static id placeholderForward(UIViewController *self, SEL _cmd)
{
    id(*UIViewControllerMethod)(id, SEL) = NULL;
    if (_cmd == @selector(navigationController)) {
        UIViewControllerMethod = UIViewController__navigationController;
    }
    else if (_cmd == @selector(navigationItem)) {
        UIViewControllerMethod = UIViewController__navigationItem;
    }
    else if (_cmd == @selector(title)) {
        UIViewControllerMethod = UIViewController__title;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    HLSPlaceholderViewController *placeholderViewController = objc_getAssociatedObject(self, HLSPlaceholderViewControllerKey);
    if (placeholderViewController && placeholderViewController.forwardInsetViewControllerProperties) {
        return UIViewControllerMethod(placeholderViewController, _cmd);
    }
    else {
        return UIViewControllerMethod(self, _cmd);
    }
}

+ (void)load
{
    UIViewController__navigationController = (id(*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationController), (IMP)placeholderForward, NULL);
    UIViewController__navigationItem = (id(*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationItem), (IMP)placeholderForward, NULL);
    UIViewController__title = (id(*)(id, SEL))class_replaceMethod([UIViewController class], @selector(title), (IMP)placeholderForward, NULL);
}

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.insetViewController = nil;
    self.oldInsetViewController = nil;
    self.placeholderView = nil;
    self.delegate = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.placeholderView = nil;
}

#pragma mark Accessors and mutators

@synthesize insetViewController = m_insetViewController;

- (void)setInsetViewController:(UIViewController *)insetViewController
{
    [self setInsetViewController:insetViewController withTransitionStyle:HLSTransitionStyleNone];
}

- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
{
    [self setInsetViewController:insetViewController withTransitionStyle:transitionStyle duration:kAnimationTransitionDefaultDuration];
}

// TODO: When bringToFront is set to YES for HLSAnimation (which is the case here), we can change the z-order of views during the animation.
//       This could let create funny effects (e.g. shuffling views: the new inset is below the new one, both centered; the old one moves to 
//       the left, the new one to the right. When their borders match, the new one is brought on top, the old one to the bottom, and
//       both are moved to the center again.
- (void)setInsetViewController:(UIViewController *)insetViewController
           withTransitionStyle:(HLSTransitionStyle)transitionStyle
                      duration:(NSTimeInterval)duration
{    
    // If not changed, nothing to do
    if (m_insetViewController == insetViewController) {
        return;
    }
    
    // Check that the new inset can be displayed for the current orientation
    if ([self isViewVisible]) {
        if (! [insetViewController shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
            HLSLoggerError(@"The inset view controller cannot be set because it does not support the current interface orientation");
            return;
        }
    }
    
    // Associate the view controller with its container
    if (insetViewController) {
        NSAssert(! objc_getAssociatedObject(insetViewController, HLSPlaceholderViewControllerKey), @"A view controller can only be inserted into one placeholder view controller");
        objc_setAssociatedObject(insetViewController, HLSPlaceholderViewControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    }
    
    // Remove any existing inset first
    if (m_insetViewAddedAsSubview) {
        // If the container is visible, deal with animation and lifecycle events for the old inset view
        if ([self isViewVisible]) {
            // Animated
            if (transitionStyle != HLSTransitionStyleNone) {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:YES];
                m_insetViewAddedAsSubview = NO;
                
                // Keep a ref to the removed view controller (and save settings) so that it can stay alive until it is removed
                self.oldInsetViewController = m_insetViewController;
                m_oldOriginalInsetViewTransform = m_originalInsetViewTransform;
                m_oldOriginalInsetViewAlpha = m_originalInsetViewAlpha;                
            }
            // Not animated
            else {
                // Forward disappearance events
                [m_insetViewController viewWillDisappear:NO];
                m_insetViewAddedAsSubview = NO;
                
                // Remove the view
                [m_insetViewController.view removeFromSuperview];
                
                // Forward disappearance events
                [m_insetViewController viewDidDisappear:NO];
                
                // Restore the original view properties we might have altered during the time the view controller was
                // set as inset
                m_insetViewController.view.transform = m_originalInsetViewTransform;
                m_insetViewController.view.alpha = m_originalInsetViewAlpha;
                
                // Remove the old view controller association with its container
                NSAssert(objc_getAssociatedObject(m_insetViewController, HLSPlaceholderViewControllerKey), @"The view controller was not inserted into a placeholder view controller");
                objc_setAssociatedObject(m_insetViewController, HLSPlaceholderViewControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
            }
        }
    }
    
    // Change the view controller
    [m_insetViewController release];
    m_insetViewController = [insetViewController retain];
    
    // Add the new inset if the placeholder is available
    if (m_insetViewController && [self isViewLoaded]) {
        // Instantiate the view lazily (if it has not been already been instantiated, which should be the case in most
        // situations). This will trigger the associated viewDidLoad
        UIView *insetView = m_insetViewController.view;
        
        // Save original parameters which can get altered by view controller animations; this way we can restore the original
        // state of the view controller's view when it gets removed. This allows callers to cache the view controller (and its
        // view) for reusing them at a later time. We must restore these parameters since the caller must expect to be able
        // to reuse a view in the same state existing before the view controller was assigned as inset
        m_originalInsetViewTransform = insetView.transform;
        m_originalInsetViewAlpha = insetView.alpha;
        
        // If already visible, forward appearance events (this event here correctly occurs after viewDidLoad)
        if ([self isViewVisible]) {
            // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
            // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
            // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
            if (self.stretchingContent) {
                // Cannot apply a transform here; we must adjust the frame for autoresizing behavior to occur
                self.insetViewController.view.frame = self.placeholderView.bounds;
            }
            
            // Animated
            if (transitionStyle != HLSTransitionStyleNone) {
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                 willShowInsetViewController:m_insetViewController 
                                                    animated:YES];
                }
                
                // Forward appearance events
                [m_insetViewController viewWillAppear:YES];
                m_insetViewAddedAsSubview = YES;
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
            }
            // Not animated
            else {                
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                 willShowInsetViewController:m_insetViewController 
                                                    animated:NO];
                } 
                
                // Forward appearance events
                [m_insetViewController viewWillAppear:NO];
                m_insetViewAddedAsSubview = YES;                
                
                // Add the inset
                [self.placeholderView addSubview:insetView];
                
                // Notify the delegate
                if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
                    [self.delegate placeholderViewController:self
                                  didShowInsetViewController:m_insetViewController 
                                                    animated:NO];
                }
                
                // Forward appearance events
                [m_insetViewController viewDidAppear:NO];          
            }
        }
        // Not visible or disappearing
        else {
            // Add the inset
            [self.placeholderView addSubview:insetView];
            m_insetViewAddedAsSubview = YES;            
        }
    }
    
    // Create the animation if any
    if (transitionStyle != HLSTransitionStyleNone) {
        UIView *oldInsetView = self.oldInsetViewController.view;
        UIView *newInsetView = m_insetViewController.view;
        
        HLSAnimation *animation = [HLSAnimation animationForTransitionStyle:transitionStyle
                                                      withDisappearingViews:[NSArray arrayWithObject:oldInsetView] 
                                                             appearingViews:[NSArray arrayWithObject:newInsetView] 
                                                                commonFrame:self.placeholderView.frame
                                                                   duration:duration];        
        animation.lockingUI = YES;
        animation.bringToFront = YES;
        animation.delegate = self;
        
        // Animation occurs if the container is visible
        if ([self isViewVisible]) {
            [animation playAnimated:YES];
        }
        else {
            [animation playAnimated:NO];
        }
    }
}

@synthesize oldInsetViewController = m_oldInsetViewController;

@synthesize placeholderView = m_placeholderView;

@synthesize stretchingContent = m_stretchingContent;

@synthesize forwardInsetViewControllerProperties = m_forwardInsetViewControllerProperties;

@synthesize delegate = m_delegate;

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
    
    // If an inset has been defined but not displayed yet, add it (remark: This is not done in viewDidLoad since only
    // now are the placeholder view dimensions known)
    if (self.insetViewController && ! m_insetViewAddedAsSubview) {
        UIView *insetView = self.insetViewController.view;
        
        // Save original parameters which can get altered by view controller animations; this way we can restore the original
        // state of the view controller's view when it gets removed. This allows callers to cache the view controller (and its
        // view) for reusing them at a later time. We must restore these parameters since the caller must expect to be able
        // to reuse a view in the same state existing before the view controller was assigned as inset
        m_originalInsetViewTransform = insetView.transform;
        m_originalInsetViewAlpha = insetView.alpha;
        
        [self.placeholderView addSubview:insetView];
        m_insetViewAddedAsSubview = YES;
    }
    
    if (m_insetViewAddedAsSubview) {
        // Adjust the frame to get proper autoresizing behavior (if autoresizesSubviews has been enabled for the placeholder
        // view). This is carefully made before notifying the inset view controller that it will appear, so that clients can
        // safely rely on the fact that dimensions of view controller's views have been set before viewWillAppear gets called
        if (self.stretchingContent) {
            // Cannot apply a transform here; we must adjust the frame for autoresizing behavior to occur
            self.insetViewController.view.frame = self.placeholderView.bounds;
        }
        
        // Notify the delegate
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:willShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                         willShowInsetViewController:self.insetViewController 
                                            animated:animated];
        } 
        
        [self.insetViewController viewWillAppear:animated];
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_insetViewAddedAsSubview) {
        // Notify the delegate
        if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
            [self.delegate placeholderViewController:self
                          didShowInsetViewController:self.insetViewController 
                                            animated:animated];
        }        
        
        [self.insetViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (m_insetViewAddedAsSubview) {
        [self.insetViewController viewDidDisappear:animated];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if (m_insetViewAddedAsSubview) {
        self.insetViewController.view = nil;
        m_insetViewAddedAsSubview = NO;
        
        [self.insetViewController viewDidUnload];
    }
}

#pragma mark Orientation management (these methods are only called if the view controller is visible)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    // If no inset has been defined, let the placeholder rotate
    if (! self.insetViewController) {
        return YES;
    }
    
    return [self.insetViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]
        || [self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)];    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{   
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If no inset has been defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    // If the view controller can rotate by cloning, clone it. Since we use 1-step rotation (smoother, default since iOS3),
    // we cannot swap it in the middle of the animation. Instead, we use a cross-dissolve transition so that the change
    // happens smoothly during the rotation
    if ([self.insetViewController conformsToProtocol:@protocol(HLSOrientationCloner)]) {
        UIViewController<HLSOrientationCloner> *cloneableInsetViewController = (UIViewController<HLSOrientationCloner> *)self.insetViewController;
        UIViewController *clonedInsetViewController = [cloneableInsetViewController viewControllerCloneWithOrientation:toInterfaceOrientation];
        [self setInsetViewController:clonedInsetViewController 
                 withTransitionStyle:HLSTransitionStyleCrossDissolve
                            duration:duration];
    }
    
    [self.oldInsetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // If no inset defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    [self.oldInsetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.insetViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // If no inset defined, we are done
    if (! self.insetViewController) {
        return;
    }
    
    // Remark: We could have feared that oldInsetViewController is nil when the rotation animation ends (since the
    //         cross-fade animation is supposed to end at the same time and could have released it). Well, it seems
    //         to work correctly, oldViewController is not nil and receives the event correctly. I do not want to
    //         add cumbersome code for this now, let's wait and see if problems arise
    [self.oldInsetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.insetViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    if ([self.insetViewController conformsToProtocol:@protocol(HLSReloadable)]) {
        UIViewController<HLSReloadable> *reloadableInsetViewController = (UIViewController<HLSReloadable> *)self.insetViewController;
        [reloadableInsetViewController reloadData];
    }
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    // The old inset view controller has disappeared
    [self.oldInsetViewController.view removeFromSuperview];
    [self.oldInsetViewController viewDidDisappear:animated];
    
    // Restore the original view properties we might have altered during the time the view controller was
    // set as inset
    self.oldInsetViewController.view.transform = m_oldOriginalInsetViewTransform;
    self.oldInsetViewController.view.alpha = m_oldOriginalInsetViewAlpha;
    
    // Remove the old view controller association with its container
    NSAssert(objc_getAssociatedObject(self.oldInsetViewController, HLSPlaceholderViewControllerKey), @"The view controller was not inserted into a placeholder view controller");
    objc_setAssociatedObject(self.oldInsetViewController, HLSPlaceholderViewControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    // Done with the old inset view controller.
    self.oldInsetViewController = nil;
    m_oldOriginalInsetViewTransform = CGAffineTransformIdentity;
    m_oldOriginalInsetViewAlpha = 0.f;
    
    // Notify the delegate
    if ([self.delegate respondsToSelector:@selector(placeholderViewController:didShowInsetViewController:animated:)]) {
        [self.delegate placeholderViewController:self
                      didShowInsetViewController:self.insetViewController 
                                        animated:animated];
    } 
    
    // Forward appearance event of the new inset
    [self.insetViewController viewDidAppear:animated];
}

@end

@implementation UIViewController (HLSPlaceholderViewController)

- (HLSPlaceholderViewController *)placeholderViewController
{
    return objc_getAssociatedObject(self, HLSPlaceholderViewControllerKey);
}

@end
