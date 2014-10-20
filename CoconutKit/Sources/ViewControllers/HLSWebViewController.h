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
 */
@interface HLSWebViewController : HLSViewController <UIPopoverControllerDelegate, UIWebViewDelegate>

/**
 * Create the browser using the specified request
 */
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

/**
 * The initial request
 */
@property (nonatomic, readonly, strong) NSURLRequest *request;

@end
