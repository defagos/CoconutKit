//
//  UIColor+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIColor+HLSExtensions.h"
#import "HLSCategoryLinker.h"

HLSLinkCategory(UIColor_HLSExtensions)

@implementation UIColor (HLSExtensions)

+ (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random() % 256)/256.f
                           green:(arc4random() % 256)/256.f 
                            blue:(arc4random() % 256)/256.f 
                           alpha:1.f];
}

- (UIColor *)invertColor
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    UIColor *invertColor = [[[UIColor alloc] initWithRed:1.f - components[0]
                                                   green:1.f - components[1]
                                                    blue:1.f - components[2]
                                                   alpha:components[3]] autorelease];
    
    return invertColor;
}

@end
