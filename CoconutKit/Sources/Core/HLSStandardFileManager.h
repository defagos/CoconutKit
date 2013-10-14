//
//  HLSStandardFileManager.h
//  CoconutKit
//
//  Created by Samuel Défago on 12/13/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSFileManager.h"

/**
 * A standard NSFileManager-based file manager, built upon +[NSFileManager defaultManager]
 */
@interface HLSStandardFileManager : HLSFileManager

/**
 * Return the default instance
 */
+ (HLSStandardFileManager *)defaultManager;

@end
