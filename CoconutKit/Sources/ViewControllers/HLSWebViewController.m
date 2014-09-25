//
//  HLSWebViewController.m
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSWebViewController.h"

#import "HLSAutorotation.h"
#import "HLSNotifications.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

@interface HLSWebViewController ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *currentURL;

@property (nonatomic, strong) UIImage *refreshImage;

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *actions;

@end

@implementation HLSWebViewController

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super initWithBundle:[NSBundle coconutKitBundle]])) {
        self.request = request;
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshImage = self.refreshBarButtonItem.image;
    
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

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
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
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // Safe, methods return void
    [self performSelector:action withObject:actionSheet];
#pragma clang diagnostic pop
}

#pragma mark UIWebViewDelegate protocol implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    [self.activityIndicator startAnimating];
    
    [self updateInterface];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    // A new page has been displayed. Remember its URL
    self.currentURL = [self.webView.request URL];
    
    [self updateInterface];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
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
    NSURL *webViewURL = [self.webView.request URL];
    
    // Reload the currently displayed page (if any)
    if ([[webViewURL absoluteString] isFilled]) {
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
    NSMutableArray *actions = [NSMutableArray array];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = [self.currentURL absoluteString];
    actionSheet.delegate = self; 
    
    [actionSheet addButtonWithTitle:CoconutKitLocalizedString(@"Open in Safari", nil)];
    [actions addObject:[NSValue valueWithPointer:@selector(openInSafari:)]];
    
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:CoconutKitLocalizedString(@"Mail Link", nil)];
        [actions addObject:[NSValue valueWithPointer:@selector(mailLink:)]];
    }
    
    self.actions = [NSArray arrayWithArray:actions];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:HLSLocalizedStringFromUIKit(@"Cancel")];
    }
    [actionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
}

- (void)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:[self.webView.request URL]];
}

- (void)mailLink:(id)sender
{
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:self.title];
    [mailComposeViewController setMessageBody:[[self.webView.request URL] absoluteString] isHTML:NO];
    [self presentViewController:mailComposeViewController animated:YES completion:nil];
}

@end
