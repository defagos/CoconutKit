//
//  HLSWebViewController.h
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@interface HLSWebViewController : HLSViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIWebViewDelegate>

- (id)initWithRequest:(NSURLRequest *)request;

@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goBackButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goForwardButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionButtonItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIImage *refreshImage;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)displayActionSheet:(id)sender;

@end
