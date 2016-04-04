//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingInformation.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Interface meant to be used by friend classes of UIView (HLSViewBinding) (= classes which must have access to private 
 * implementation details)
 */
@interface UIView (HLSViewBindingFriend)

/**
 * The attached binding information, if any
 */
@property (nonatomic, readonly, nullable) HLSViewBindingInformation *bindingInformation;

/**
 * Update the view with the most recent value retrieved from the bound model object
 */
- (void)updateBoundView;

@end

NS_ASSUME_NONNULL_END
