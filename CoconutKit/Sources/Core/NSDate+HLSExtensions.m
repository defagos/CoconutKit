//
//  NSDate+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

#import "HLSRuntime.h"
#import "NSCalendar+HLSExtensions.h"

static NSDateFormatter *s_dateFormatter = nil;

// Original implementation of the methods we swizzle
static id (*s_NSDate__descriptionWithLocale_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static NSString *swizzled_NSDate__descriptionWithLocale_Imp(NSDate *self, SEL _cmd, id locale);

@implementation NSDate (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    s_NSDate__descriptionWithLocale_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                  @selector(descriptionWithLocale:),
                                                                                  (IMP)swizzled_NSDate__descriptionWithLocale_Imp);
}

+ (void)initialize
{
    if (self != [NSDate class]) {
        return;
    }
    
    // Create time formatter for system timezone (which is the default one if not set)
    s_dateFormatter = [[NSDateFormatter alloc] init];
    [s_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'ZZZ"];
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

static NSString *swizzled_NSDate__descriptionWithLocale_Imp(NSDate *self, SEL _cmd, id locale)
{
    NSString *originalString = (*s_NSDate__descriptionWithLocale_Imp)(self, _cmd, locale);
    return [NSString stringWithFormat:@"%@ (system time zone: %@)", originalString, [s_dateFormatter stringFromDate:self]];
}
