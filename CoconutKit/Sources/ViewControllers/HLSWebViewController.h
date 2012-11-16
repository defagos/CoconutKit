//
//  HLSWebViewController.h
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

/**
 * A web browser with standard features (navigation buttons, link sharing, etc.)
 *
 * Designated initializer: -initWithRequest:
 */
@interface HLSWebViewController : HLSViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate> {
@private
    NSURLRequest *m_request;
    NSURL *m_currentURL;
    UIWebView *m_webView;
    UIToolbar *m_toolbar;
    UIBarButtonItem *m_goBackBarButtonItem;
    UIBarButtonItem *m_goForwardBarButtonItem;
    UIBarButtonItem *m_refreshBarButtonItem;
    UIBarButtonItem *m_actionBarButtonItem;
    UIActivityIndicatorView *m_activityIndicator;
    UIImage *m_refreshImage;
}

/**
 * Create the browser using the specified request
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * The initial request
 */
@property (nonatomic, readonly, retain) NSURLRequest *request;

/**
 * View outlets. Do not change
 */
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

/**
 * Actions. Do not change
 */
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)displayActionSheet:(id)sender;

@end
