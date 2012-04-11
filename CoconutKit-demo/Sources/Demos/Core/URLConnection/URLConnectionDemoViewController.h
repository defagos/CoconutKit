//
//  URLConnectionDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface URLConnectionDemoViewController : HLSViewController <HLSReloadable, HLSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate> {
@private
    NSArray *m_coconuts;
    UITableView *m_tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
