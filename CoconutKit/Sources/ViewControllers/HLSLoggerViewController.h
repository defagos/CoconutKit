//
//  HLSLoggerViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSLogger.h"
#import "HLSViewController.h"

@interface HLSLoggerViewController : HLSViewController <QLPreviewControllerDataSource, UITableViewDataSource, UITableViewDelegate>

- (id)initWithLogger:(HLSLogger *)logger;

@end
