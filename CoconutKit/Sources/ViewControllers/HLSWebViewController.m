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

@interface HLSWebViewController ()

@property (nonatomic, retain) HLSActionSheet *actionSheet;

- (void)openInSafari:(id)sender;
- (void)mailLink:(id)sender;

@end

@implementation HLSWebViewController

@synthesize request;
@synthesize webView, toolbar, goBackButtonItem, goForwardButtonItem, refreshButtonItem, actionButtonItem, activityIndicator, refreshImage, actionSheet;

- (id)initWithRequest:(NSURLRequest *)aRequest
{
    if ((self = [super initWithNibName:@"CoconutKit_HLSWebViewController" bundle:nil])) {
        request = [aRequest retain];
    }
    return self;
}

- (void)dealloc
{
    [request release];
    [super dealloc];
}

- (void)updateView
{
    self.goBackButtonItem.enabled = self.webView.canGoBack;
    self.goForwardButtonItem.enabled = self.webView.canGoForward;
    self.refreshButtonItem.enabled = !self.activityIndicator.isAnimating;
    self.refreshButtonItem.image = self.activityIndicator.isAnimating ? nil : self.refreshImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshImage = self.refreshButtonItem.image;
    [self.webView loadRequest:self.request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = (CGRect){CGPointMake(0, CGRectGetHeight(self.view.bounds) - toolbarSize.height), toolbarSize};
    self.webView.frame = (CGRect){CGPointZero, CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolbar.frame))};
    
    UIBarButtonItem *fixedSpaceLeft = [self.toolbar.items objectAtIndex:2];
    UIBarButtonItem *fixedSpaceRight = [self.toolbar.items objectAtIndex:6];
    CGFloat activityIndicatorYPosition = CGRectGetMinY(self.toolbar.frame) + roundf(toolbarSize.height / 2.0f);
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        fixedSpaceLeft.width = fixedSpaceRight.width = 40.0f;
        activityIndicator.center = CGPointMake(214, activityIndicatorYPosition);
    }
    else
    {
        fixedSpaceLeft.width = fixedSpaceRight.width = 83.0f;
        activityIndicator.center = CGPointMake(334, activityIndicatorYPosition);
    }
}

- (void)releaseViews
{
    [super releaseViews];
    self.webView = nil;
    self.toolbar = nil;
    self.goBackButtonItem = nil;
    self.goForwardButtonItem = nil;
    self.refreshButtonItem = nil;
    self.actionButtonItem = nil;
    self.activityIndicator = nil;
    self.refreshImage = nil;
    self.actionSheet = nil;
}

// MARK: -
// MARK: UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityIndicator startAnimating];
    [self updateView];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateView];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error;
{
    [self webViewDidFinishLoad:aWebView];
}

// MARK: -
// MARK: Actions

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self updateView];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self updateView];
}

- (IBAction)refresh:(id)sender
{
    [self.webView loadRequest:self.webView.request];
}

- (IBAction)displayActionSheet:(id)sender;
{    
    self.actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    self.actionSheet.delegate = self;
    self.actionSheet.title = [self.webView.request.URL absoluteString];
    [self.actionSheet addCancelButtonWithTitle:HLSLocalizedStringFromUIKit(@"Cancel") 
                                        target:nil
                                        action:NULL];
    [self.actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Open in Safari", @"CoconutKit_localizable", @"HLSWebViewController 'Open in Safari' action")
                                  target:self
                                  action:@selector(openInSafari:)];
    [self.actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Mail Link", @"CoconutKit_localizable", @"HLSWebViewController 'Mail Link' action")
                                  target:self
                                  action:@selector(mailLink:)];
    [self.actionSheet showFromBarButtonItem:self.actionButtonItem animated:YES];
}

// MARK: -
// MARK: Action Sheet

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)mailLink:(id)sender
{
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:self.title];
    [mailComposeViewController setMessageBody:[self.webView.request.URL absoluteString] isHTML:NO];
    [self presentModalViewController:mailComposeViewController animated:YES];
    [mailComposeViewController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.actionSheet = nil;
}

@end
