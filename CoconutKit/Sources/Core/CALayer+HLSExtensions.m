//
//  CALayer+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CALayer+HLSExtensions.h"

@implementation CALayer (HLSExtensions)

- (void)removeAllAnimationsRecursively
{
    [self removeAllAnimations];
    for (CALayer *sublayer in self.sublayers) {
        [sublayer removeAllAnimationsRecursively];
    }
}

@end
