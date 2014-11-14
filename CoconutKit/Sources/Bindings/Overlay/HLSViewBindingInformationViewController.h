//
//  HLSViewBindingInformationViewController.h
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformation.h"
#import "HLSViewController.h"

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
