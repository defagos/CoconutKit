//
//  CoconutTableViewCell.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface CoconutTableViewCell : HLSTableViewCell {
@private
    UIImageView *m_thumbnailImageView;
    UILabel *m_nameLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end
