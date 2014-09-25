//
//  WebViewDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "WebViewDemoViewController.h"

@interface WebViewDemoViewController ()

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UISwitch *scrollEnabledSwitch;

@end

@implementation WebViewDemoViewController

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
    
    self.title = NSLocalizedString(@"Web view", nil);
}

#pragma mark Event callbacks

- (IBAction)toggleScrollEnabled:(id)sender
{
    self.webView.scrollView.scrollEnabled = self.scrollEnabledSwitch.on;
}

@end
