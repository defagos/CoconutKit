//
//  HLSViewAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/8/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewAnimationStep.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

static const CGFloat kAnimationStepDefaultAlphaVariation = 0.f;

@implementation HLSViewAnimationStep

#pragma mark Convenience methods

+ (HLSViewAnimationStep *)viewAnimationStep
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        // Default: No change
        self.transform = CATransform3DIdentity;
        self.alphaVariation = kAnimationStepDefaultAlphaVariation; 
    }
    return self;
}

#pragma mark Accessors and mutators

@synthesize transform = m_transform;

@synthesize alphaVariation = m_alphaVariation;

- (void)setAlphaVariation:(CGFloat)alphaVariation
{
    // Sanitize input
    if (floatlt(alphaVariation, -1.f)) {
        HLSLoggerWarn(@"Alpha variation cannot be smaller than -1. Fixed to -1");
        m_alphaVariation = -1.f;
    }
    else if (floatgt(alphaVariation, 1.f)) {
        HLSLoggerWarn(@"Alpha variation cannot be larger than 1. Fixed to 1");
        m_alphaVariation = 1.f;
    }
    else {
        m_alphaVariation = alphaVariation;
    }
}

#pragma mark Reverse

- (HLSViewAnimationStep *)reverseViewAnimationStep
{
    HLSViewAnimationStep *reverseViewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
    reverseViewAnimationStep.transform = CATransform3DInvert(self.transform);
    reverseViewAnimationStep.alphaVariation = -self.alphaVariation;
    return reverseViewAnimationStep;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; transform: %@; alphaVariation: %f>", 
            [self class],
            self,
            @"TODO",
            self.alphaVariation];
}

@end
