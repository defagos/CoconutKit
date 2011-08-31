//
//  CursorSelectedFolderView.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 17.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: initWithFrame:
 */
@interface CursorSelectedFolderView : HLSNibView {
@private
    UILabel *m_nameLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end
