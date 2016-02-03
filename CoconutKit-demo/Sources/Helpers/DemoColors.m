//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemoColors.h"

@implementation DemoColor

+ (UIColor *)customDemo1Color
{
    return [UIColor redColor];
}

+ (UIColor *)customDemo2Color
{
    return [UIColor yellowColor];
}

@end

@implementation UIColor (DemoColors)

+ (UIColor *)customCategory1Color
{
    return [UIColor blueColor];
}

+ (UIColor *)customCategory2Color
{
    return [UIColor greenColor];
}

@end
