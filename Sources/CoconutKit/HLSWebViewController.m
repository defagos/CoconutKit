//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSWebViewController.h"

#import "HLSApplicationInformation.h"
#import "HLSAutorotation.h"
#import "HLSGoogleChromeActivity.h"
#import "HLSKeyboardInformation.h"
#import "HLSLogger.h"
#import "HLSNotifications.h"
#import "HLSSafariActivity.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"

@import MessageUI;

static void *s_KVOContext = &s_KVOContext;

static const NSTimeInterval HLSWebViewFadeAnimationDuration = 0.3;

@interface HLSWebViewController ()

@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSURL *currentURL;
@property (nonatomic) NSError *currentError;

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) WKWebView *errorWebView;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *actionBarButtonItem;

@property (nonatomic) NSArray<UIBarButtonItem *> *normalToolbarItems;
@property (nonatomic) NSArray<UIBarButtonItem *> *loadingToolbarItems;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;

@property (nonatomic) NSArray<NSValue *> *actions;

@end

@implementation HLSWebViewController {
@private
    CGFloat _progress;
}

#pragma mark Object creation and destruction

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    NSParameterAssert(request);
    
    if (self = [super initWithBundle:SWIFTPM_MODULE_BUNDLE]) {
        self.request = request;
    }
    return self;
}

- (void)dealloc
{
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    @catch (NSException *exception) {}
}

#pragma mark Accessors and mutators

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
    
    if (_progress == 0.f) {
        if (animated) {
            [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
                self.progressView.alpha = 1.f;
            }];
        }
        else {
            self.progressView.alpha = 1.f;
        }
    }
    
    // Never animated
    [self.progressView setProgress:_progress animated:animated];
    
    if (_progress == 1.f) {
        if (animated) {
            [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
                self.progressView.alpha = 0.f;
            } completion:^(BOOL finished) {
                // Reset the progress bar
                self.progressView.progress = 0.f;
            }];
        }
        else {
            self.progressView.alpha = 0.f;
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
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.alpha = 0.f;
    webView.navigationDelegate = self;
    [webView loadRequest:self.request];
    
    // Progress information is available from WKWebView
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:s_KVOContext];
    
    // Scroll view content insets are adjusted automatically, but only for the scroll view at index 0. This
    // is the main content web view, we therefore put it at index 0
    [self.view insertSubview:webView atIndex:0];
    self.webView = webView;
    
    WKWebView *errorWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    errorWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    errorWebView.alpha = 0.f;
    errorWebView.navigationDelegate = self;
    errorWebView.userInteractionEnabled = NO;
    
    NSURL *errorHTMLFileURL = [SWIFTPM_MODULE_BUNDLE URLForResource:@"HLSWebViewControllerErrorTemplate" withExtension:@"html"];
    [errorWebView loadRequest:[NSURLRequest requestWithURL:errorHTMLFileURL]];
    
    // No automatic scroll inset adjustment, but not a problem since the error view displays static centered content
    [self.view insertSubview:errorWebView atIndex:1];
    self.errorWebView = errorWebView;
    
    self.progressView.alpha = 0.f;
    self.normalToolbarItems = self.toolbar.items;
    
    // Build the toolbar displayed when the web view is loading content
    NSMutableArray *loadingToolbarItems = [self.normalToolbarItems mutableCopy];
    UIBarButtonItem *stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                       target:self
                                                                                       action:@selector(stop:)];
    loadingToolbarItems[[loadingToolbarItems indexOfObject:self.refreshBarButtonItem]] = stopBarButtonItem;
    self.loadingToolbarItems = [loadingToolbarItems copy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateInterfaceAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    [self updateTitle];
    [self updateErrorDescription];
}

#pragma mark Layout and display

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout];
}

- (void)updateLayout
{
    CGFloat toolbarHeight = [self.toolbar sizeThatFits:self.view.bounds.size].height;
    self.toolbarHeightConstraint.constant = toolbarHeight;
    
    UIScrollView *scrollView = self.webView.scrollView;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    HLSKeyboardInformation *keyboardInformation = [HLSKeyboardInformation keyboardInformation];
    if (keyboardInformation) {
        contentInset.bottom = CGRectGetHeight(keyboardInformation.endFrame);
        
        // Take into account bottom inset, most notably for iPhone X
        if (@available(iOS 11.0, *)) {
            contentInset.bottom -= self.view.safeAreaInsets.bottom;
        }
    }
    else {
        contentInset.bottom = toolbarHeight;
    }
    
    scrollView.scrollIndicatorInsets = contentInset;
}

- (void)updateInterfaceAnimated:(BOOL)animated
{
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
    
    BOOL isLoading = self.webView.loading;
    if (isLoading) {
        [self.toolbar setItems:self.loadingToolbarItems animated:animated];
    }
    else {
        [self.toolbar setItems:self.normalToolbarItems animated:animated];
    }
    
    self.actionBarButtonItem.enabled = ! isLoading && self.currentURL;
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentURL) {
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
            self.title = title;
        }];
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
    if ([localizedEscapedDescription isEqualToString:HLSMissingLocalization]) {
        localizedEscapedDescription = [HLSLocalizedDescriptionForCFNetworkError(kCFURLErrorUnknown) stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    }
    NSString *replaceErrorJavaScript = [NSString stringWithFormat:@"document.getElementById('localizedErrorDescription').innerHTML = '%@'", localizedEscapedDescription];
    [self.errorWebView evaluateJavaScript:replaceErrorJavaScript completionHandler:nil];
}

#pragma mark MFMailComposeViewControllerDelegate protocol implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark WKWebViewDelegate protocol implementation

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        return;
    }
    
    if (self.errorWebView.alpha == 1.f) {
        [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
            self.errorWebView.alpha = 0.f;
        }];
    }
    
    self.currentError = nil;
    
    [self setProgress:0.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    
    [self updateInterfaceAnimated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        // Reliably executing JavaScript requires us to wait until the error page has been loaded
        [self updateErrorDescription];
        return;
    }
    
    [UIView animateWithDuration:HLSWebViewFadeAnimationDuration animations:^{
        self.webView.alpha = 1.f;
        self.errorWebView.alpha = 0.f;
    }];
    
    [self setProgress:1.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    self.currentURL = self.webView.URL;
    
    [self updateInterfaceAnimated:YES];
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
        
        self.currentError = error;
        [self updateErrorDescription];
    }
    
    [self setProgress:1.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    [self updateInterfaceAnimated:YES];
}

#pragma mark Action callbacks

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self updateInterfaceAnimated:YES];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self updateInterfaceAnimated:YES];
}

- (IBAction)refresh:(id)sender
{
    // Reload the currently displayed page (if any)
    if (self.currentURL.absoluteString.filled) {
        [self.webView reload];
    }
    // Reload the start page
    else {
        [self.webView loadRequest:self.request];
    }
    [self updateInterfaceAnimated:YES];
}

- (void)stop:(id)sender
{
    [self.webView stopLoading];
    [self updateInterfaceAnimated:YES];
}

- (IBAction)displayActionSheet:(id)sender
{
    NSAssert([sender isKindOfClass:[UIBarButtonItem class]], @"Expect a bar button item");
    UIBarButtonItem *barButtonItem = sender;
    
    HLSGoogleChromeActivity *googleChromeActivity = [[HLSGoogleChromeActivity alloc] init];
    HLSSafariActivity *safariActivity = [[HLSSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.currentURL] applicationActivities:@[safariActivity, googleChromeActivity]];
    activityViewController.popoverPresentationController.barButtonItem = barButtonItem;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != s_KVOContext) {
        return;
    }
    
    // Check if loading since progress information can be received before -webView:didStartProvisionalNavigation:, which
    // initially resets progress to 0
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"] && self.webView.loading) {
        [self setProgress:self.webView.estimatedProgress animated:YES];
    }
}

#pragma mark Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self updateLayout];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self updateLayout];
}

@end
