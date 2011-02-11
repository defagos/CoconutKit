//
//  ProgrammaticTableViewCell.h
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ProgrammaticTableViewCell : HLSStandardTableViewCell {
@private
    UILabel *m_label;
}

@property (nonatomic, retain) UILabel *label;

@end
