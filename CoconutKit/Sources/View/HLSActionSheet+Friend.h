//
//  HLSActionSheet+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 23.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSActionSheet.h"

/**
 * Interface meant to be used by friend classes of HLSActionSheet (= classes which must have access to private implementation
 * details)
 */
@interface HLSActionSheet (Friend)

/**
 * Return the currently displayed HLSActionSheet, or nil if none
 */
+ (HLSActionSheet *)currentActionSheet;

/**
 * Dismiss the currently displayed HLSAction sheet (if any)
 */
+ (void)dismissCurrentActionSheetAnimated:(BOOL)animated;

@end
