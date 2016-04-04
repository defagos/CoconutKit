//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (HLSExtensions)

/**
 * If set to YES, the web view background is completely transparent
 */
@property (nonatomic, getter=isTransparent) BOOL transparent;

@end

NS_ASSUME_NONNULL_END
