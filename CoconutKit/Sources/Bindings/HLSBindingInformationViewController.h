//
//  HLSBindingInformationViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewBindingInformation.h"

/**
 * Display various informations about a binding
 */
@interface HLSBindingInformationViewController : UITableViewController

/**
 * Initialize for displaying the provided binding information
 */
- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation NS_DESIGNATED_INITIALIZER;

@end

@interface HLSBindingInformationViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

@end
