//
//  HLSLoggerViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSLogger.h"
#import "HLSViewController.h"

@interface HLSLoggerViewController : HLSViewController <QLPreviewControllerDataSource, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithLogger:(HLSLogger *)logger NS_DESIGNATED_INITIALIZER;

@end

@interface HLSLoggerViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
