//
//  UIViewController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 21.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIViewController+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSCategoryLinker.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UITextField+HLSExtensions.h"

HLSLinkCategory(UIViewController_HLSExtensions)

// Associated object keys
static void *s_lifeCyclePhaseKey = &s_lifeCyclePhaseKey;
static void *s_originalViewSizeKey = &s_originalViewSizeKey;

// Original implementation of the methods we swizzle
static id (*s_UIViewController__initWithNibName_bundle_Imp)(id, SEL, id, id) = NULL;
static id (*s_UIViewController__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UIViewController__viewDidLoad_Imp)(id, SEL) = NULL;
static void (*s_UIViewController__viewWillAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewWillDisappear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidDisappear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidUnload_Imp)(id, SEL) = NULL;

@interface UIViewController (HLSExtensionsPrivate)

- (void)uiViewControllerHLSExtensionsInit;

- (id)swizzledInitWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;
- (id)swizzledInitWithCoder:(NSCoder *)aDecoder;
- (void)swizzledViewDidLoad;
- (void)swizzledViewWillAppear:(BOOL)animated;
- (void)swizzledViewDidAppear:(BOOL)animated;
- (void)swizzledViewWillDisappear:(BOOL)animated;
- (void)swizzledViewDidDisappear:(BOOL)animated;
- (void)swizzledViewDidUnload;

- (void)setLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase;
- (void)setOriginalViewSize:(CGSize)originalViewSize;

@end

@implementation UIViewController (HLSExtensions)

#pragma mark View management

/**
 * Remark: We have NOT overridden the view property to perform the viewDidUnload, and on purpose. This would have been
 *         very convenient, but this would have been unusual and in most cases the viewDidUnload would have
 *         been sent twice (when a container controller nils a view it manages, it is likely it will set the view
 *         to nil and send it the viewDidUnload afterwards. If all view controller containers of the world knew
 *         about HLSViewController, this would work, but since they don't this would lead to viewDidUnload be
 *         called twice in most cases)! 
 */
- (void)unloadViews
{
    if ([self isViewLoaded]) {
        self.view = nil;
        [self viewDidUnload];        
    }
}

#pragma mark Accessors and mutators

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return [objc_getAssociatedObject(self, s_lifeCyclePhaseKey) intValue];
}

- (BOOL)isViewVisible
{
    HLSViewControllerLifeCyclePhase lifeCyclePhase = [self lifeCyclePhase];
    return HLSViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase 
    && lifeCyclePhase <= HLSViewControllerLifeCyclePhaseViewWillDisappear;
}

- (CGSize)originalViewSize
{
    if ([self lifeCyclePhase] < HLSViewControllerLifeCyclePhaseViewDidLoad) {
        HLSLoggerError(@"The view has not been created. Size is unknown yet");
        return CGSizeZero;
    }
    
    return [objc_getAssociatedObject(self, s_originalViewSizeKey) CGSizeValue];
}

- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    HLSViewControllerLifeCyclePhase currentLifeCyclePhase = [self lifeCyclePhase];
    switch (lifeCyclePhase) {
        case HLSViewControllerLifeCyclePhaseViewDidLoad: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseInitialized
                || currentLifeCyclePhase  == HLSViewControllerLifeCyclePhaseViewDidUnload;
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewWillAppear: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidLoad
                || currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidDisappear;
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewDidAppear: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewWillAppear;
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewWillDisappear: {
            // Having a view controller transition from ViewWillAppear to ViewWillDisappear directly is quite rare (in
            // general we expect it to transition to ViewDidAppear first), but this can still happen if two container 
            // animations are played simultaneously (i.e. if two containers are nested). If the first container is
            // revealing the view controller while this view controller is being replaced in the second, and depending
            // on the timing of the animations, the view controller might have disappeared before it actually appeared
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidAppear        // <-- usual case
                || currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewWillAppear;      // <-- rare (see above)
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewDidDisappear: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewWillDisappear;
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewDidUnload: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidLoad
                || currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidDisappear;
            break;
        }
            
        default: {
            HLSLoggerWarn(@"Invalid lifecycle phase, or testing for initialization");
            return NO;
            break;
        }
    }
}

@end

@implementation UIViewController (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIViewController__initWithNibName_bundle_Imp = (id (*)(id, SEL, id, id))HLSSwizzleSelector(self, 
                                                                                                 @selector(initWithNibName:bundle:), 
                                                                                                 @selector(swizzledInitWithNibName:bundle:));
    s_UIViewController__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                    @selector(initWithCoder:), 
                                                                                    @selector(swizzledInitWithCoder:));
    s_UIViewController__viewDidLoad_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(viewDidLoad), @selector(swizzledViewDidLoad));
    s_UIViewController__viewWillAppear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, @selector(viewWillAppear:), @selector(swizzledViewWillAppear:));
    s_UIViewController__viewDidAppear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, @selector(viewDidAppear:), @selector(swizzledViewDidAppear:));
    s_UIViewController__viewWillDisappear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, @selector(viewWillDisappear:), @selector(swizzledViewWillDisappear:));
    s_UIViewController__viewDidDisappear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, @selector(viewDidDisappear:), @selector(swizzledViewDidDisappear:));
    s_UIViewController__viewDidUnload_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(viewDidUnload), @selector(swizzledViewDidUnload));
}

#pragma mark Object creation and destruction

- (void)uiViewControllerHLSExtensionsInit
{
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseInitialized];
    [self setOriginalViewSize:CGSizeZero];
}

#pragma mark Accessors and mutators

- (void)setLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    objc_setAssociatedObject(self, s_lifeCyclePhaseKey, [NSNumber numberWithInt:lifeCyclePhase], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setOriginalViewSize:(CGSize)originalViewSize
{
    objc_setAssociatedObject(self, s_originalViewSizeKey, [NSValue valueWithCGSize:originalViewSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Swizzled methods

- (id)swizzledInitWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self = (*s_UIViewController__initWithNibName_bundle_Imp)(self, @selector(initWithNibName:bundle:), nibName, bundle))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;    
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    if ((self = (*s_UIViewController__initWithCoder_Imp)(self, @selector(initWithCoder:), aDecoder))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;
}

- (void)swizzledViewDidLoad
{
    (*s_UIViewController__viewDidLoad_Imp)(self, @selector(viewDidLoad));
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad]) {
        HLSLoggerDebug(@"The viewDidLoad method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewDidLoad] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setOriginalViewSize:self.view.bounds.size];
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad];
}

- (void)swizzledViewWillAppear:(BOOL)animated
{
    (*s_UIViewController__viewWillAppear_Imp)(self, @selector(viewWillAppear:), animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        HLSLoggerDebug(@"The viewWillAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewWillAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear];
}

- (void)swizzledViewDidAppear:(BOOL)animated
{
    (*s_UIViewController__viewDidAppear_Imp)(self, @selector(viewDidAppear:), animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        HLSLoggerDebug(@"The viewDidAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewDidAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear];
}

- (void)swizzledViewWillDisappear:(BOOL)animated
{
    (*s_UIViewController__viewWillDisappear_Imp)(self, @selector(viewWillDisappear:), animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        HLSLoggerDebug(@"The viewWillDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewWillDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear];
    [[UITextField currentTextField] resignFirstResponder];
}

- (void)swizzledViewDidDisappear:(BOOL)animated
{
    (*s_UIViewController__viewDidDisappear_Imp)(self, @selector(viewDidDisappear:), animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        HLSLoggerDebug(@"The viewDidDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewDidDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear];
}

- (void)swizzledViewDidUnload
{
    (s_UIViewController__viewDidUnload_Imp)(self, @selector(viewDidUnload));
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidUnload]) {
        HLSLoggerDebug(@"The viewDidUnload method has been called on %@, but its current view lifecycle state is not compatible. "
                       "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                       "or maybe [super viewDidUnload] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidUnload];
}

@end
