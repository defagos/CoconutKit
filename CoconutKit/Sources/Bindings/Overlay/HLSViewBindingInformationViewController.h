//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewBindingInformation.h"
#import "HLSViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Display various information about a binding
 */
@interface HLSViewBindingInformationViewController : HLSViewController <UITableViewDataSource, UITableViewDelegate>

/**
 * Initialize for displaying the provided binding information
 */
- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation NS_DESIGNATED_INITIALIZER;

@end

@interface HLSViewBindingInformationViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

@end
