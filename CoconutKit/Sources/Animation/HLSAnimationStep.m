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
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSObjectAnimation+Friend.h"
#import "NSString+HLSExtensions.h"

@interface HLSAnimationStep ()

@property (nonatomic, retain) NSMutableArray *objectKeys;
@property (nonatomic, retain) NSMutableDictionary *objectToObjectAnimationMap;
@property (nonatomic, retain) id<HLSAnimationStepDelegate> delegate;        // Set during animated animations to retain the delegate during animation

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
    self.delegate = nil;
    
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

@synthesize delegate = m_delegate;

@synthesize running = m_running;

@synthesize animating = m_animating;

@synthesize cancelling = m_cancelling;

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

- (void)playWithDelegate:(id<HLSAnimationStepDelegate>)delegate afterDelay:(NSTimeInterval)delay animated:(BOOL)animated
{
    if (self.running) {
        HLSLoggerInfo(@"The animation step is already running");
        return;
    }
    
    self.running = YES;
    self.cancelling = NO;
    
    BOOL actuallyAnimated = animated && ! doubleeq(self.duration, 0.f);
    
    if (! actuallyAnimated) {
        // Give the caller the original animated information (even if duration is zero) so that animations with duration 0
        // played animated are still considered to be played animated
        [delegate animationStepWillStart:self animated:animated];
    }
    // Retain the delegate during the time of the animation (this is based on the assumption
    // that animations implemented in subclasses do the same, and that they always call the
    // animation delegate stop method, which is the case for UIView animations and CAAnimations
    else {
        self.delegate = delegate;
    }
    
    [self playAnimationAfterDelay:delay animated:actuallyAnimated];
    
    if (! actuallyAnimated) {
        // Give the caller the original animated information (even if duration is zero) so that animations with duration 0
        // played animated are still considered to be played animated
        [delegate animationStepDidStop:self animated:animated finished:YES];
        
        self.running = NO;
    }
}

- (void)cancel
{
    if (! self.running) {
        HLSLoggerDebug(@"The animation step is not running, nothing to cancel");
        return;
    }
    
    if (self.cancelling) {
        HLSLoggerDebug(@"The animation step is already being cancelled");
        return;
    }
    
    self.cancelling = YES;
    
    [self cancelAnimation];
    
    // Cancel occurs during the initial delay period
    if (! self.animating) {
        // Must notify manually (the willStart callback is still called, but too late. We want to get this event
        // on the spot)
        if ([self.delegate respondsToSelector:@selector(animationStepWillStart:animated:)]) {
            [self.delegate animationStepWillStart:self animated:NO];
        }        
    }
    
    // The animation callback might be called (it might depend on subclasses, but currently this is the case for UIView
    // bock-based animations and CoreAnimations), but to get delegate events in the proper order we cannot notify that
    // the animation step has ended there. We must do it right here
    if ([self.delegate respondsToSelector:@selector(animationStepDidStop:animated:finished:)]) {
        [self.delegate animationStepDidStop:self animated:NO finished:NO];
    }
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
    reverseAnimationStep.duration = self.duration;
    return reverseAnimationStep;
}

#pragma mark Delegate notification

- (void)notifyDelegateAnimationStepWillStart
{
    if (! self.cancelling) {
        [self.delegate animationStepWillStart:self animated:YES];
    }
    
    self.animating = YES;
}

- (void)notifyDelegateAnimationStepDidStopFinished:(BOOL)finished
{
    // If the animation was cancelled, we do not notify from end callbacks (where this method is supposedly being called)
    if (! self.cancelling) {
        [self.delegate animationStepDidStop:self animated:YES finished:YES];
    }
    
    self.animating = NO;
    self.cancelling = NO;
    
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
    animationStepCopy.duration = self.duration;
    return animationStepCopy;
}

#pragma mark Description

- (NSString *)objectAnimationDescriptionString
{
    NSString *objectAnimationDescriptionString = @"{";
    for (id object in [self objects]) {
        HLSObjectAnimation *objectAnimation = [self objectAnimationForObject:object];
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
