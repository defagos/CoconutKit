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

@interface HLSLoggerViewController : HLSViewController <QLPreviewControllerDataSource, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithLogger:(HLSLogger *)logger NS_DESIGNATED_INITIALIZER;

@end

@interface HLSLoggerViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
