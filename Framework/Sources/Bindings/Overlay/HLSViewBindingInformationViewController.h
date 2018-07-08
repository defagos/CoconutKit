//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingInformation.h"
#import "HLSTableViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Display various information about a binding
 */
@interface HLSViewBindingInformationViewController : HLSTableViewController

/**
 * Initialize for displaying the provided binding information
 */
- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation NS_DESIGNATED_INITIALIZER;

@end

@interface HLSViewBindingInformationViewController (UnavailableMethods)

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
