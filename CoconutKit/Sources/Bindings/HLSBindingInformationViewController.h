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
- (id)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation;

@end
