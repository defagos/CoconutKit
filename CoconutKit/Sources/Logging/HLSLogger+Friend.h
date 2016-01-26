//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSLogger.h"

#import <Foundation/Foundation.h>

/**
 * Interface meant to be used by friend classes of HLSLogger (= classes which must have access to private implementation
 * details)
 */
@interface HLSLogger (Friend)

/**
 * Return the paths of all available log files, from the most recent to the oldest one
 */
@property (nonatomic, readonly) NSArray<NSString *> *availableLogFilePaths;

/**
 * Remove all log files
 */
- (void)clearLogs;

@end
