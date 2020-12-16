//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An activity to open a given URL in Google Chrome. This activity expects a single activity item which
 * is the URL to open
 *
 * Starting with iOS 9, you must add an LSApplicationQueriesSchemes array entry to your application info plist,
 * with the following string items:
 *  googlechrome
 *  googlechromes
 */
@interface HLSGoogleChromeActivity : UIActivity
@end

NS_ASSUME_NONNULL_END
