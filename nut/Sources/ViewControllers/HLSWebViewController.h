//
//  HLSWebViewController.h
//  nut
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@interface HLSWebViewController : HLSViewController <UIWebViewDelegate>

- (id) initWithRequest:(NSURLRequest *)request;

@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goBackButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goForwardButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButtonItem;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

@end
