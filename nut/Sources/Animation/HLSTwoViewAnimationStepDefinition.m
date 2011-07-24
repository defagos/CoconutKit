//
//  HLSTwoViewAnimationStepDefinition.m
//  nut
//
//  Created by Samuel Défago on 2/9/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTwoViewAnimationStepDefinition.h"

#import "HLSLogger.h"

static const double kTwoViewAnimationStepDefinitionDefaultDuration = 0.2;
static const UIViewAnimationCurve kTwoViewAnimationStepDefinition = UIViewAnimationCurveEaseInOut;

@implementation HLSTwoViewAnimationStepDefinition

#pragma mark Class methods

+ (HLSTwoViewAnimationStepDefinition *)twoViewAnimationStepDefinition
{
    return [[[[self class] alloc] init] autorelease];
}

+ (NSArray *)twoViewAnimationStepDefinitionsForTransitionStyle:(HLSTransitionStyle)transitionStyle
                                              disappearingView:(UIView *)disappearingView
                                                 appearingView:(UIView *)appearingView
                                                 inCommonFrame:(CGRect)commonFrame
{
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            return nil;
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStyleCrossDissolve: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-appearingView.alpha];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-disappearingView.alpha];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:appearingView.alpha];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                        deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:-CGRectGetHeight(commonFrame)];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                        deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                         deltaY:CGRectGetHeight(commonFrame)];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                        deltaY:0.f];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition1.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            animationStepDefinition2.firstViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                        deltaY:0.f];
            animationStepDefinition2.secondViewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                         deltaY:0.f];
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            HLSTwoViewAnimationStepDefinition *animationStepDefinition1 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            HLSViewAnimationStep *secondViewAnimationStep1 = [HLSViewAnimationStep viewAnimationStep];
            secondViewAnimationStep1.transform = CGAffineTransformMakeScale(0.01f, 0.01f);      // cannot use 0.f, otherwise infinite matrix elements
            animationStepDefinition1.secondViewAnimationStep = secondViewAnimationStep1;
            animationStepDefinition1.duration = 0.;
            
            HLSTwoViewAnimationStepDefinition *animationStepDefinition2 = [HLSTwoViewAnimationStepDefinition twoViewAnimationStepDefinition];
            HLSViewAnimationStep *secondViewAnimationStep2 = [HLSViewAnimationStep viewAnimationStep];
            secondViewAnimationStep2.transform = CGAffineTransformInvert(secondViewAnimationStep1.transform);
            animationStepDefinition2.secondViewAnimationStep = secondViewAnimationStep2;
            animationStepDefinition2.duration = 0.4;
            
            return [NSArray arrayWithObjects:animationStepDefinition1,
                    animationStepDefinition2,
                    nil];
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            return nil;
            break;
        }
    }
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
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
