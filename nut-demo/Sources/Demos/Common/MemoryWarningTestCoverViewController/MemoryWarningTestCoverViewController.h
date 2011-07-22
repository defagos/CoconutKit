//
//  MemoryWarningTestCoverViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller, intended to be prsented modally in order to test behavior after memory warnings have been received
 */
@interface MemoryWarningTestCoverViewController : HLSViewController {
@private
    UIBarButtonItem *m_closeBarButtonItem;
    UILabel *m_instructionLabel;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, retain) IBOutlet UILabel *instructionLabel;

@end
