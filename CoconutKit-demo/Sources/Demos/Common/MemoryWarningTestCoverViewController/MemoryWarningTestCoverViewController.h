//
//  MemoryWarningTestCoverViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller, intended to be prsented modally in order to test behavior after memory warnings have been received
 */
@interface MemoryWarningTestCoverViewController : HLSViewController {
@private
    UIBarButtonItem *_closeBarButtonItem;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeBarButtonItem;

@end
