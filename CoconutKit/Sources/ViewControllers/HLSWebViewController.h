//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 * A web browser with standard features (navigation buttons, link sharing, etc.)
 */
@interface HLSWebViewController : HLSViewController <UIPopoverControllerDelegate, UIWebViewDelegate, WKNavigationDelegate>

/**
 * Create the browser using the specified request
 */
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

/**
 * The initial request
 */
@property (nonatomic, readonly, strong) NSURLRequest *request;

@end

@interface HLSWebViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
