//
//  XibTableViewCell.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface XibTableViewCell : HLSTableViewCell {
@private
    UIImageView *m_testImageView;
    UILabel *m_testLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *testImageView;
@property (nonatomic, retain) IBOutlet UILabel *testLabel;

@end
