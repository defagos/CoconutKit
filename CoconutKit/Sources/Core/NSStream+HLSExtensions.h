//
//  NSStream+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.10.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface NSInputStream (HLSExtensions)

/**
 * Consume the receiver, writing it to the provided output stream. No stream must be opened. Return YES iff successful
 * (error information is returned on failure)
 */
- (BOOL)writeToOutputStream:(NSOutputStream *)outputStream error:(NSError **)pError;

@end
