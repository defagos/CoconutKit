//
//  CursorFolderView.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: -initWithFrame:
 */
@interface CursorFolderView : HLSNibView {
@private
    UILabel *_nameLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end
