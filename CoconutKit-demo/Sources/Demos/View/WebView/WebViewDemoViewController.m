//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "WebViewDemoViewController.h"

@interface WebViewDemoViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation WebViewDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.transparent = YES;
        
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"sample_text" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:htmlText baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Web view", nil);
}

@end
