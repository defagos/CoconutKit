//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (HLSExtensions)

/**
 * The distance to keep (at least) between keyboard and content. Overrides the corresponding value defined on UIScrollView
 * when set
 */
@property (nonatomic, nullable) IBInspectable NSNumber *keyboardDistance;

@end

NS_ASSUME_NONNULL_END
