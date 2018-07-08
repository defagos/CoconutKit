//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSLogger.h"
#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSLoggerViewController : HLSViewController <QLPreviewControllerDataSource, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithLogger:(HLSLogger *)logger NS_DESIGNATED_INITIALIZER;

@end

@interface HLSLoggerViewController (UnavailableMethods)

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(nullable NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
