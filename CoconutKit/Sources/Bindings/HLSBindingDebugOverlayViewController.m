//
//  HLSBindingsDebugOverlayViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingDebugOverlayViewController.h"

#import "HLSAssert.h"
#import "HLSBindingInformationViewController.h"
#import "HLSLogger.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSExtensions.h"

static UIWindow *s_overlayWindow = nil;
static UIWindow *s_previousKeyWindow = nil;

@interface HLSBindingDebugOverlayViewController ()

@property (nonatomic, weak) UIViewController *debuggedViewController;
@property (nonatomic, assign, getter=isRecursive) BOOL recursive;

@property (nonatomic, strong) UIPopoverController *bindingInformationPopoverController;

@end

@implementation HLSBindingDebugOverlayViewController

#pragma mark Class methods

+ (void)showForDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    if (s_overlayWindow) {
        HLSLoggerWarn(@"An overlay is already being displayed");
        return;
    }
    
    s_previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    // Using a second window and setting our overlay as its root view controller ensures that rotation is dealt with correctly
    s_overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    s_overlayWindow.rootViewController = [[HLSBindingDebugOverlayViewController alloc] initWithDebuggedViewController:debuggedViewController recursive:recursive];
    [s_overlayWindow makeKeyAndVisible];
}

#pragma mark Object creation and destruction

- (id)initWithDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    if (self = [super init]) {
        self.debuggedViewController = debuggedViewController;
        self.recursive = recursive;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
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
    
    [self displayDebugInformationForBindingsInView:self.debuggedViewController.view
                            debuggedViewController:self.debuggedViewController
                                         recursive:self.recursive];
}

#pragma mark Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Workaround rotation glitches with multiple windows (black screen)
    s_overlayWindow.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // See above
    s_overlayWindow.hidden = NO;
}

#pragma mark Debug information display

- (void)displayDebugInformationForBindingsInView:(UIView *)view
                          debuggedViewController:(UIViewController *)debuggedViewController
                                       recursive:(BOOL)recursive
{
    if (! recursive && view.nearestViewController != debuggedViewController) {
        return;
    }
    
    HLSViewBindingInformation *bindingInformation = view.bindingInformation;
    if (bindingInformation) {
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = [view convertRect:view.bounds toView:self.view];
        overlayButton.layer.borderColor = bindingInformation.verified ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        overlayButton.layer.borderWidth = 2.f;
        overlayButton.userInfo_hls = @{@"bindingInformation" : bindingInformation};
        [overlayButton addTarget:self action:@selector(showInfos:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:overlayButton];
    }
    
    for (UIView *subview in view.subviews) {
        [self displayDebugInformationForBindingsInView:subview debuggedViewController:debuggedViewController recursive:recursive];
    }
}

#pragma mark UIPopoverControllerDelegate protocol implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.bindingInformationPopoverController = nil;
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
    NSAssert([sender isKindOfClass:[UIView class]], @"Expect a view");
    UIView *view = sender;
    HLSViewBindingInformation *bindingInformation = view.userInfo_hls[@"bindingInformation"];
    
    HLSBindingInformationViewController *bindingInformationViewController = [[HLSBindingInformationViewController alloc] initWithBindingInformation:bindingInformation];
    self.bindingInformationPopoverController = [[UIPopoverController alloc] initWithContentViewController:bindingInformationViewController];
    [self.bindingInformationPopoverController presentPopoverFromRect:view.frame
                                                              inView:self.view
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];
}

@end
