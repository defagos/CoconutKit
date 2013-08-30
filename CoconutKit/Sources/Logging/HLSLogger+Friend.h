//
//  HLSLogger+Friend.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of HLSLogger (= classes which must have access to private implementation
 * details)
 */
@interface HLSLogger (Friend)

/**
 * Return the paths of all available log files, from the most recent to the oldest one
 */
- (NSArray *)availableLogFilePaths;

/**
 * Remove all log files
 */
- (void)clearLogs;

@end
