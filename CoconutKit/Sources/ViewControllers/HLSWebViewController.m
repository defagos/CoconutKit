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

@interface HLSWebViewController ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, strong) UIImage *refreshImage;

@property (nonatomic, weak) IBOutlet UIWebView *webView;
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
    
    self.refreshImage = self.refreshBarButtonItem.image;
    self.fakeProgressView.alpha = 0.f;
    
    self.webView.delegate = self;
    [self.webView loadRequest:self.request];
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
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else {
        self.title = CoconutKitLocalizedString(@"Untitled", nil);
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self setProgress:0.f animated:NO];
    
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    [self.activityIndicator startAnimating];
    
    [self updateInterface];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setProgress:1.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    // A new page has been displayed. Remember its URL
    self.currentURL = [self.webView.request URL];
    
    [self updateInterface];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setProgress:1.f animated:YES];
    
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    [self updateInterface];
    
    // We can also encounter other types of errors here (e.g. if a user clicks on two links consecutively on the same page. 
    // The first request is cancelled and ends with NSURLErrorCancelled)
    if ([error hasCode:NSURLErrorNotConnectedToInternet withinDomain:NSURLErrorDomain]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CoconutKitLocalizedString(@"Cannot Open Page", nil)
                                                            message:CoconutKitLocalizedString(@"No Internet connection is available", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:HLSLocalizedStringFromUIKit(@"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
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
        [self.webView loadRequest:self.webView.request];
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
