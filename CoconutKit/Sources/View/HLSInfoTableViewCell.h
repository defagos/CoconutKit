//
//  HLSInfoTableViewCell.h
//  CoconutKit
//
//  Created by Samuel Défago on 04/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSLabel.h"
#import "HLSTableViewCell.h"

@interface HLSInfoTableViewCell : HLSTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet HLSLabel *valueLabel;

@end
