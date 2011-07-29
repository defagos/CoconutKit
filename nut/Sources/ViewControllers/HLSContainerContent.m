//
//  HLSContainerContent.m
//  nut
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSContainerContent.h"

#import "HLSAssert.h"
#import "HLSConverters.h"
#import "HLSFloat.h"
#import "HLSLogger.h"

#import <objc/runtime.h>

// Keys for runtime container - view controller object association
static void *kContainerControllerKey = &kContainerControllerKey;
static void *kContainerContentKey = &kContainerContentKey;

static id (*UIViewController__navigationController)(id, SEL) = NULL;
static id (*UIViewController__navigationItem)(id, SEL) = NULL;
static void (*UIViewController__setTitle)(id, SEL, id) = NULL;

// Container content property forwarding
// TODO: Other methods (setTitle, toolbar, etc.). Update documentation accordingly
static id placeholderForwardGetter(UIViewController *self, SEL _cmd)
{
    id (*UIViewControllerMethod)(id, SEL) = NULL;
    if (_cmd == @selector(navigationController)) {
        UIViewControllerMethod = UIViewController__navigationController;
    }
    else if (_cmd == @selector(navigationItem)) {
        UIViewControllerMethod = UIViewController__navigationItem;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property getter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Is forwarding enabled? Retrieve associated container content object to know it
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, kContainerContentKey);
    id containerController = objc_getAssociatedObject(self, kContainerControllerKey);
    // Forwarding only makes sense if the controller itself is a view controller; if not, call original implementation
    if (containerContent.viewControllerContainerForwardingEnabled && [containerController isKindOfClass:[UIViewController class]]) {
        return UIViewControllerMethod(containerController, _cmd);
    }
    else {
        return UIViewControllerMethod(self, _cmd);
    }
}

static void placeholderForwardSetter(UIViewController *self, SEL _cmd, id value)
{
    void(*UIViewControllerMethod)(id, SEL, id) = NULL;
    if (_cmd == @selector(setTitle:)) {
        UIViewControllerMethod = UIViewController__setTitle;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property setter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Is forwarding enabled? Retrieve associated container content object to know it
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, kContainerContentKey);
    id containerController = objc_getAssociatedObject(self, kContainerControllerKey);
    // Forwarding only makes sense if the controller itself is a view controller; if not, call original implementation
    if (containerContent.viewControllerContainerForwardingEnabled && [containerController isKindOfClass:[UIViewController class]]) {
        UIViewControllerMethod(containerController, _cmd, value);
    }
    else {
        UIViewControllerMethod(self, _cmd, value);
    }
}

@interface HLSContainerContent ()

/**
 * Create an animation corresponding to some transition style. The disappearing view controllers will be applied a 
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
@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedToContainerView;
@property (nonatomic, retain) IBOutlet UIView *blockingView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, retain) HLSAnimation *cachedAnimation;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;

- (BOOL)addViewIntoContainerView:(UIView *)containerView 
           otherContainerContent:(HLSContainerContent *)otherContainerContent
                           above:(BOOL)above
                         stretch:(BOOL)stretch
                blockInteraction:(BOOL)blockInteraction;

@end

@implementation HLSContainerContent

#pragma mark Class methods

+ (void)load
{
    // Swizzle methods ASAP. Cannot be in +initialize since those methods might be called before an HLSContainerContent is actually created for the
    // first tiime
    UIViewController__navigationController = (id (*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationController), (IMP)placeholderForwardGetter, NULL);
    UIViewController__navigationItem = (id (*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationItem), (IMP)placeholderForwardGetter, NULL);
    UIViewController__setTitle = (void (*)(id, SEL, id))class_replaceMethod([UIViewController class], @selector(setTitle:), (IMP)placeholderForwardSetter, NULL);
}

// TODO: When bringToFront is set to YES for HLSAnimation (which is the case here), we can change the z-order of views during the animation.
//       This could let create funny effects (e.g. shuffling views: the new inset is below the new one, both centered; the old one moves to 
//       the left, the new one to the right. When their borders match, the new one is brought on top, the old one to the bottom, and
//       both are moved to the center again.
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
    return objc_getAssociatedObject(viewController, kContainerControllerKey);
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
        NSAssert(! objc_getAssociatedObject(viewController, kContainerControllerKey), @"A view controller can only be inserted into one container controller");
        objc_setAssociatedObject(viewController, kContainerControllerKey, containerController, OBJC_ASSOCIATION_ASSIGN);
        
        // Associate the view controller with its container content object
        NSAssert(! objc_getAssociatedObject(viewController, kContainerContentKey), @"A view controller can only be associated with one container content object");
        objc_setAssociatedObject(viewController, kContainerContentKey, self, OBJC_ASSOCIATION_ASSIGN);
                
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
    // Restore the view controller's frame. If the view controller was not retained elsewhere, this would not be necessary. 
    // But clients might keep additional references to view controllers for caching purposes. The cleanest we can do is to 
    // restore a view controller's properties when it is removed from a container, no matter whether or not it is later 
    // reused by the client
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    
    // Remove the association of the view controller with its container
    NSAssert(objc_getAssociatedObject(self.viewController, kContainerControllerKey), @"The view controller was not inserted into a container controller");
    objc_setAssociatedObject(self.viewController, kContainerControllerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    // Remove the association of the view controller with its content container object
    NSAssert(objc_getAssociatedObject(self.viewController, kContainerContentKey), @"The view controller was not associated with a content container");
    objc_setAssociatedObject(self.viewController, kContainerContentKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    self.viewController = nil;
    self.blockingView = nil;
    self.cachedAnimation = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize addedToContainerView = m_addedToContainerView;

@synthesize blockingView = m_blockingView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

@synthesize viewControllerContainerForwardingEnabled = m_viewControllerContainerForwardingEnabled;

- (void)setViewControllerContainerForwardingEnabled:(BOOL)viewControllerContainerForwardingEnabled
{
    if (m_viewControllerContainerForwardingEnabled == viewControllerContainerForwardingEnabled) {
        return;
    }
    
    m_viewControllerContainerForwardingEnabled = viewControllerContainerForwardingEnabled;

    if (viewControllerContainerForwardingEnabled) {
        id containerController = [HLSContainerContent containerControllerForViewController:self.viewController];
        if ([containerController isKindOfClass:[UIViewController class]]) {
            UIViewController *containerViewController = (UIViewController *)containerController;
            containerViewController.title = self.viewController.title;
            containerViewController.navigationItem.title = self.viewController.navigationItem.title;
            containerViewController.navigationItem.backBarButtonItem = self.viewController.navigationItem.backBarButtonItem;
            containerViewController.navigationItem.titleView = self.viewController.navigationItem.titleView;
            containerViewController.navigationItem.prompt = self.viewController.navigationItem.prompt;
            containerViewController.navigationItem.hidesBackButton = self.viewController.navigationItem.hidesBackButton;
            containerViewController.navigationItem.leftBarButtonItem = self.viewController.navigationItem.leftBarButtonItem;
            containerViewController.navigationItem.rightBarButtonItem = self.viewController.navigationItem.rightBarButtonItem;
        }   
    }
}

@synthesize cachedAnimation = m_cachedAnimation;

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

- (UIView *)view
{
    if (! self.addedToContainerView) {
        HLSLoggerWarn(@"View not added to a container view");
        return nil;
    }
    else {
        return self.viewController.view;
    }
}

#pragma mark View management

- (BOOL)addViewToContainerView:(UIView *)containerView 
                       stretch:(BOOL)stretch
              blockInteraction:(BOOL)blockInteraction
{
    return [self addViewIntoContainerView:containerView
                    otherContainerContent:nil 
                                    above:NO
                                  stretch:stretch
                         blockInteraction:blockInteraction];
}

- (BOOL)insertViewIntoContainerView:(UIView *)containerView 
              belowContainerContent:(HLSContainerContent *)containerContent
                            stretch:(BOOL)stretch
                   blockInteraction:(BOOL)blockInteraction
{
    return [self addViewIntoContainerView:containerView
                    otherContainerContent:containerContent 
                                    above:NO
                                  stretch:stretch
                         blockInteraction:blockInteraction];
}

- (BOOL)insertViewIntoContainerView:(UIView *)containerView 
              aboveContainerContent:(HLSContainerContent *)containerContent
                            stretch:(BOOL)stretch
                   blockInteraction:(BOOL)blockInteraction
{
    return [self addViewIntoContainerView:containerView
                    otherContainerContent:containerContent 
                                    above:YES
                                  stretch:stretch
                         blockInteraction:blockInteraction];    
}

- (BOOL)addViewIntoContainerView:(UIView *)containerView 
           otherContainerContent:(HLSContainerContent *)otherContainerContent
                           above:(BOOL)above        // irrelevant when no other container controller
                         stretch:(BOOL)stretch
                blockInteraction:(BOOL)blockInteraction
{
    if (self.addedToContainerView) {
        HLSLoggerInfo(@"View controller's view already added as to a container view");
        return NO;
    }
    
    // If no other container content provided, simply add it to the as top container subview
    if (! otherContainerContent) {
        [containerView addSubview:self.viewController.view];    
    }
    // Other container content provided, insert above or below
    else {
        NSAssert([HLSContainerContent containerControllerForViewController:self.viewController] 
                 == [HLSContainerContent containerControllerForViewController:otherContainerContent.viewController], 
                 @"Both container contents must be associated with the same container controller");
        NSAssert([otherContainerContent view].superview == containerView, 
                 @"Other container contents was not added to the same container view");
        if (above) {
            [containerView insertSubview:self.viewController.view aboveSubview:[otherContainerContent view]];
        }
        else {
            [containerView insertSubview:self.viewController.view belowSubview:otherContainerContent.blockingView];
        }
    }
    
    self.addedToContainerView = YES;
    
    // Insert blocking subview if required
    if (blockInteraction) {
        self.blockingView = [[[UIView alloc] initWithFrame:containerView.frame] autorelease];
        self.blockingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView insertSubview:self.blockingView belowSubview:self.viewController.view];
    }
    
    // Save original view controller's view properties
    self.originalViewFrame = self.viewController.view.frame;
    self.originalViewAlpha = self.viewController.view.alpha;
    
    // Stretching
    if (stretch) {
        self.viewController.view.frame = containerView.bounds;
    }
    
    return YES;
}

- (void)removeViewFromContainerView
{
    if (! self.addedToContainerView) {
        HLSLoggerInfo(@"View controller's view is not added to a container view");
        return;
    }
    
    // Remove the view controller's view
    [self.viewController.view removeFromSuperview];
    self.addedToContainerView = NO;
    
    // Remove the blocking view (if any)
    [self.blockingView removeFromSuperview];
    self.blockingView = nil;
    
    // Restore view controller original properties (this way, if addViewToContainerView:stretch:blockInteraction:
    // is called again later, it will get the view controller's view in its original state)
    self.viewController.view.frame = self.originalViewFrame;
    self.viewController.view.alpha = self.originalViewAlpha;
    
    // Reset saved properties
    self.originalViewFrame = CGRectZero;
    self.originalViewAlpha = 0.f;
}

- (void)releaseViews
{
    [self removeViewFromContainerView];
    self.cachedAnimation = nil;
    
    if ([self.viewController isViewLoaded]) {
        self.viewController.view = nil;
        [self.viewController viewDidUnload];
    }
}

#pragma mark Animation

- (HLSAnimation *)createAnimationWithDisappearingContainerContents:(NSArray *)disappearingContainerContents
                                                       commonFrame:(CGRect)commonFrame
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(disappearingContainerContents, HLSContainerContent);
    self.cachedAnimation = [HLSContainerContent animationForTransitionStyle:self.transitionStyle 
                                          withDisappearingContainerContents:disappearingContainerContents 
                                                 appearingContainerContents:[NSArray arrayWithObject:self] 
                                                                commonFrame:commonFrame
                                                                   duration:self.duration];
    return self.cachedAnimation;
}

- (HLSAnimation *)reverseAnimation
{
    return [self.cachedAnimation reverseAnimation];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; viewController: %@; addedToContainerView: %@; view: %@>", 
            [self class],
            self,
            self.viewController,
            [HLSConverters stringFromBool:self.addedToContainerView],
            [self view]];
}

@end
