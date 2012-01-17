//
//  NSDate+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "NSDate+HLSExtensions.h"

#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"
#import "NSCalendar+HLSExtensions.h"

HLSLinkCategory(NSDate_HLSExtensions)

static id (*s_NSDate__descriptionWithLocale_Imp)(id, SEL, id) = NULL;
static NSDateFormatter *s_dateFormatter = nil;

@interface NSDate (HLSExtensionsPrivate)

- (NSString *)swizzledDescriptionWithLocale:(id)locale;

@end

__attribute__ ((constructor)) static void NSDate_HLSExtensionsInject(void)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    s_NSDate__descriptionWithLocale_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector([NSDate class], @selector(descriptionWithLocale:), @selector(swizzledDescriptionWithLocale:));
    
    // Create time formatter for system timezone (which is the default one if not set)
    s_dateFormatter = [[NSDateFormatter alloc] init];
    [s_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'ZZZ"];
    
    [pool release];
}

@implementation NSDate (HLSExtensions)

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

#pragma mark Injected methods

- (NSString *)swizzledDescriptionWithLocale:(id)locale
{
    NSString *originalString = (*s_NSDate__descriptionWithLocale_Imp)(self, @selector(descriptionWithLocale:), locale);
    return [NSString stringWithFormat:@"%@ (system time zone: %@)", originalString, [s_dateFormatter stringFromDate:self]];
}

@end
