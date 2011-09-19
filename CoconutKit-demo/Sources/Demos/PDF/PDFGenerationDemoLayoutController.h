//
//  PDFGenerationDemoLayoutController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface PDFGenerationDemoLayoutController : HLSPDFLayoutController <UITableViewDataSource, UITableViewDelegate> {
@private
    UITableView *m_tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
