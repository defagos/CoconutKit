//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemoTransformer.h"

@implementation DemoTransformer

+ (NSDateFormatter *)mediumDateFormatter
{
    static dispatch_once_t s_onceToken;
    static NSDateFormatter *s_dateFormatter;
    dispatch_once(&s_onceToken, ^{
        s_dateFormatter = [[NSDateFormatter alloc] init];
        s_dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        s_dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    });
    return s_dateFormatter;
}

+ (NSNumberFormatter *)decimalNumberFormatter
{
    static dispatch_once_t s_onceToken;
    static NSNumberFormatter *s_numberFormatter;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        s_numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    return s_numberFormatter;
}

@end
