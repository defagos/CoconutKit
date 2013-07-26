//
//  FontsDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 1/18/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "FontsDemoViewController.h"

@interface FontsDemoViewController ()

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end

@implementation FontsDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.label = nil;
    self.webView = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.label.font = [UIFont fontWithName:@"Beon-Regular" size:20.f];
    
    // Make the webview look nice :)
    self.webView.shadowHidden = YES;
    [self.webView fadeTop:0.02f bottom:0.02f];
    
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"sample_text_with_custom_font" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:htmlText baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Font", nil);
}

@end
