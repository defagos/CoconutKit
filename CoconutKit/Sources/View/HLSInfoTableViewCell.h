//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSTableViewCell.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HLSInfoTableViewCell : HLSTableViewCell

+ (CGFloat)heightForValue:(NSString *)value;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
