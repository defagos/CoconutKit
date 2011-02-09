//
//  HLSOneViewAnimationStepDefinition.m
//  nut
//
//  Created by Samuel Défago on 2/9/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSOneViewAnimationStepDefinition.h"

static const double kOneViewAnimationStepDefinitionDefaultDuration = 0.2;
static const UIViewAnimationCurve kOneViewAnimationStepDefinition = UIViewAnimationCurveEaseInOut;

@implementation HLSOneViewAnimationStepDefinition

#pragma mark Class methods

+ (HLSOneViewAnimationStepDefinition *)oneViewAnimationStepDefinition
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.duration = kOneViewAnimationStepDefinitionDefaultDuration;
        self.curve = kOneViewAnimationStepDefinition;
    }
    return self;
}

- (void)dealloc
{
    self.viewAnimationStep = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewAnimationStep = m_viewAnimationStep;

@synthesize duration = m_duration;

@synthesize curve = m_curve;

#pragma mark Animation step generation

- (HLSAnimationStep *)animationStepWithView:(UIView *)viewOrNil
{
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    if (viewOrNil && self.viewAnimationStep) {
        [animationStep addViewAnimationStep:self.viewAnimationStep 
                                    forView:viewOrNil];
    }
    animationStep.duration = self.duration;
    animationStep.curve = self.curve;
    
    return animationStep;
}

@end
