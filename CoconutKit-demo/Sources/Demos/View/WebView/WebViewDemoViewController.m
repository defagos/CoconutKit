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

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.webView = nil;
    self.scrollEnabledSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize webView = m_webView;

@synthesize scrollEnabledSwitch = m_scrollEnabledSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"sample_text" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:htmlText baseURL:[[NSBundle mainBundle] bundleURL]];
    
    self.scrollEnabledSwitch.on = self.webView.scrollEnabled;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
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
    self.webView.scrollEnabled = self.scrollEnabledSwitch.on;
}

@end
