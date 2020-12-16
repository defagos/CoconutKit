//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A web browser with standard features (navigation buttons, link sharing, etc.). Starting with iOS 9, you should
 * use SFSafariViewController instead
 */
@interface HLSWebViewController : HLSViewController <WKNavigationDelegate>

/**
 * Create the browser using the specified request
 */
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

/**
 * The initial request
 */
@property (nonatomic, readonly) NSURLRequest *request;

@end

@interface HLSWebViewController (UnavailableMethods)

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(nullable NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
