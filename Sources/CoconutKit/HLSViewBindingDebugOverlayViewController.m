//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingDebugOverlayViewController.h"

#import "HLSLogger.h"
#import "HLSViewBindingDebugOverlayApperance.h"
#import "HLSViewBindingInformationViewController.h"
#import "NSBundle+HLSExtensions.h"
#import "UIColor+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"
#import "UINavigationController+HLSExtensions.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSExtensions.h"

@import HLSMAKVONotificationCenter;

static UIWindow *s_overlayWindow = nil;
static UIWindow *s_previousKeyWindow = nil;

static NSString * const HLSViewBindingDebugOverlayUnderlyingViewKey = @"underlyingView";

@interface HLSViewBindingDebugOverlayViewController ()

@property (nonatomic, weak) UIWindow *debuggedWindow;

@property (nonatomic, weak) HLSViewBindingInformationViewController *bindingInformationViewController;

@end

@implementation HLSViewBindingDebugOverlayViewController

#pragma mark Class methods

+ (void)show
{
    if (s_overlayWindow) {
        HLSLoggerWarn(@"An overlay is already being displayed");
        return;
    }
    
    s_previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    // Ensure we exit edit mode when displaying the overlay
    [s_previousKeyWindow.firstResponderView resignFirstResponder];
    
    // Using a second window and setting our overlay as its root view controller ensures that rotation is dealt with correctly
    s_overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    s_overlayWindow.rootViewController = [[HLSViewBindingDebugOverlayViewController alloc] initWithDebuggedWindow:s_previousKeyWindow];
    [s_overlayWindow makeKeyAndVisible];
}

+ (HLSViewBindingDebugOverlayViewController *)currentBindingDebugOverlayViewController
{
    return (HLSViewBindingDebugOverlayViewController *)s_overlayWindow.rootViewController;
}

#pragma mark Class methods

// Recursively collect all scroll views in a given view
+ (NSArray *)scrollViewsInView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]]) {
        return @[view];
    }
    
    NSMutableArray *scrollViews = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        [scrollViews addObjectsFromArray:[self scrollViewsInView:subview]];
    }
    return [scrollViews copy];
}

#pragma mark Object creation and destruction

- (instancetype)initWithDebuggedWindow:(UIWindow *)debuggedWindow
{
    if (self = [super init]) {
        self.debuggedWindow = debuggedWindow;
    }
    return self;
}

#pragma mark View lifecycle

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
    
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    [view addGestureRecognizer:gestureRecognizer];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    [self displayDebugInformationForBindingsInView:self.debuggedWindow];
    
    __weak __typeof(self) weakSelf = self;
    
    // Follow the motion of underlying views if a scroll view they are in is moved
    NSArray *scrollViews = [HLSViewBindingDebugOverlayViewController scrollViewsInView:s_previousKeyWindow.rootViewController.view];
    for (UIScrollView *scrollView in scrollViews) {
        [scrollView hlsma_addObserver:self keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
            [weakSelf updateOverlayViewFrames];
        }];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateOverlayViewFrames];
}

#pragma mark Rotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & [self.debuggedWindow.rootViewController supportedInterfaceOrientations];
}

#pragma mark Debug information display

- (void)displayDebugInformationForBindingsInView:(UIView *)view
{
    HLSViewBindingInformation *bindingInformation = view.bindingInformation;
    if (bindingInformation) {
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = [self overlayViewFrameForView:view];
        
        // Border with appropriate color and width
        overlayButton.layer.borderColor = HLSViewBindingDebugOverlayBorderColor(bindingInformation.verified, bindingInformation.error != nil).CGColor;
        overlayButton.layer.borderWidth = HLSViewBindingDebugOverlayBorderWidth(bindingInformation.viewAutomaticallyUpdated);
        overlayButton.backgroundColor = HLSViewBindingDebugOverlayBackgroundColor(bindingInformation.verified,
                                                                                  bindingInformation.error != nil,
                                                                                  bindingInformation.modelAutomaticallyUpdated);
        
        overlayButton.userInfo_hls = @{ HLSViewBindingDebugOverlayUnderlyingViewKey : view };
        [overlayButton addTarget:self action:@selector(showInfos:) forControlEvents:UIControlEventTouchUpInside];
        
        // Track frame changes
        __weak UIView *weakView = view;
        __weak __typeof(self) weakSelf = self;
        [view hlsma_addObserver:self keyPath:@"frame" options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
            overlayButton.frame = [weakSelf overlayViewFrameForView:weakView];
        }];
        
        [self.view addSubview:overlayButton];
    }
    
    for (UIView *subview in view.subviews) {
        [self displayDebugInformationForBindingsInView:subview];
    }
}

- (CGRect)overlayViewFrameForView:(UIView *)view margin:(CGFloat)margin
{
    // Make the button frame surround the view
    CGRect frame = [view convertRect:view.bounds toCoordinateSpace:self.view];
    return CGRectMake(CGRectGetMinX(frame) - margin,
                      CGRectGetMinY(frame) - margin,
                      CGRectGetWidth(frame) + 2 * margin,
                      CGRectGetHeight(frame) + 2 * margin);
}

- (CGRect)overlayViewFrameForView:(UIView *)view
{
    if (view.bindingInformation) {
        return [self overlayViewFrameForView:view margin:HLSViewBindingDebugOverlayBorderWidth(view.bindingInformation.viewAutomaticallyUpdated)];
    }
    else {
        return [self overlayViewFrameForView:view margin:0.f];
    }
}

- (void)updateOverlayViewFrames
{
    for (UIView *overlayView in self.view.subviews) {
        UIView *underlyingView = overlayView.userInfo_hls[HLSViewBindingDebugOverlayUnderlyingViewKey];
        if (! underlyingView) {
            HLSLoggerWarn(@"The view %@ has no underlying view. Its frame will not be correctly updated", overlayView);
            continue;
        }
        
        overlayView.frame = [self overlayViewFrameForView:underlyingView];
    }
}

#pragma mark Highlighting

- (void)highlightView:(UIView *)view
{
    if (! view) {
        return;
    }
    
    CGRect frame = [self overlayViewFrameForView:view margin:0.f];
    UIView *highlightOverlayView = [[UIView alloc] initWithFrame:frame];
    highlightOverlayView.userInfo_hls = @{ HLSViewBindingDebugOverlayUnderlyingViewKey : view };
    highlightOverlayView.backgroundColor = [UIColor blueColor];
    highlightOverlayView.alpha = 0.f;
    [self.view addSubview:highlightOverlayView];
    
    [UIView animateWithDuration:0.2 animations:^{
        highlightOverlayView.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            highlightOverlayView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [highlightOverlayView removeFromSuperview];
        }];
    }];
}

#pragma mark Actions

- (void)close:(id)sender
{
    [s_previousKeyWindow makeKeyAndVisible];
    s_previousKeyWindow = nil;
    
    s_overlayWindow = nil;
}

- (void)showInfos:(id)sender
{
    NSAssert([sender isKindOfClass:[UIButton class]], @"Expect a button");
    UIButton *overlayButton = sender;
    UIView *underlyingView = overlayButton.userInfo_hls[HLSViewBindingDebugOverlayUnderlyingViewKey];
    HLSViewBindingInformation *bindingInformation = underlyingView.bindingInformation;
    if (! bindingInformation) {
        return;
    }
    
    HLSViewBindingInformationViewController *bindingInformationViewController = [[HLSViewBindingInformationViewController alloc] initWithBindingInformation:bindingInformation];
    UINavigationController *bindingInformationNavigationController = [[UINavigationController alloc] initWithRootViewController:bindingInformationViewController];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bindingInformationNavigationController.modalPresentationStyle = UIModalPresentationPopover;
        
        UIPopoverPresentationController *presentationController = bindingInformationNavigationController.popoverPresentationController;
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        presentationController.sourceView = self.view;
        presentationController.sourceRect = overlayButton.frame;
    }
    
    [self presentViewController:bindingInformationNavigationController animated:YES completion:nil];
}

@end
