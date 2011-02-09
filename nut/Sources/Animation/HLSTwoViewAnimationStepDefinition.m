//
//  HLSTwoViewAnimationStepDefinition.m
//  nut
//
//  Created by Samuel Défago on 2/9/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTwoViewAnimationStepDefinition.h"

static const double kTwoViewAnimationStepDefinitionDefaultDuration = 0.2;
static const UIViewAnimationCurve kTwoViewAnimationStepDefinition = UIViewAnimationCurveEaseInOut;

@implementation HLSTwoViewAnimationStepDefinition

#pragma mark Class methods

+ (HLSTwoViewAnimationStepDefinition *)twoViewAnimationStepDefinition
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.duration = kTwoViewAnimationStepDefinitionDefaultDuration;
        self.curve = kTwoViewAnimationStepDefinition;
    }
    return self;
}

- (void)dealloc
{
    self.firstViewAnimationStep = nil;
    self.secondViewAnimationStep = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize firstViewAnimationStep = m_firstViewAnimationStep;

@synthesize secondViewAnimationStep = m_secondViewAnimationStep;

@synthesize duration = m_duration;

@synthesize curve = m_curve;

#pragma mark Animation step generation

- (HLSAnimationStep *)animationStepWithFirstView:(UIView *)firstViewOrNil
                                      secondView:(UIView *)secondViewOrNil
{
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStep];
    if (firstViewOrNil && self.firstViewAnimationStep) {
        [animationStep addViewAnimationStep:self.firstViewAnimationStep 
                                    forView:firstViewOrNil];
    }
    if (secondViewOrNil && self.secondViewAnimationStep) {
        [animationStep addViewAnimationStep:self.secondViewAnimationStep 
                                    forView:secondViewOrNil];
    }
    animationStep.duration = self.duration;
    animationStep.curve = self.curve;
    
    return animationStep;
}

@end
