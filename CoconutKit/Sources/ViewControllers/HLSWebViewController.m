//
//  HLSWebViewController.m
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSWebViewController.h"

#import "HLSAutorotation.h"
#import "HLSGoogleChromeActivity.h"
#import "HLSLogger.h"
#import "HLSNotifications.h"
#import "HLSSafariActivity.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

static const NSTimeInterval HLSWebViewMaxFakeDuration = 3.;
static const NSTimeInterval HLSWebViewFakeTimerInterval = 1. / 60.;
static const CGFloat HLSWebViewFakeTimerMaxProgress = 0.95f;
static const CGFloat HLSWebViewFakeTimerProgressIncrement = HLSWebViewFakeTimerMaxProgress / HLSWebViewMaxFakeDuration * HLSWebViewFakeTimerInterval;
static const NSTimeInterval HLSWebViewFadeAnimationDuration = 0.3;

@interface HLSWebViewController ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, strong) NSError *currentError;

@property (nonatomic, strong) UIImage *refreshImage;

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) WKWebView *errorWebView;

@property (nonatomic, weak) IBOutlet UIProgressView *fakeProgressView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *actions;

@property (nonatomic, strong) UIPopoverController *activityPopoverController;

@property (nonatomic, strong) NSTimer *fakeProgressTimer;

@end

@implementation HLSWebViewController {
@private
    CGFloat _progress;
}

#pragma mark Object creation and destruction

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super initWithBundle:[NSBundle coconutKitBundle]])) {
        self.request = request;
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)setFakeProgressTimer:(NSTimer *)fakeProgressTimer
{
    [_fakeProgressTimer invalidate];
    _fakeProgressTimer = fakeProgressTimer;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (isless(progress, 0.f)) {
        HLSLoggerWarn(@"Progress cannot be < 0. Fixed to 0");
        _progress = 0.f;
    }
    else if (isgreater(progress, 1.f)) {
        HLSLoggerWarn(@"Progress cannot be > 1. Fixed to 1");
        _progress = 1.f;
    }
    else {
        _progress = progress;
    }
    
    // Fake progress
    // See http://stackoverflow.com/questions/21263358/uiwebview-with-progress-bar
    if (_progress == 0.f) {
        self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:HLSWebViewFakeTimerInterval
                                                                  target:self
                                                                selector:@selector(updateProgress:)
                                                                userInfo:nil
                                                                 repeats:YES];
        self.fakeProgressView.alpha = 1.f;
    }
    else if (isgreaterequal(progress, HLSWebViewFakeTimerMaxProgress)) {
        self.fakeProgressTimer = nil;
    }
    
    // Never animated
    [self.fakeProgressView setProgress:_progress animated:NO];
    
    if (_progress == 1.f) {
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                self.fakeProgressView.alpha = 0.f;
            }];
        }
        else {
            self.fakeProgressView.alpha = 0.f;
        }
    }
}

- (CGFloat)progress
{
    return _progress;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Trick: We use outlets marked as WKWebView to avoid redundancies. On iOS 7 the web view is an old web view. Since the
    //        web view class interfaces have only slightly changed, we will use a cast where appropriate
    // TODO: Remove when CoconutKit requires at least iOS 8. Improve using new WKWebView abilities
    Class webViewClass = [WKWebView class] ?: [UIWebView class];
    
    CGRect frame = (CGRect){CGPointZero, CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolbar.frame))};
    WKWebView *webView = [[webViewClass alloc] initWithFrame:frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.alpha = 0.f;
    if ([WKWebView class]) {
        webView.navigationDelegate = self;
    }
    else {
        ((UIWebView *)webView).delegate = self;
    }
    [webView loadRequest:self.request];
    
    [self.view insertSubview:webView atIndex:0];
    self.webView = webView;
    
    WKWebView *errorWebView = [[webViewClass alloc] initWithFrame:frame];
    errorWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    errorWebView.alpha = 0.f;
    if ([WKWebView class]) {
        errorWebView.navigationDelegate = self;
    }
    else {
        ((UIWebView *)errorWebView).delegate = self;
    }
    errorWebView.scrollView.scrollEnabled = NO;
    
    NSURL *errorHTMLFileURL = [[NSBundle coconutKitBundle] URLForResource:@"HLSWebViewControllerErrorTemplate" withExtension:@"html"];
    [errorWebView loadRequest:[NSURLRequest requestWithURL:errorHTMLFileURL]];
    
    [self.view insertSubview:errorWebView atIndex:0];
    self.errorWebView = errorWebView;
    
    self.refreshImage = self.refreshBarButtonItem.image;
    self.fakeProgressView.alpha = 0.f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateInterface];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Position the progress view under the top layout guide when wrapped in a navigation controller
    self.fakeProgressView.frame = CGRectMake(CGRectGetMinX(self.fakeProgressView.frame),
                                             self.navigationController ? self.topLayoutGuide.length : 0.f,
                                             CGRectGetWidth(self.fakeProgressView.frame),
                                             CGRectGetHeight(self.fakeProgressView.frame));
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAll;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    [self updateTitle];
    [self updateErrorDescription];
}

#pragma mark Layout and display

- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Adjust the toolbar height depending on the screen orientation
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = (CGRect){CGPointMake(0.f, CGRectGetHeight(self.view.bounds) - toolbarSize.height), toolbarSize};
    self.webView.frame = (CGRect){CGPointZero, CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolbar.frame))};
    
    // Center UI elements accordingly
    self.activityIndicator.center = CGPointMake(self.activityIndicator.center.x, CGRectGetMidY(self.toolbar.frame));
}

- (void)updateInterface
{
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
    self.refreshBarButtonItem.enabled = ! self.webView.loading;
    self.refreshBarButtonItem.image = self.webView.loading ? nil : self.refreshImage;
    self.actionBarButtonItem.enabled = ! self.webView.loading && self.currentURL;
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentURL) {
        NSString *titleJavaScript = @"document.title";
        
        if ([WKWebView class]) {
            [self.webView evaluateJavaScript:titleJavaScript completionHandler:^(NSString *title, NSError *error) {
                self.title = title;
            }];
        }
        else {
            self.title = [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:titleJavaScript];
        }
    }
    else {
        self.title = CoconutKitLocalizedString(@"Untitled", nil);
    }
}

- (void)updateErrorDescription
{
    if (! self.currentError) {
        return;
    }
    
    // Error information is filled in the CFNetwork layer and escapes control of CoconutKit dynamic localization mechanism.
    // Fix by applying dynamic localization based on the error code and escape properly
    NSString *localizedEscapedDescription = [HLSLocalizedDescriptionForCFNetworkError(self.currentError.code) stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *replaceErrorJavaScript = [NSString stringWithFormat:@"document.getElementById('localizedErrorDescription').innerHTML = '%@'", localizedEscapedDescription];
    
    if ([WKWebView class]) {
        [self.errorWebView evaluateJavaScript:replaceErrorJavaScript completionHandler:nil];
    }
    else {
        [(UIWebView *)self.errorWebView stringByEvaluatingJavaScriptFromString:replaceErrorJavaScript];
    }
}

#pragma mark MFMailComposeViewControllerDelegate protocol implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    SEL action = [[self.actions objectAtIndex:buttonIndex] pointerValue];
    
    // Cannot use -performSelector here since the signature is not explicitly visible in the call for ARC to perform
    // correct memory management
    void (*methodImp)(id, SEL, id) = (void (*)(id, SEL, id))[self methodForSelector:action];
    methodImp(self, action, actionSheet);
}

#pragma mark UIPopoverControllerDelegate protocol implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSAssert(popoverController == self.activityPopoverController, @"Expect activity popover, no other popover supported yet");
    self.activityPopoverController = nil;
}

#pragma mark UIWebViewDelegate protocol implementation

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        return;
    }
    
    self.currentError = nil;
    
    [self setProgress:0.f animated:NO];
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    [self.activityIndicator startAnimating];
    
    [self updateInterface];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        // Reliably executing JavaScript requires us to wait until the error page has been loaded
        [self updateErrorDescription];
        return;
    }
    
    [self setProgress:1.f animated:YES];
    
    [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
        self.webView.alpha = 1.f;
        self.errorWebView.alpha = 0.f;
    }];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    // A new page has been displayed. Remember its URL
    if ([WKWebView class]) {
        self.currentURL = self.webView.URL;
    }
    else {
        self.currentURL = ((UIWebView *)self.webView).request.URL;
    }
    [self updateInterface];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.errorWebView) {
        return;
    }
    
    if (! [error hasCode:NSURLErrorCancelled withinDomain:NSURLErrorDomain]) {
        [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
            self.webView.alpha = 0.f;
            self.errorWebView.alpha = 1.f;
        }];
    }
    
    self.currentError = error;
    [self updateErrorDescription];
    
    [self setProgress:1.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    [self updateInterface];
}

#pragma mark WKWebViewDelegate protocol implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self webView:(WKWebView *)webView didStartProvisionalNavigation:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self webView:(WKWebView *)webView didFinishNavigation:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self webView:(WKWebView *)webView didFailProvisionalNavigation:nil withError:error];
}

#pragma mark Action callbacks

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self updateInterface];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self updateInterface];
}

- (IBAction)refresh:(id)sender
{
    // Reload the currently displayed page (if any)
    if ([[self.currentURL absoluteString] isFilled]) {
        if ([WKWebView class]) {
            [self.webView reload];
        }
        else {
            [(UIWebView *)self.webView loadRequest:((UIWebView *)self.webView).request];
        }
    }
    // Reload the start page
    else {
        [self.webView loadRequest:self.request];
    }
    
    [self updateInterface];
}

- (IBAction)displayActionSheet:(id)sender
{
    NSAssert([sender isKindOfClass:[UIBarButtonItem class]], @"Expect a bar button item");
    UIBarButtonItem *barButtonItem = sender;
    
    HLSGoogleChromeActivity *googleChromeActivity = [[HLSGoogleChromeActivity alloc] init];
    HLSSafariActivity *safariActivity = [[HLSSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.currentURL] applicationActivities:@[safariActivity, googleChromeActivity]];
    
    // iOS 8: Must set the bar button item which presents the activity popover for the iPad (automatically managed via iOS 8 UIPopoverPresentationController)
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        activityViewController.popoverPresentationController.barButtonItem = barButtonItem;
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    // iOS 7: Present as is on iPhone
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    // iOS 7: Present in manually instantiated popover
    else {
        self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        self.activityPopoverController.delegate = self;
        [self.activityPopoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark Timer callbacks

- (void)updateProgress:(NSTimer *)timer
{
    // 33% update chance to make fake progress more realistic
    if (arc4random_uniform(3) == 0) {
        [self setProgress:[self progress] + HLSWebViewFakeTimerProgressIncrement animated:YES];
    }
}

@end
