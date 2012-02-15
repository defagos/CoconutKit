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

+ (HLSActionSheet *)currentActionSheet;
+ (void)dismissCurrentActionSheetAnimated:(BOOL)animated;

@end
