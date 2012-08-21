//
//  HLSLayerAnimationGroup.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLayerAnimationGroup.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@interface HLSLayerAnimationGroup ()

@property (nonatomic, retain) NSMutableArray *layerKeys;
@property (nonatomic, retain) NSMutableDictionary *layerToLayerAnimationMap;

@end

@implementation HLSLayerAnimationGroup

#pragma mark Convenience methods

+ (HLSLayerAnimationGroup *)layerAnimationGroup
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.layerKeys = [NSMutableArray array];
        self.layerToLayerAnimationMap = [NSMutableDictionary dictionary];
        
        // Default animation settings. Core Animation default value is 0.25 and linar timing function,
        // but to be consistent with UIView block-based animations we use 0.2 and an ease-in ease-out
        // function
        self.duration = 0.2;
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    return self;
}

- (void)dealloc
{
    self.layerKeys = nil;
    self.layerToLayerAnimationMap = nil;
    self.tag = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forLayer:(CALayer *)layer
{
    if (! layerAnimation) {
        HLSLoggerDebug(@"Layer animation is nil");
        return;
    }
    
    if (! layer) {
        HLSLoggerDebug(@"Layer is nil; no layer animation added");
        return;
    }
    
    NSValue *layerKey = [NSValue valueWithPointer:layer];
    [self.layerKeys addObject:layerKey];
    [self.layerToLayerAnimationMap setObject:layerAnimation forKey:layerKey];
}

- (void)addLayerAnimation:(HLSLayerAnimation *)layerAnimation forView:(UIView *)view
{
    [self addLayerAnimation:layerAnimation forLayer:view.layer];
}

- (NSArray *)layers
{
    NSMutableArray *layers = [NSMutableArray array];
    for (NSValue *layerKey in self.layerKeys) {
        CALayer *layer = [layerKey pointerValue];
        [layers addObject:layer];
    }
    return [NSArray arrayWithArray:layers];
}

- (HLSLayerAnimation *)layerAnimationForLayer:(CALayer *)layer
{
    if (! layer) {
        return nil;
    }
    
    NSValue *layerKey = [NSValue valueWithPointer:layer];
    return [self.layerToLayerAnimationMap objectForKey:layerKey];
}

@synthesize layerKeys = m_layerKeys;

@synthesize layerToLayerAnimationMap = m_layerToLayerAnimationMap;

@synthesize duration = m_duration;

- (void)setDuration:(CFTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.)) {
        HLSLoggerWarn(@"Duration must be non-negative. Fixed to 0");
        m_duration = 0.;
    }
    else {
        m_duration = duration;
    }
}

@synthesize timingFunction = m_timingFunction;

@synthesize tag = m_tag;

- (CGFloat)opacityVariationForLayer:(CALayer *)layer
{
    HLSLayerAnimation *layerAnimation = [self layerAnimationForLayer:layer];
    return layerAnimation.opacityVariation;
}

#pragma mark Reverse animation

- (HLSLayerAnimationGroup *)reverseLayerAnimationGroup
{
    HLSLayerAnimationGroup *reverseAnimationGroup = [HLSLayerAnimationGroup layerAnimationGroup];
    for (CALayer *layer in [self layers]) {
        HLSLayerAnimation *layerAnimation = [self layerAnimationForLayer:layer];
        [reverseAnimationGroup addLayerAnimation:[layerAnimation reverseLayerAnimation] forLayer:layer];
    }
    
    // Animation group properties
    reverseAnimationGroup.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimationGroup.duration = self.duration;
    
    // TODO: Add category to CAMediaTimingFunction to generate the inverse function, and add defines
    //       for the common animations (e.g. HLSMediaTimingFunctionEaseInEaseOut)
#if 0
    switch (self.curve) {
        case UIViewAnimationCurveEaseIn:
            reverseAnimationGroup.curve = UIViewAnimationCurveEaseOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            reverseAnimationGroup.curve = UIViewAnimationCurveEaseIn;
            break;
            
        case UIViewAnimationCurveLinear:
        case UIViewAnimationCurveEaseInOut:
        default:
            // Nothing to do
            break;
    }
#endif
    return reverseAnimationGroup;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSLayerAnimationGroup *animationGroupCopy = [[HLSLayerAnimationGroup allocWithZone:zone] init];
    for (CALayer *layer in [self layers]) {
        HLSLayerAnimation *layerAnimation = [self layerAnimationForLayer:layer];
        HLSLayerAnimation *layerAnimationCopy = [[layerAnimation copyWithZone:zone] autorelease];
        [animationGroupCopy addLayerAnimation:layerAnimationCopy forLayer:layer];
    }
    animationGroupCopy.tag = self.tag;
    animationGroupCopy.duration = self.duration;
    animationGroupCopy.timingFunction = self.timingFunction;
    return animationGroupCopy;
}

#pragma mark Description

- (NSString *)description
{
    NSString *layerAnimationDescriptions = @"{";
    for (CALayer *layer in [self layers]) {
        HLSLayerAnimation *layerAnimation = [self layerAnimationForLayer:layer];
        layerAnimationDescriptions = [layerAnimationDescriptions stringByAppendingFormat:@"\n\t%@ - %@", layer, layerAnimation];
    }
    layerAnimationDescriptions = [layerAnimationDescriptions stringByAppendingFormat:@"\n}"];
    
    return [NSString stringWithFormat:@"<%@: %p; layerAnimations: %@; duration: %f; tag: %@>",
            [self class],
            self,
            layerAnimationDescriptions,
            self.duration,
            self.tag];
}

@end

