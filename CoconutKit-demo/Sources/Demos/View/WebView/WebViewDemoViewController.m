//
//  WebViewDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "WebViewDemoViewController.h"

@implementation WebViewDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.webView = nil;
    self.scrollEnabledSwitch = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webView makeBackgroundTransparent];
    self.webView.shadowHidden = YES;
        
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"sample_text" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:htmlText baseURL:[[NSBundle mainBundle] bundleURL]];
    
    self.scrollEnabledSwitch.on = self.webView.scrollView.scrollEnabled;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Web view", @"Web view");
}

#pragma mark Event callbacks

- (IBAction)toggleScrollEnabled:(id)sender
{
    self.webView.scrollView.scrollEnabled = self.scrollEnabledSwitch.on;
}

@end
