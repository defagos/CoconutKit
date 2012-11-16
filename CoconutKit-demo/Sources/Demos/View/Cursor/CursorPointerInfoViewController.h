//
//  CursorPointerInfoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: -init
 */
@interface CursorPointerInfoViewController : HLSViewController {
@private
    UILabel *m_valueLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

@end
