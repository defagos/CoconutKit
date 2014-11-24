//
//  UIViewController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 21.02.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UIViewController+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UITextField+HLSExtensions.h"
#import "UITextView+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

// TODO: When CoconutKit requires iOS >= 8, completely update rotation code. Yeah, this is going to be a lot of work...

// Associated object keys
static void *s_lifeCyclePhaseKey = &s_lifeCyclePhaseKey;
static void *s_createdViewSizeKey = &s_createdViewSizeKey;

// Original implementation of the methods we swizzle
static id (*s_UIViewController__initWithNibName_bundle_Imp)(id, SEL, id, id) = NULL;
static id (*s_UIViewController__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UIViewController__viewDidLoad_Imp)(id, SEL) = NULL;
static void (*s_UIViewController__viewWillAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidAppear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewWillDisappear_Imp)(id, SEL, BOOL) = NULL;
static void (*s_UIViewController__viewDidDisappear_Imp)(id, SEL, BOOL) = NULL;

// Swizzled method implementations
static id swizzled_UIViewController__initWithNibName_bundle_Imp(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle);
static id swizzled_UIViewController__initWithCoder_Imp(UIViewController *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__viewWillAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewWillDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);

@implementation UIViewController (HLSExtensions)

#pragma mark Accessors and mutators

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return [hls_getAssociatedObject(self, s_lifeCyclePhaseKey) intValue];
}

- (UIView *)viewIfLoaded
{
    return [self isViewLoaded] ? self.view : nil;
}

- (BOOL)isViewVisible
{
    HLSViewControllerLifeCyclePhase lifeCyclePhase = [self lifeCyclePhase];
    return HLSViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase 
        && lifeCyclePhase <= HLSViewControllerLifeCyclePhaseViewWillDisappear;
}

- (BOOL)isViewDisplayed
{
    return [self lifeCyclePhase] >= HLSViewControllerLifeCyclePhaseViewWillAppear;
}

- (CGSize)createdViewSize
{
    NSValue *createdViewSizeValue = hls_getAssociatedObject(self, s_createdViewSizeKey);
    if (createdViewSizeValue) {
        return [createdViewSizeValue CGSizeValue];
    }
    else {
        // Return zero to avoid triggering lazy view creation
        HLSLoggerWarn(@"The view has not been created (incorrect view lifecycle). Return zero");
        return CGSizeZero;
    }
}

- (BOOL)isReadyForLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    HLSViewControllerLifeCyclePhase currentLifeCyclePhase = [self lifeCyclePhase];
    switch (lifeCyclePhase) {
        case HLSViewControllerLifeCyclePhaseViewDidLoad: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseInitialized;
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
            
        default: {
            HLSLoggerWarn(@"Invalid lifecycle phase, or testing for initialization");
            return NO;
            break;
        }
    }
}

- (BOOL)shouldAutorotateForOrientations:(UIInterfaceOrientationMask)orientations
{
    return [self shouldAutorotate] && (orientations & [self supportedInterfaceOrientations]);
}

- (BOOL)isOrientationCompatibleWithViewController:(UIViewController *)viewController
{
    if (! viewController) {
        return NO;
    }
    
    return [self shouldAutorotateForOrientations:[viewController supportedInterfaceOrientations]];
}

- (BOOL)autorotatesToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self shouldAutorotate] && ([self supportedInterfaceOrientations] & (1 << interfaceOrientation));
}

- (UIInterfaceOrientation)compatibleOrientationWithOrientations:(UIInterfaceOrientationMask)orientations
{
    if (orientations & UIInterfaceOrientationMaskPortrait) {
        if ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait) {
            return UIInterfaceOrientationPortrait;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeRight) {
        if ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeRight) {
            return UIInterfaceOrientationLandscapeRight;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeLeft) {
        if ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft) {
            return UIInterfaceOrientationLandscapeLeft;
        }
    }
    if (orientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        if ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortraitUpsideDown) {
            return UIInterfaceOrientationPortraitUpsideDown;
        }
    }
    return 0;
}

- (UIInterfaceOrientation)compatibleOrientationWithViewController:(UIViewController *)viewController
{
    if (! viewController) {
        return 0;
    }
    
    return [self compatibleOrientationWithOrientations:[viewController supportedInterfaceOrientations]];
}

@end

@implementation UIViewController (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UIViewController__initWithNibName_bundle_Imp = (id (*)(id, SEL, id, id))hls_class_swizzleSelector(self,
                                                                                                        @selector(initWithNibName:bundle:),
                                                                                                        (IMP)swizzled_UIViewController__initWithNibName_bundle_Imp);
    s_UIViewController__initWithCoder_Imp = (id (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                           @selector(initWithCoder:),
                                                                                           (IMP)swizzled_UIViewController__initWithCoder_Imp);
    s_UIViewController__viewDidLoad_Imp = (void (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                                       @selector(viewDidLoad),
                                                                                       (IMP)swizzled_UIViewController__viewDidLoad_Imp);
    s_UIViewController__viewWillAppear_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzleSelector(self,
                                                                                                @selector(viewWillAppear:),
                                                                                                (IMP)swizzled_UIViewController__viewWillAppear_Imp);
    s_UIViewController__viewDidAppear_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzleSelector(self,
                                                                                               @selector(viewDidAppear:),
                                                                                               (IMP)swizzled_UIViewController__viewDidAppear_Imp);
    s_UIViewController__viewWillDisappear_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzleSelector(self,
                                                                                                   @selector(viewWillDisappear:),
                                                                                                   (IMP)swizzled_UIViewController__viewWillDisappear_Imp);
    s_UIViewController__viewDidDisappear_Imp = (void (*)(id, SEL, BOOL))hls_class_swizzleSelector(self,
                                                                                                  @selector(viewDidDisappear:),
                                                                                                  (IMP)swizzled_UIViewController__viewDidDisappear_Imp);
}

#pragma mark Object creation and destruction

- (void)uiViewControllerHLSExtensionsInit
{
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseInitialized];
}

#pragma mark Accessors and mutators

- (void)setLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    hls_setAssociatedObject(self, s_lifeCyclePhaseKey, [NSNumber numberWithInt:lifeCyclePhase], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#ifdef DEBUG

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIViewController (HLSDebugging)

@end

#pragma clang diagnostic pop

#endif

#pragma mark Swizzled method implementations

static id swizzled_UIViewController__initWithNibName_bundle_Imp(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle)
{
    if ((self = (*s_UIViewController__initWithNibName_bundle_Imp)(self, _cmd, nibName, bundle))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;
}

static id swizzled_UIViewController__initWithCoder_Imp(UIViewController *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = (*s_UIViewController__initWithCoder_Imp)(self, _cmd, aDecoder))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;
}

static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd)
{
    if (! [self isViewLoaded]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException 
                                       reason:@"The view controller's view has not been loaded" 
                                     userInfo:nil];
    }
    
    hls_setAssociatedObject(self, s_createdViewSizeKey, [NSValue valueWithCGSize:self.view.bounds.size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    (*s_UIViewController__viewDidLoad_Imp)(self, _cmd);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad]) {
        HLSLoggerWarn(@"The viewDidLoad method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidLoad] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad];
}

static void swizzled_UIViewController__viewWillAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewWillAppear_Imp)(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        HLSLoggerWarn(@"The viewWillAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewWillAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear];
}

static void swizzled_UIViewController__viewDidAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewDidAppear_Imp)(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        HLSLoggerWarn(@"The viewDidAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear];    
}

static void swizzled_UIViewController__viewWillDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewWillDisappear_Imp)(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        HLSLoggerWarn(@"The viewWillDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewWillDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear];
    
    // Automatic keyboard dismissal when the view disappears. We test that the view has been loaded to account for the possibility 
    // that the view lifecycle has been incorrectly implemented
    if ([self isViewLoaded]) {
        UIView *firstResponderView = [self.view firstResponderView];
        [firstResponderView resignFirstResponder];
    }
}

static void swizzled_UIViewController__viewDidDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated)
{
    (*s_UIViewController__viewDidDisappear_Imp)(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        HLSLoggerWarn(@"The viewDidDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear];
}
