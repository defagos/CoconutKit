//
//  HLSViewAnimationGroup.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/10/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSViewAnimationGroup.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@interface HLSViewAnimationGroup ()

@property (nonatomic, retain) NSMutableArray *viewKeys;
@property (nonatomic, retain) NSMutableDictionary *viewToViewAnimationMap;

@end

@implementation HLSViewAnimationGroup

#pragma mark Convenience methods

+ (HLSViewAnimationGroup *)viewAnimationGroup
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.viewKeys = [NSMutableArray array];
        self.viewToViewAnimationMap = [NSMutableDictionary dictionary];
        
        // Default animation settings (as given in UIKit documentation)
        self.duration = 0.2;
        self.curve = UIViewAnimationCurveEaseInOut;   
    }
    return self;
}

- (void)dealloc
{
    self.viewKeys = nil;
    self.viewToViewAnimationMap = nil;
    self.tag = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

- (void)addViewAnimation:(HLSViewAnimation *)viewAnimation forView:(UIView *)view
{   
    if (! viewAnimation) {
        HLSLoggerDebug(@"View animation is nil");
        return;
    }
    
    if (! view) {
        HLSLoggerDebug(@"View is nil; no view animation added");
        return;
    }
    
    NSValue *viewKey = [NSValue valueWithPointer:view];
    [self.viewKeys addObject:viewKey];
    [self.viewToViewAnimationMap setObject:viewAnimation forKey:viewKey];
}

- (NSArray *)views
{
    NSMutableArray *views = [NSMutableArray array];
    for (NSValue *viewKey in self.viewKeys) {
        UIView *view = [viewKey pointerValue];
        [views addObject:view];
    }
    return [NSArray arrayWithArray:views];
}

- (HLSViewAnimation *)viewAnimationForView:(UIView *)view
{
    if (! view) {
        return nil;
    }
    
    NSValue *viewKey = [NSValue valueWithPointer:view];
    return [self.viewToViewAnimationMap objectForKey:viewKey];
}

@synthesize viewKeys = m_viewKeys;

@synthesize viewToViewAnimationMap = m_viewToViewAnimationMap;

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

- (CGFloat)alphaVariationForView:(UIView *)view
{
    HLSViewAnimation *viewAnimation = [self viewAnimationForView:view];
    return viewAnimation.alphaVariation;
}

#pragma mark Reverse animation

- (HLSViewAnimationGroup *)reverseViewAnimationGroup
{
    HLSViewAnimationGroup *reverseAnimationGroup = [HLSViewAnimationGroup viewAnimationGroup];
    for (UIView *view in [self views]) {
        HLSViewAnimation *viewAnimation = [self viewAnimationForView:view];
        [reverseAnimationGroup addViewAnimation:[viewAnimation reverseViewAnimation] forView:view];
    }
    
    // Animation group properties
    reverseAnimationGroup.tag = [self.tag isFilled] ? [NSString stringWithFormat:@"reverse_%@", self.tag] : nil;
    reverseAnimationGroup.duration = self.duration;
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
    return reverseAnimationGroup;
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    HLSViewAnimationGroup *animationGroupCopy = [[HLSViewAnimationGroup allocWithZone:zone] init];
    for (UIView *view in [self views]) {
        HLSViewAnimation *viewAnimation = [self viewAnimationForView:view];
        HLSViewAnimation *viewAnimationCopy = [[viewAnimation copyWithZone:zone] autorelease];
        [animationGroupCopy addViewAnimation:viewAnimationCopy forView:view];
    }
    animationGroupCopy.tag = self.tag;
    animationGroupCopy.duration = self.duration;
    animationGroupCopy.curve = self.curve;
    return animationGroupCopy;
}

#pragma mark Description

- (NSString *)description
{
    NSString *viewAnimationDescriptions = @"{";
    for (UIView *view in [self views]) {
        HLSViewAnimation *viewAnimation = [self viewAnimationForView:view];
        viewAnimationDescriptions = [viewAnimationDescriptions stringByAppendingFormat:@"\n\t%@ - %@", view, viewAnimation];
    }
    viewAnimationDescriptions = [viewAnimationDescriptions stringByAppendingFormat:@"\n}"];
    
    return [NSString stringWithFormat:@"<%@: %p; viewAnimations: %@; duration: %f; tag: %@>", 
            [self class],
            self,
            viewAnimationDescriptions,
            self.duration,
            self.tag];
}

@end
