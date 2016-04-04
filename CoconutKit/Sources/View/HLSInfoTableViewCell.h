//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTableViewCell.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSInfoTableViewCell : HLSTableViewCell

+ (CGFloat)heightForValue:(nullable NSString *)value;

@property (nonatomic, weak, nullable) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak, nullable) IBOutlet UILabel *valueLabel;

@end

NS_ASSUME_NONNULL_END
