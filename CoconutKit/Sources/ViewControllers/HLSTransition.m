//
//  HLSTransitions.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/8/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSTransition.h"

#import "HLSAssert.h"
#import "HLSFloat.h"
#import "NSSet+HLSExtensions.h"
#import <objc/runtime.h>

// Constants
const NSTimeInterval kAnimationTransitionDefaultDuration = -1.;

static CGFloat kPushToTheBackScaleFactor = 0.95f;
static CGFloat kEmergeFromCenterScaleFactor = 0.01f;      // cannot use 0.f, otherwise infinite transform matrix elements

@interface HLSTransition ()

+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView;

+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                                      appearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView;

+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView;

@end

@implementation HLSTransition

#pragma mark Getting the available transition class list

+ (NSArray *)availableTransitionNames
{
    static NSArray *s_availableTransitionNames = nil;
    if (! s_availableTransitionNames) {
        NSMutableArray *availableTransitionNames = [NSMutableArray array];
        
        // Find all HLSTransition subclasses (except HLSTransition itself)
        int numberOfClasses = objc_getClassList(NULL, 0);
        if (numberOfClasses > 0) {
            Class *classes = malloc(numberOfClasses * sizeof(Class));
            objc_getClassList(classes, numberOfClasses);
            for (int i = 0; i < numberOfClasses; ++i) {
                Class class = classes[i];
                
                // Discard HLSTransition
                if (class == [HLSTransition class]) {
                    continue;
                }
                
                // Find whether HLSTransition is a superclass. We cannot use isSubclassOfClass: since it is an NSObject
                // method and we might encounter other kinds of classes
                // TODO: Factor out in HLSRuntime.h after merge with url-networking branch
                Class superclass = class;
                do {
                    superclass = class_getSuperclass(superclass);
                } while (superclass && superclass != [HLSTransition class]);
                
                if (! superclass) {
                    continue;
                }
                
                [availableTransitionNames addObject:NSStringFromClass(class)];
            }
            free(classes);
        }
        s_availableTransitionNames = [[availableTransitionNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
    }
    return s_availableTransitionNames;
}

#pragma mark Built-in transition common code

+ (HLSAnimation *)coverAnimationWithInitialXOffset:(CGFloat)xOffset
                                           yOffset:(CGFloat)yOffset
                                     appearingView:(UIView *)appearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)coverAnimation2WithInitialXOffset:(CGFloat)xOffset
                                            yOffset:(CGFloat)yOffset
                                      appearingView:(UIView *)appearingView
                                   disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)pushAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)pushAndFadeAnimationWithInitialXOffset:(CGFloat)xOffset
                                                 yOffset:(CGFloat)yOffset
                                           appearingView:(UIView *)appearingView
                                        disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = -1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = 1.f;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)flowAnimationWithInitialXOffset:(CGFloat)xOffset
                                          yOffset:(CGFloat)yOffset
                                    appearingView:(UIView *)appearingView
                                 disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 translateByVectorWithX:xOffset y:yOffset z:0.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep31 translateByVectorWithX:-xOffset y:-yOffset z:0.f];
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:disappearingView];
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:appearingView];
    animationStep3.duration = 0.2;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 scaleWithXFactor:1.f / kPushToTheBackScaleFactor yFactor:1.f / kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:disappearingView];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:appearingView];
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    // Make the disappearing view disappear. Otherwise the view which disappeared might be visible if we apply the same
    // effect to push another view controller
    HLSAnimationStep *animationStep5 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep51 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep51.alphaVariation = -1.f;
    [animationStep5 addViewAnimationStep:viewAnimationStep51 forView:disappearingView];
    animationStep5.duration = 0.;
    [animationSteps addObject:animationStep5];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)flipAnimationAroundVectorWithX:(CGFloat)x
                                               y:(CGFloat)y
                                               z:(CGFloat)z
                                   appearingView:(UIView *)appearingView
                                disappearingView:(UIView *)disappearingView
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 rotateByAngle:M_PI aboutVectorWithX:x y:y z:z];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep21.alphaVariation = -0.5f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep22 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.curve = UIViewAnimationCurveEaseOut;
    animationStep2.duration = 0.2;
    [animationSteps addObject:animationStep2];
    
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep31 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep31.alphaVariation = 0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep31 forView:appearingView];
    HLSViewAnimationStep *viewAnimationStep32 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep32.alphaVariation = -0.5f;
    [animationStep3 addViewAnimationStep:viewAnimationStep32 forView:disappearingView];
    animationStep3.duration = 0.;
    [animationSteps addObject:animationStep3];
    
    HLSAnimationStep *animationStep4 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep41 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep41 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    [animationStep4 addViewAnimationStep:viewAnimationStep41 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep42 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep42 rotateByAngle:-M_PI_2 aboutVectorWithX:x y:y z:z];
    viewAnimationStep42.alphaVariation = 0.5f;
    [animationStep4 addViewAnimationStep:viewAnimationStep42 forView:appearingView];
    animationStep4.curve = UIViewAnimationCurveEaseIn;
    animationStep4.duration = 0.2;
    [animationSteps addObject:animationStep4];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

#pragma mark Default transition implementation

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSAnimation animationWithAnimationStep:nil];
}

@end

@implementation HLSTransitionNone

// Same as HLSTransition, i.e. empty animation

@end

@implementation HLSTransitionCoverFromBottom

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:0.f
                                                   yOffset:CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTop

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:0.f
                                                   yOffset:-CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromLeft

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                   yOffset:0.f
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromRight

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                   yOffset:0.f
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeft

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                   yOffset:-CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromTopRight

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                   yOffset:-CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeft

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                   yOffset:CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRight

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                   yOffset:CGRectGetHeight(frame)
                                             appearingView:appearingView];
}

@end

@implementation HLSTransitionCoverFromBottom2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:0.f
                                                    yOffset:CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTop2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:0.f
                                                    yOffset:-CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromLeft2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                    yOffset:0.f
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromRight2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                    yOffset:0.f
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopLeft2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                    yOffset:-CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromTopRight2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                    yOffset:-CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomLeft2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:-CGRectGetWidth(frame)
                                                    yOffset:CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionCoverFromBottomRight2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition coverAnimation2WithInitialXOffset:CGRectGetWidth(frame)
                                                    yOffset:CGRectGetHeight(frame)
                                              appearingView:appearingView
                                           disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFadeIn

// The new view fades in. The view below is left as is
+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

@end

@implementation HLSTransitionFadeIn2

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:kPushToTheBackScaleFactor yFactor:kPushToTheBackScaleFactor zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:disappearingView];
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

@end

@implementation HLSTransitionCrossDissolve

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.alphaVariation = -1.f;
    HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep22.alphaVariation = 1.f;
    [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

@end

@implementation HLSTransitionPushFromBottom

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationWithInitialXOffset:0.f
                                                  yOffset:CGRectGetHeight(frame)
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTop

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationWithInitialXOffset:0.f
                                                  yOffset:-CGRectGetHeight(frame)
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeft

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                  yOffset:0.f
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRight

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                  yOffset:0.f
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromBottomFadeIn

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationWithInitialXOffset:0.f
                                                         yOffset:CGRectGetHeight(frame)
                                                   appearingView:appearingView
                                                disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromTopFadeIn

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationWithInitialXOffset:0.f
                                                         yOffset:-CGRectGetHeight(frame)
                                                   appearingView:appearingView
                                                disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromLeftFadeIn

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                         yOffset:0.f
                                                   appearingView:appearingView
                                                disappearingView:disappearingView];
}

@end

@implementation HLSTransitionPushFromRightFadeIn

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition pushAndFadeAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                         yOffset:0.f
                                                   appearingView:appearingView
                                                disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromBottom

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationWithInitialXOffset:0.f
                                                  yOffset:CGRectGetHeight(frame)
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromTop

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationWithInitialXOffset:0.f
                                                  yOffset:-CGRectGetHeight(frame)
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromLeft

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationWithInitialXOffset:-CGRectGetWidth(frame)
                                                  yOffset:0.f
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlowFromRight

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flowAnimationWithInitialXOffset:CGRectGetWidth(frame)
                                                  yOffset:0.f
                                            appearingView:appearingView
                                         disappearingView:disappearingView];
}

@end

@implementation HLSTransitionEmergeFromCenter

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep11 scaleWithXFactor:kEmergeFromCenterScaleFactor yFactor:kEmergeFromCenterScaleFactor zFactor:1.f];
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:appearingView];
    animationStep1.duration = 0.;
    [animationSteps addObject:animationStep1];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    [viewAnimationStep21 scaleWithXFactor:1.f / kEmergeFromCenterScaleFactor
                                  yFactor:1.f / kEmergeFromCenterScaleFactor
                                  zFactor:1.f];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:appearingView];
    animationStep2.duration = 0.4;
    [animationSteps addObject:animationStep2];
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

@end

@implementation HLSTransitionFlipVertical

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flipAnimationAroundVectorWithX:0.f
                                                       y:1.f
                                                       z:0.f
                                           appearingView:appearingView
                                        disappearingView:disappearingView];
}

@end

@implementation HLSTransitionFlipHorizontal

+ (HLSAnimation *)animationWithAppearingView:(UIView *)appearingView
                            disappearingView:(UIView *)disappearingView
                                     inFrame:(CGRect)frame
{
    return [HLSTransition flipAnimationAroundVectorWithX:1.f
                                                       y:0.f
                                                       z:0.f
                                           appearingView:appearingView
                                        disappearingView:disappearingView];
}

@end

