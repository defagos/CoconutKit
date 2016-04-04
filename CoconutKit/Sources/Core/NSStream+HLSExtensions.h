//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInputStream (HLSExtensions)

/**
 * Consume the receiver, writing it to the provided output stream. No stream must be opened. Return YES iff successful
 * (error information is returned on failure)
 */
- (BOOL)writeToOutputStream:(NSOutputStream *)outputStream error:(out NSError *__autoreleasing *)pError;

@end

NS_ASSUME_NONNULL_END
