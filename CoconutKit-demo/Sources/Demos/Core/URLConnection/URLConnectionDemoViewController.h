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
    UITableView *m_cachedImagesTableView;
    UITableView *m_nonCachedImagesTableView;
    UIButton *m_asynchronousLoadButton;
    UIButton *m_cancelButton;
    UIButton *m_synchronousLoadButton;
    UIButton *m_asynchronousLoadNoCancelButton;
    UIButton *m_clearButton;
    UILabel *m_treatingHTTPErrorsAsFailuresLabel;
    UISwitch *m_treatingHTTPErrorsAsFailuresSwitch;
    UIButton *m_testHTTP404ErrorButton;
}

@property (nonatomic, retain) IBOutlet UITableView *cachedImagesTableView;
@property (nonatomic, retain) IBOutlet UITableView *nonCachedImagesTableView;
@property (nonatomic, retain) IBOutlet UIButton *asynchronousLoadButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton *synchronousLoadButton;
@property (nonatomic, retain) IBOutlet UIButton *asynchronousLoadNoCancelButton;
@property (nonatomic, retain) IBOutlet UIButton *clearButton;
@property (nonatomic, retain) IBOutlet UILabel *treatingHTTPErrorsAsFailuresLabel;
@property (nonatomic, retain) IBOutlet UISwitch *treatingHTTPErrorsAsFailuresSwitch;
@property (nonatomic, retain) IBOutlet UIButton *testHTTP404ErrorButton;

- (IBAction)loadAsynchronously:(id)sender;
- (IBAction)loadAsynchronouslyNoCancel:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)loadSynchronously:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)testHTTP404Error:(id)sender;

@end
