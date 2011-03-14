//
//  HLSWebViewController.m
//  nut
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSWebViewController.h"

@implementation HLSWebViewController

@synthesize request;
@synthesize webView, toolbar, goBackButtonItem, goForwardButtonItem, refreshButtonItem, activityIndicator;

- (id)initWithRequest:(NSURLRequest *)aRequest
{
	if ((self = [super initWithNibName:@"nut_HLSWebViewController" bundle:nil])) {
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
	self.refreshButtonItem.image = self.activityIndicator.isAnimating ? nil : [UIImage imageNamed:@"nut_ButtonBarRefresh.png"];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.webView loadRequest:self.request];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
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
	self.activityIndicator = nil;
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

- (IBAction)displayActionShet:(id)sender;
{
	NSBundle *uiKitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
	NSString *cancel = NSLocalizedStringFromTableInBundle(@"Cancel", nil, uiKitBundle ?: [NSBundle mainBundle], @"");
	NSString *openInSafari = NSLocalizedStringFromTable(@"Open in Safari", @"nut_Localizable", @"HLSWebViewController 'Open in Safari' action");
	NSString *mailLink = [MFMailComposeViewController canSendMail] ? NSLocalizedStringFromTable(@"Mail Link", @"nut_Localizable", @"HLSWebViewController 'Mail Link' action") : nil;
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:[self.webView.request.URL absoluteString] delegate:self cancelButtonTitle:cancel destructiveButtonTitle:nil otherButtonTitles:openInSafari, mailLink, nil] autorelease];
	[actionSheet showFromToolbar:self.toolbar];
}

// MARK: -
// MARK: Action Sheet

- (void)openInBrowser
{
	[[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)mailLink
{
	MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
	mailComposeViewController.mailComposeDelegate = self;
	[mailComposeViewController setSubject:self.title];
	[mailComposeViewController setMessageBody:[self.webView.request.URL absoluteString] isHTML:NO];
	[self presentModalViewController:mailComposeViewController animated:YES];
	[mailComposeViewController release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	switch (buttonIndex)
	{
		case 0:
			[self openInBrowser];
			break;
		case 1:
			[self mailLink];
			break;
	}
}

@end
