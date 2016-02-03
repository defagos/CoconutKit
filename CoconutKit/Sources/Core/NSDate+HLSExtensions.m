//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSDate+HLSExtensions.h"

#import "HLSRuntime.h"

// Original implementation of the methods we swizzle
static id (*s_descriptionWithLocale)(id, SEL, id) = NULL;

// Swizzled method implementations
static NSString *swizzle_descriptionWithLocale(NSDate *self, SEL _cmd, id locale);

@implementation NSDate (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(descriptionWithLocale:), swizzle_descriptionWithLocale, &s_descriptionWithLocale);
}

#pragma mark Convenience methods

- (BOOL)isEarlierThanDate:(NSDate *)date
{
    return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)date
{
    return [self compare:date] != NSOrderedDescending;
}

- (BOOL)isLaterThanDate:(NSDate *)date
{
    return [self compare:date] == NSOrderedDescending;
}

- (BOOL)isLaterThanOrEqualToDate:(NSDate *)date
{
    return [self compare:date] != NSOrderedAscending;
}

@end

#pragma mark Swizzled method implementations

static NSString *swizzle_descriptionWithLocale(NSDate *self, SEL _cmd, id locale)
{
    static NSDateFormatter *s_dateFormatter = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        // Create time formatter for system timezone (which is the default one if not set)
        s_dateFormatter = [[NSDateFormatter alloc] init];
        [s_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'ZZZ"];
    });
    
    NSString *originalString = s_descriptionWithLocale(self, _cmd, locale);
    return [NSString stringWithFormat:@"%@ (system time zone: %@)", originalString, [s_dateFormatter stringFromDate:self]];
}
