
//
//  HLSWebViewController.m
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSWebViewController.h"

#import "HLSActionSheet.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "HLSNotifications.h"

@interface HLSWebViewController ()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) UIImage *refreshImage;

- (void)openInSafari:(id)sender;
- (void)mailLink:(id)sender;

@end

@implementation HLSWebViewController

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super initWithNibName:@"CoconutKit_HLSWebViewController" bundle:nil])) {
        self.request = request;
    }
    return self;
}

- (void)dealloc
{
    self.request = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.webView = nil;
    self.toolbar = nil;
    self.goBackBarButtonItem = nil;
    self.goForwardBarButtonItem = nil;
    self.refreshBarButtonItem = nil;
    self.actionBarButtonItem = nil;
    self.activityIndicator = nil;
    self.refreshImage = nil;
}

#pragma mark Accessors and mutators

@synthesize request = m_request;

@synthesize webView = m_webView;

@synthesize toolbar = m_toolbar;

@synthesize goBackBarButtonItem = m_goBackBarButtonItem;

@synthesize goForwardBarButtonItem = m_goForwardBarButtonItem;

@synthesize refreshBarButtonItem = m_refreshBarButtonItem;

@synthesize actionBarButtonItem = m_actionBarButtonItem;

@synthesize activityIndicator = m_activityIndicator;

@synthesize refreshImage = m_refreshImage;

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
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
    else {
        return YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = (CGRect){CGPointMake(0, CGRectGetHeight(self.view.bounds) - toolbarSize.height), toolbarSize};
    self.webView.frame = (CGRect){CGPointZero, CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolbar.frame))};
    
    UIBarButtonItem *fixedSpaceLeft = [self.toolbar.items objectAtIndex:2];
    UIBarButtonItem *fixedSpaceRight = [self.toolbar.items objectAtIndex:6];
    CGFloat activityIndicatorYPosition = CGRectGetMinY(self.toolbar.frame) + roundf(toolbarSize.height / 2.f);
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        fixedSpaceLeft.width = fixedSpaceRight.width = 40.f;
        self.activityIndicator.center = CGPointMake(214.f, activityIndicatorYPosition);
    }
    else {
        fixedSpaceLeft.width = fixedSpaceRight.width = 83.f;
        self.activityIndicator.center = CGPointMake(334.f, activityIndicatorYPosition);
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    // Just to remove the associated warning. Nothing here yet
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
    self.refreshBarButtonItem.enabled = !self.activityIndicator.isAnimating;
    self.refreshBarButtonItem.image = self.activityIndicator.isAnimating ? nil : self.refreshImage;
}

#pragma mark MFMailComposeViewControllerDelegate protocol implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate protocol implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    
    [self.activityIndicator startAnimating];
    [self reloadData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    
    [self.activityIndicator stopAnimating];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self reloadData];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self webViewDidFinishLoad:webView];
}

#pragma mark Action callbacks

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self reloadData];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self reloadData];
}

- (IBAction)refresh:(id)sender
{
    [self.webView loadRequest:self.webView.request];
}

- (IBAction)displayActionSheet:(id)sender
{    
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    actionSheet.title = [self.webView.request.URL absoluteString];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Open in Safari", @"CoconutKit_Localizable", @"HLSWebViewController 'Open in Safari' action")
                             target:self
                             action:@selector(openInSafari:)];
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Mail Link", @"CoconutKit_Localizable", @"HLSWebViewController 'Mail Link' action")
                                 target:self
                                 action:@selector(mailLink:)];
    }
    [actionSheet addCancelButtonWithTitle:HLSLocalizedStringFromUIKit(@"Cancel") 
                                   target:nil
                                   action:NULL];
    [actionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
}

- (void)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)mailLink:(id)sender
{
    MFMailComposeViewController *mailComposeViewController = [[[MFMailComposeViewController alloc] init] autorelease];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:self.title];
    [mailComposeViewController setMessageBody:[self.webView.request.URL absoluteString] isHTML:NO];
    [self presentModalViewController:mailComposeViewController animated:YES];
}

@end
