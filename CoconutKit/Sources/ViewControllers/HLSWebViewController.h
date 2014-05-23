//
//  HLSWebViewController.h
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSViewController.h"

/**
 * A web browser with standard features (navigation buttons, link sharing, etc.)
 *
 * Designated initializer: -initWithRequest:
 */
@interface HLSWebViewController : HLSViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate>

/**
 * Create the browser using the specified request
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * The initial request
 */
@property (nonatomic, readonly, retain) NSURLRequest *request;

@end
