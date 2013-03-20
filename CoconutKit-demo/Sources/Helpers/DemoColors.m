//
//  DemoColors.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 20.03.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
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
