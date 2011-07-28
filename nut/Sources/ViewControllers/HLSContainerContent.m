//
//  HLSContainerContent.m
//  nut
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

#import <objc/runtime.h>

@interface HLSContainerContent ()

/**
 * Creating an animation corresponding to some transition style. The disappearing view controllers will be applied a 
 * corresponding disapperance effect, the appearing view controllers an appearance effect. The commonFrame parameter 
 * is the frame where all animations take place.
 * The timing of the animation depends on the transition style
 */
+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
            withDisappearingContainerContents:(NSArray *)disappearingContainerContents
                   appearingContainerContents:(NSArray *)appearingContainerContents
                                  commonFrame:(CGRect)commonFrame;

/**
 * Same as the previous method, but with the default transition duration overridden. The total duration is distributed
 * among the animation steps so that the animation still looks the same, only slower / faster. Use the special value
 * kAnimationTransitionDefaultDuration as duration to get the default transition duration (same result as the method
 * above)
 */
+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
            withDisappearingContainerContents:(NSArray *)disappearingContainerContents
                   appearingContainerContents:(NSArray *)appearingContainerContents
                                  commonFrame:(CGRect)commonFrame
                                     duration:(NSTimeInterval)duration;

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedAsSubview;
@property (nonatomic, retain) IBOutlet UIView *blockingView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, retain) HLSAnimation *cachedAnimation;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;

@end

static void *kContainerKey = &kContainerKey;

@implementation HLSContainerContent

#pragma mark Class methods

+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
            withDisappearingContainerContents:(NSArray *)disappearingContainerContents
                   appearingContainerContents:(NSArray *)appearingContainerContents
                                  commonFrame:(CGRect)commonFrame
{
    HLSAssertObjectsInEnumerationAreKindOfClass(disappearingContainerContents, HLSContainerContent);
    HLSAssertObjectsInEnumerationAreKindOfClass(appearingContainerContents, HLSContainerContent);
    
    // Remark: If an animation changes the view alpha, be sure to use the originalViewAlpha. Using the current view alpha does not work in general, we
    //         need the initial value, not the one we might have if the animation has already been applied
    
    NSMutableArray *animationSteps = [NSMutableArray array];
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleFadeIn: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                // Important: 
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-appearingContainerContent.originalViewAlpha];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:appearingContainerContent.originalViewAlpha];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-appearingContainerContent.originalViewAlpha];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-disappearingContainerContent.originalViewAlpha];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[disappearingContainerContent view]];                 
            }
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:appearingContainerContent.originalViewAlpha];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {            
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[disappearingContainerContent view]]; 
            }
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:-CGRectGetHeight(commonFrame)];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[disappearingContainerContent view]]; 
            }
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                    deltaY:CGRectGetHeight(commonFrame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[disappearingContainerContent view]]; 
            }
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[disappearingContainerContent view]]; 
            }
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(commonFrame)
                                                                                                                    deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            CGAffineTransform shrinkTransform = CGAffineTransformMakeScale(0.01f, 0.01f);      // cannot use 0.f, otherwise infinite matrix elements
            
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
                viewAnimationStep.transform = shrinkTransform;
                [animationStep1 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *appearingContainerContent in appearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep = [HLSViewAnimationStep viewAnimationStep];
                viewAnimationStep.transform = CGAffineTransformInvert(shrinkTransform);
                [animationStep2 addViewAnimationStep:viewAnimationStep forView:[appearingContainerContent view]]; 
            }
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown transition style");
            return nil;
            break;
        }
    }
    
    return [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
}

+ (HLSAnimation *)animationForTransitionStyle:(HLSTransitionStyle)transitionStyle
            withDisappearingContainerContents:(NSArray *)disappearingContainerContents
                   appearingContainerContents:(NSArray *)appearingContainerContents
                                  commonFrame:(CGRect)commonFrame
                                     duration:(NSTimeInterval)duration
{
    HLSAnimation *animation = [self animationForTransitionStyle:transitionStyle 
                              withDisappearingContainerContents:disappearingContainerContents 
                                     appearingContainerContents:appearingContainerContents
                                                    commonFrame:commonFrame];
    
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
    }
    
    // Sanitize input
    if (doublelt(duration, 0.)) {
        HLSLoggerWarn(@"Duration must be non-negative. Fixed to 0");
        duration = 0.;
    }
    
    // Calculate the total animation duration
    NSTimeInterval totalDuration = 0.;
    for (HLSAnimationStep *animationStep in animation.animationSteps) {
        totalDuration += animationStep.duration;
    }
    
    // Find out which factor must be applied to each animation step to preserve the animation appearance for the specified duration
    double factor = duration / totalDuration;
    
    // Distribute the total duration evenly among animation steps
    for (HLSAnimationStep *animationStep in animation.animationSteps) {
        animationStep.duration *= factor;
    }
    
    return animation;
}

+ (id)containerControllerForViewController:(UIViewController *)viewController;
{
    return objc_getAssociatedObject(viewController, kContainerKey);
}

#pragma mark Object creation and destruction

- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
{
    if ((self = [super init])) {
        NSAssert(viewController != nil, @"View controller cannot be nil");
        NSAssert(containerController != nil, @"The container cannot be nil");
        
        // Associate the view controller with its container
        NSAssert(! objc_getAssociatedObject(viewController, kContainerKey), @"A view controller can only be inserted into one container controller");
        objc_setAssociatedObject(viewController, kContainerKey, self, OBJC_ASSOCIATION_ASSIGN);
        
        self.viewController = viewController;
        self.transitionStyle = transitionStyle;
        self.duration = duration;
        
        self.originalViewFrame = CGRectZero;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    // Restore the view controller's frame. If the view controller was not retained elsewhere, this is
    // unnecessary. But clients might keep additional references to view controllers for caching purposes.
    // The cleanest we can do is to restore view controller properties when it is removed from a container,
    // no matter whether it is actually reused later or not
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    
    // Remove the association of the view controller with its container
    NSAssert(objc_getAssociatedObject(self.viewController, kContainerKey), @"The view controller was not inserted into a container controller");
    objc_setAssociatedObject(self.viewController, kContainerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    self.viewController = nil;
    self.blockingView = nil;
    self.cachedAnimation = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize addedAsSubview = m_addedAsSubview;

@synthesize blockingView = m_blockingView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

@synthesize cachedAnimation = m_cachedAnimation;

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

- (UIView *)view
{
    if (! self.addedAsSubview) {
        HLSLoggerWarn(@"View not loaded");
        return nil;
    }
    else {
        return self.viewController.view;
    }
}

#pragma mark View management

- (void)addViewToContainerView:(UIView *)containerView 
              blockInteraction:(BOOL)blockInteraction
{
    if (self.addedAsSubview) {
        HLSLoggerInfo(@"View controller's view already added as subview");
        return;
    }
    
    // This triggers lazy view creation
    [containerView addSubview:self.viewController.view];
    self.addedAsSubview = YES;
    
    // Insert blocking subview if required
    if (blockInteraction) {
        self.blockingView = [[[UIView alloc] initWithFrame:containerView.frame] autorelease];
        self.blockingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView insertSubview:self.blockingView belowSubview:self.viewController.view];
    }
    
    // Save original view controller's view properties
    self.originalViewFrame = self.viewController.view.frame;
    self.originalViewAlpha = self.viewController.view.alpha;
}

- (void)removeViewFromContainerView
{
    if (! self.addedAsSubview) {
        HLSLoggerInfo(@"View controller's view is not added as subview");
        return;
    }
    
    // Remove the view controller's view
    [self.viewController.view removeFromSuperview];
    self.addedAsSubview = NO;
    
    // Remove the blocking view (if any)
    [self.blockingView removeFromSuperview];
    self.blockingView = nil;
    
    // Restore view controller original properties (this way, it might be reused somewhere else)
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    
    // Reset saved properties
    self.originalViewFrame = CGRectZero;
    self.originalViewAlpha = 0.f;
}

- (void)releaseView
{
    self.viewController.view = nil;
    self.cachedAnimation = nil;
}

#pragma mark Animation

- (HLSAnimation *)createAnimationWithDisappearingContainerContents:(NSArray *)disappearingContainerContents
                                                       commonFrame:(CGRect)commonFrame
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(disappearingContainerContents, HLSContainerContent);
    self.cachedAnimation = [HLSContainerContent animationForTransitionStyle:self.transitionStyle 
                                          withDisappearingContainerContents:disappearingContainerContents 
                                                 appearingContainerContents:[NSArray arrayWithObject:self] 
                                                                commonFrame:commonFrame];
    return self.cachedAnimation;
}

- (HLSAnimation *)reverseAnimation
{
    return [self.cachedAnimation reverseAnimation];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; viewController: %@; addedAsSubview: %@>", 
            [self class],
            self,
            self.viewController,
            self.addedAsSubview];
}

@end
