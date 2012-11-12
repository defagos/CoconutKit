//
//  HLSAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

#import "HLSAnimationStep+Friend.h"
#import "HLSAnimationStep+Protected.h"
#import "HLSAssert.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "NSString+HLSExtensions.h"

@interface HLSAnimationStep ()

@property (nonatomic, retain) NSMutableArray *objectKeys;
@property (nonatomic, retain) NSMutableDictionary *objectToObjectAnimationMap;
@property (nonatomic, retain) id<HLSAnimationStepDelegate> delegate;        // Set during animated animations to retain the delegate
@property (nonatomic, assign, getter=isCancelling) BOOL terminating;

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
    self.userInfo = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize objectKeys = m_objectKeys;

@synthesize objectToObjectAnimationMap = m_objectToObjectAnimationMap;

@synthesize tag = m_tag;

@synthesize userInfo = m_userInfo;

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

@synthesize delegate = m_delegate;

- (BOOL)isPaused
{
    return [self isAnimationPaused];
}

@synthesize terminating = m_terminating;

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
    [self.objectToObjectAnimationMap setObject:[[objectAnimation copy] autorelease] forKey:objectKey];
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

- (void)playWithDelegate:(id<HLSAnimationStepDelegate>)delegate startTime:(NSTimeInterval)startTime animated:(BOOL)animated
{
    self.terminating = NO;
    
    // We do not perform the animation if the duration is 0 (this can lead to unnecessary flickering in animations)
    BOOL actuallyAnimated = animated && ! doubleeq(self.duration - startTime, 0.);
    
    // Retain the delegate during the time of the animation (this is based on the assumption
    // that animations implemented in subclasses do the same, and that they always call the
    // animation delegate stop method, which is the case for UIView animations and CAAnimations
    if (actuallyAnimated) {
        self.delegate = delegate;
    }
    
    // Call the subclass implementation
    [self playAnimationWithStartTime:startTime animated:actuallyAnimated];
    
    // Not animated (i.e. synchronously animated to the final position)
    if (! actuallyAnimated) {
        // Same remark as above
        [delegate animationStepDidStop:self animated:animated finished:YES];
    }
}

- (void)pause
{
    if (self.terminating) {
        HLSLoggerDebug(@"The animation step is being terminated");
        return;
    }
    
    if (self.paused) {
        HLSLoggerDebug(@"The animation step is already paused");
        return;
    }
    
    [self pauseAnimation];
}

- (void)resume
{
    if (! self.paused) {
        HLSLoggerDebug(@"The animation step has not being paused. Nothing to resume");
        return;
    }
    
    [self resumeAnimation];
}

- (void)terminate
{
    if (self.terminating) {
        HLSLoggerDebug(@"The animation step is already being terminated");
        return;
    }
    
    self.terminating = YES;
    
    // Call the subclass implementation
    [self terminateAnimation];
        
    // Same remark as above
    if ([self.delegate respondsToSelector:@selector(animationStepDidStop:animated:finished:)]) {
        [self.delegate animationStepDidStop:self animated:NO finished:NO];
    }
}

- (void)playAnimationAnimated:(BOOL)animated
{
    HLSMissingMethodImplementation();
}

- (void)pauseAnimation
{
    HLSMissingMethodImplementation();
}

- (void)resumeAnimation
{
    HLSMissingMethodImplementation();
}

- (BOOL)isAnimationPaused
{
    HLSMissingMethodImplementation();
    return NO;
}

- (void)terminateAnimation
{
    HLSMissingMethodImplementation();
}

- (NSTimeInterval)elapsedTime;
{
    HLSMissingMethodImplementation();
    return 0.;
}

#pragma mark Reverse animation

- (id)reverseAnimationStep
{
    HLSAnimationStep *reverseAnimationStep = [[self class] animationStep];
    for (id object in [self objects]) {
        HLSObjectAnimation *objectAnimation = [self objectAnimationForObject:object];
        [reverseAnimationStep addObjectAnimation:[objectAnimation reverseObjectAnimation] forObject:object];
    }
    reverseAnimationStep.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimationStep.userInfo = self.userInfo;
    reverseAnimationStep.duration = self.duration;
    return reverseAnimationStep;
}

#pragma mark Delegate notification

- (void)notifyAsynchronousAnimationStepDidStopFinished:(BOOL)finished
{
    // If the animation is terminated, this event was already emitted when termination occurs (to avoid
    // waiting too long on this event to occur asynchronously). Do not notify again here
    if (! self.terminating) {
        // This method is meant to be called in the animation stop callback, which is called for animations
        // with animated = YES
        [self.delegate animationStepDidStop:self animated:YES finished:YES];
    }
    
    self.terminating = NO;
    
    self.delegate = nil;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSAnimationStep *animationStepCopy = [[[self class] allocWithZone:zone] init];
    for (id object in [self objects]) {
        HLSObjectAnimation *objectAnimation = [self objectAnimationForObject:object];
        HLSObjectAnimation *objectAnimationCopy = [[objectAnimation copyWithZone:zone] autorelease];
        [animationStepCopy addObjectAnimation:objectAnimationCopy forObject:object];
    }
    animationStepCopy.tag = self.tag;
    animationStepCopy.userInfo = self.userInfo;
    animationStepCopy.duration = self.duration;
    return animationStepCopy;
}

#pragma mark Description

- (NSString *)objectAnimationsDescriptionString
{
    NSString *objectAnimationsDescriptionString = @"{";
    for (id object in [self objects]) {
        HLSObjectAnimation *objectAnimation = [self objectAnimationForObject:object];
        objectAnimationsDescriptionString = [objectAnimationsDescriptionString stringByAppendingFormat:@"\n\t%@ - %@", object, objectAnimation];        
    }
    return [objectAnimationsDescriptionString stringByAppendingFormat:@"\n}"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; objectAnimations: %@; duration: %.2f; tag: %@>",
            [self class],
            self,
            [self objectAnimationsDescriptionString],
            self.duration,
            self.tag];
}

@end
