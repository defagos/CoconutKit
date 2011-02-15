//
//  MemoryWarningTestCoverViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface MemoryWarningTestCoverViewController : HLSViewController {
@private
    UIBarButtonItem *m_closeBarButtonItem;
    UILabel *m_instructionLabel;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, retain) IBOutlet UILabel *instructionLabel;

@end
