//
//  URLConnectionDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface URLConnectionDemoViewController : HLSViewController <HLSReloadable, HLSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate> {
@private
    HLSURLConnection *m_asynchronousConnection;
    NSArray *m_coconuts;
    UITableView *m_tableView;
    UIButton *m_asynchronousLoadButton;
    UIButton *m_cancelButton;
    UIButton *m_synchronousLoadButton;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *asynchronousLoadButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *synchronousLoadButton;

- (IBAction)loadAsynchronously:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)loadSynchronously:(id)sender;

@end
