//
//  XibTableViewCell.h
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface XibTableViewCell : HLSTableViewCell {
@private
    UIImageView *m_imageView;
    UILabel *m_label;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end
