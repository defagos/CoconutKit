//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTableViewCell.h"

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 * Just to be used by subclasses of HLSTableViewCell within the CoconutKit framework (the ones needing
 * access to styles). Not to be published in the library public headers
 */
@interface HLSTableViewCell (Protected)

+ (UITableViewCellStyle)style;

@end

NS_ASSUME_NONNULL_END
