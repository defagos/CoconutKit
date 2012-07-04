//
//  HLSAnimationStep.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSAnimationStep.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

// Default values as given by Apple UIView documentation
static const double kAnimationStepDefaultDuration = 0.2;
static const UIViewAnimationCurve kAnimationStepDefaultCurve = UIViewAnimationCurveEaseInOut;

@interface HLSAnimationStep ()

@property (nonatomic, retain) NSMutableArray *viewKeys;
@property (nonatomic, retain) NSMutableDictionary *viewToViewAnimationStepMap;

@end

@implementation HLSAnimationStep

#pragma mark Convenience methods

+ (HLSAnimationStep *)animationStep
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.viewKeys = [NSMutableArray array];
        self.viewToViewAnimationStepMap = [NSMutableDictionary dictionary];
        
        // Default animation settings
        self.duration = kAnimationStepDefaultDuration;
        self.curve = kAnimationStepDefaultCurve;   
    }
    return self;
}

- (void)dealloc
{
    self.viewKeys = nil;
    self.viewToViewAnimationStepMap = nil;
    self.tag = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

- (void)addViewAnimationStep:(HLSViewAnimationStep *)viewAnimationStep forView:(UIView *)view
{   
    if (! viewAnimationStep) {
        HLSLoggerInfo(@"View animation step is nil; no animation step added");
        return;
    }
    
    if (! view) {
        HLSLoggerInfo(@"View is nil; no animation step added");
        return;
    }
    
    NSValue *viewKey = [NSValue valueWithPointer:view];
    [self.viewKeys addObject:viewKey];
    [self.viewToViewAnimationStepMap setObject:viewAnimationStep forKey:viewKey];
}

- (NSArray *)views
{
    NSMutableArray *views = [NSMutableArray array];
    for (NSValue *viewKey in self.viewKeys) {
        UIView *view = [viewKey pointerValue];
        [views addObject:view];
    }
    return views;
}

- (HLSViewAnimationStep *)viewAnimationStepForView:(UIView *)view
{
    if (! view) {
        return nil;
    }
    
    NSValue *viewKey = [NSValue valueWithPointer:view];
    return [self.viewToViewAnimationStepMap objectForKey:viewKey];
}

@synthesize viewKeys = m_viewKeys;

@synthesize viewToViewAnimationStepMap = m_viewToViewAnimationStepMap;

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

@synthesize curve = m_curve;

@synthesize tag = m_tag;

#pragma mark Reverse animation

- (HLSAnimationStep *)reverseAnimationStep
{
    HLSAnimationStep *reverseAnimationStep = [HLSAnimationStep animationStep];
    for (UIView *view in [self views]) {
        HLSViewAnimationStep *viewAnimationStep = [self viewAnimationStepForView:view];
        [reverseAnimationStep addViewAnimationStep:[viewAnimationStep reverseViewAnimationStep] forView:view];
    }
    
    // Animation step properties
    reverseAnimationStep.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimationStep.duration = self.duration;
    switch (self.curve) {
        case UIViewAnimationCurveEaseIn:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            reverseAnimationStep.curve = UIViewAnimationCurveEaseIn;
            break;
            
        case UIViewAnimationCurveLinear:
        case UIViewAnimationCurveEaseInOut:
        default:
            // Nothing to do
            break;
    }
    return reverseAnimationStep;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSAnimationStep *animationStepCopy = [[HLSAnimationStep allocWithZone:zone] init];
    for (UIView *view in [self views]) {
        HLSViewAnimationStep *viewAnimationStep = [self viewAnimationStepForView:view];
        [animationStepCopy addViewAnimationStep:[viewAnimationStep copyWithZone:zone] forView:view];
    }
    animationStepCopy.tag = self.tag;
    animationStepCopy.duration = self.duration;
    animationStepCopy.curve = self.curve;
    return animationStepCopy;
}

#pragma mark Description

- (NSString *)description
{
    NSString *viewAnimationStepDescriptions = @"{";
    for (UIView *view in [self views]) {
        HLSViewAnimationStep *viewAnimationStep = [self viewAnimationStepForView:view];
        viewAnimationStepDescriptions = [viewAnimationStepDescriptions stringByAppendingFormat:@"\n\t%@ - %@", view, viewAnimationStep];
    }
    viewAnimationStepDescriptions = [viewAnimationStepDescriptions stringByAppendingFormat:@"\n}"];
    
    return [NSString stringWithFormat:@"<%@: %p; viewAnimationSteps: %@; duration: %f; tag: %@>", 
            [self class],
            self,
            viewAnimationStepDescriptions,
            self.duration,
            self.tag];
}

@end
