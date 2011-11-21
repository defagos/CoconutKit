//
//  HLSManagedTextFieldValidator+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 21.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSManagedTextFieldValidator.h"

@interface HLSManagedTextFieldValidator (Friend)

/**
 * Check the value currently displayed by the text field. Returns YES iff valid
 */
- (BOOL)checkDisplayedValue;

/**
 * Update the bound managed object to match the value currently displayed by the text field
 */
- (void)synchronizeWithDisplayedValue;

@end
