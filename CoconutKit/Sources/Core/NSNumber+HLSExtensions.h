//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

@interface NSNumber (HLSExtensions)

/**
 * Return the minimum / maximum between the receiver and another number (if equal, return the receiver)
 */
- (NSNumber *)minimumNumber:(NSNumber *)anotherNumber;
- (NSNumber *)maximumNumber:(NSNumber *)anotherNumber;

/**
 * Convenience methods for number comparisons. Easier to read than -[NSNumber compare:]
 */
- (BOOL)isLessThanNumber:(NSNumber *)number;
- (BOOL)isLessThanOrEqualToNumber:(NSNumber *)number;
- (BOOL)isGreaterThanNumber:(NSNumber *)number;
- (BOOL)isGreaterThanOrEqualToNumber:(NSNumber *)number;

@end
