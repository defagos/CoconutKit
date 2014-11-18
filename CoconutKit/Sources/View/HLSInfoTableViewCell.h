//
//  HLSInfoTableViewCell.h
//  CoconutKit
//
//  Created by Samuel Défago on 04/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSLabel.h"
#import "HLSTableViewCell.h"

@interface HLSInfoTableViewCell : HLSTableViewCell

+ (CGFloat)heightForValue:(NSString *)value;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
