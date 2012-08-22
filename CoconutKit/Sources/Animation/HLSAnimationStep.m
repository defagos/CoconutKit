//
//  HLSAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

#import "HLSAnimationStep+Protected.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@interface HLSAnimationStep ()

@property (nonatomic, retain) NSMutableArray *objectKeys;
@property (nonatomic, retain) NSMutableDictionary *objectToObjectAnimationMap;

@end

@implementation HLSAnimationStep

#pragma mark Convenience methods

+ (id)animationStep
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.objectKeys = [NSMutableArray array];
        self.objectToObjectAnimationMap = [NSMutableDictionary dictionary];
        
        // Default animation settings (as given in UIKit documentation)
        self.duration = 0.2;
    }
    return self;
}

- (void)dealloc
{
    self.objectKeys = nil;
    self.objectToObjectAnimationMap = nil;
    self.tag = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize objectKeys = m_objectKeys;

@synthesize objectToObjectAnimationMap = m_objectToObjectAnimationMap;

@synthesize tag = m_tag;

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
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

- (NSArray *)objects
{
    NSMutableArray *objects = [NSMutableArray array];
    for (NSValue *objectKey in self.objectKeys) {
        id object = [objectKey pointerValue];
        [objects addObject:object];
    }
    return [NSArray arrayWithArray:objects];
}

#pragma mark Animations in the step

- (void)addObjectAnimation:(id)objectAnimation forObject:(id)object
{
    if (! objectAnimation) {
        HLSLoggerDebug(@"No animation for the object");
        return;
    }
    
    if (! object) {
        HLSLoggerDebug(@"No object to animated");
        return;
    }
    
    NSValue *objectKey = [NSValue valueWithPointer:object];
    [self.objectKeys addObject:objectKey];
    [self.objectToObjectAnimationMap setObject:objectAnimation forKey:objectKey];
}

- (id)objectAnimationForObject:(id)object
{
    if (! object) {
        return nil;
    }
    
    NSValue *objectKey = [NSValue valueWithPointer:object];
    return [self.objectToObjectAnimationMap objectForKey:objectKey];
}

#pragma mark Managing the animation

- (BOOL)animatingView
{
    return NO;
}

- (void)playAfterDelay:(NSTimeInterval)delay withDelegate:(id<HLSAnimationStepDelegate>)delegate animated:(BOOL)animated
{}

- (void)cancel
{}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSAnimationStep *reverseAnimationStep = [[self class] animationStep];
    for (id object in [self objects]) {
        id<HLSObjectAnimation> objectAnimation = [self objectAnimationForObject:object];
        [reverseAnimationStep addObjectAnimation:[objectAnimation reverseObjectAnimation] forObject:object];
    }
    reverseAnimationStep.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimationStep.duration = self.duration;
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSAnimationStep *animationStepCopy = [[[self class] allocWithZone:zone] init];
    for (id object in [self objects]) {
        id<HLSObjectAnimation> objectAnimation = [self objectAnimationForObject:object];
        id<HLSObjectAnimation> objectAnimationCopy = [[objectAnimation copyWithZone:zone] autorelease];
        [animationStepCopy addObjectAnimation:objectAnimationCopy forObject:object];
    }
    animationStepCopy.tag = self.tag;
    animationStepCopy.duration = self.duration;
    return animationStepCopy;
}

#pragma mark Description

- (NSString *)objectAnimationDescriptionString
{
    NSString *objectAnimationDescriptionString = @"{";
    for (id object in [self objects]) {
        id<HLSObjectAnimation> objectAnimation = [self objectAnimationForObject:object];
        objectAnimationDescriptionString = [objectAnimationDescriptionString stringByAppendingFormat:@"\n\t%@ - %@", object, objectAnimation];        
    }
    return [objectAnimationDescriptionString stringByAppendingFormat:@"\n}"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; objectAnimations: %@; duration: %f; tag: %@>",
            [self class],
            self,
            [self objectAnimationDescriptionString],
            self.duration,
            self.tag];
}

@end
