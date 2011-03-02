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
@synthesize webView, goBackButtonItem, goForwardButtonItem, refreshButtonItem;

- (id) initWithRequest:(NSURLRequest *)aRequest
{
	if ((self = [super initWithNibName:@"nut_HLSWebViewController" bundle:nil])) {
		request = [aRequest retain];
	}
	return self;
}

- (void) dealloc
{
	[request release];
	[super dealloc];
}

- (void) updateView
{
	self.goBackButtonItem.enabled = self.webView.canGoBack;
	self.goForwardButtonItem.enabled = self.webView.canGoForward;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.webView loadRequest:self.request];
	[self updateView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return /*UIInterfaceOrientationIsLandscape(interfaceOrientation) ||*/ interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)releaseViews
{
	[super releaseViews];
	self.webView = nil;
	self.goBackButtonItem = nil;
	self.goForwardButtonItem = nil;
	self.refreshButtonItem = nil;
}

// MARK: -
// MARK: UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self updateView];
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

@end
