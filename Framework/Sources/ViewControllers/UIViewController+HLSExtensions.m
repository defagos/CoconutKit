//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIViewController+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UITextField+HLSExtensions.h"
#import "UITextView+HLSExtensions.h"

// Associated object keys
static void *s_lifeCyclePhaseKey = &s_lifeCyclePhaseKey;
static void *s_createdViewSizeKey = &s_createdViewSizeKey;

// Original implementation of the methods we swizzle
static id (*s_initWithNibName_bundle)(id, SEL, id, id) = NULL;
static id (*s_initWithCoder)(id, SEL, id) = NULL;
static void (*s_viewDidLoad)(id, SEL) = NULL;
static void (*s_viewWillAppear)(id, SEL, BOOL) = NULL;
static void (*s_viewDidAppear)(id, SEL, BOOL) = NULL;
static void (*s_viewWillDisappear)(id, SEL, BOOL) = NULL;
static void (*s_viewDidDisappear)(id, SEL, BOOL) = NULL;

// Swizzled method implementations
static id swizzle_initWithNibName_bundle(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle);
static id swizzle_initWithCoder(UIViewController *self, SEL _cmd, NSCoder *aDecoder);
static void swizzle_viewDidLoad(UIViewController *self, SEL _cmd);
static void swizzle_viewWillAppear(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzle_viewDidAppear(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzle_viewWillDisappear(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzle_viewDidDisappear(UIViewController *self, SEL _cmd, BOOL animated);

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
    HLSViewControllerLifeCyclePhase lifeCyclePhase = self.lifeCyclePhase;
    return HLSViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase 
        && lifeCyclePhase <= HLSViewControllerLifeCyclePhaseViewWillDisappear;
}

- (BOOL)isViewDisplayed
{
    return self.lifeCyclePhase >= HLSViewControllerLifeCyclePhaseViewWillAppear;
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
    HLSViewControllerLifeCyclePhase currentLifeCyclePhase = self.lifeCyclePhase;
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

@end

@implementation UIViewController (HLSExtensionsPrivate)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(initWithNibName:bundle:), swizzle_initWithNibName_bundle, &s_initWithNibName_bundle);
    HLSSwizzleSelector(self, @selector(initWithCoder:), swizzle_initWithCoder, &s_initWithCoder);
    HLSSwizzleSelector(self, @selector(viewDidLoad), swizzle_viewDidLoad, &s_viewDidLoad);
    HLSSwizzleSelector(self, @selector(viewWillAppear:), swizzle_viewWillAppear, &s_viewWillAppear);
    HLSSwizzleSelector(self, @selector(viewDidAppear:), swizzle_viewDidAppear, &s_viewDidAppear);
    HLSSwizzleSelector(self, @selector(viewWillDisappear:), swizzle_viewWillDisappear, &s_viewWillDisappear);
    HLSSwizzleSelector(self, @selector(viewDidDisappear:), swizzle_viewDidDisappear, &s_viewDidDisappear);
}

#pragma mark Object creation and destruction

- (void)uiViewControllerHLSExtensionsInit
{
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseInitialized];
}

#pragma mark Accessors and mutators

- (void)setLifeCyclePhase:(HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    hls_setAssociatedObject(self, s_lifeCyclePhaseKey, @(lifeCyclePhase), HLS_ASSOCIATION_STRONG_NONATOMIC);
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

static id swizzle_initWithNibName_bundle(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle)
{
    if ((self = s_initWithNibName_bundle(self, _cmd, nibName, bundle))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;
}

static id swizzle_initWithCoder(UIViewController *self, SEL _cmd, NSCoder *aDecoder)
{
    if ((self = s_initWithCoder(self, _cmd, aDecoder))) {
        [self uiViewControllerHLSExtensionsInit];
    }
    return self;
}

static void swizzle_viewDidLoad(UIViewController *self, SEL _cmd)
{
    if (! [self isViewLoaded]) {
        HLSLoggerError(@"The view controller's view has not been loaded, but -viewDidLoad is being called. Something "
                       "must be terribly wrong with this view controller");
    }
    
    // Remote view controllers have weird behavior and can have -viewDidLoad being called while the view is nil.
    // Use -viewIfLoaded to prevent infinite recursion
    hls_setAssociatedObject(self, s_createdViewSizeKey, [NSValue valueWithCGSize:self.viewIfLoaded.bounds.size], HLS_ASSOCIATION_STRONG_NONATOMIC);
    
    s_viewDidLoad(self, _cmd);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad]) {
        HLSLoggerWarn(@"The viewDidLoad method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidLoad] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad];
}

static void swizzle_viewWillAppear(UIViewController *self, SEL _cmd, BOOL animated)
{
    s_viewWillAppear(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear]) {
        HLSLoggerWarn(@"The viewWillAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewWillAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillAppear];
}

static void swizzle_viewDidAppear(UIViewController *self, SEL _cmd, BOOL animated)
{
    s_viewDidAppear(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear]) {
        HLSLoggerWarn(@"The viewDidAppear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidAppear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidAppear];    
}

static void swizzle_viewWillDisappear(UIViewController *self, SEL _cmd, BOOL animated)
{
    s_viewWillDisappear(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear]) {
        HLSLoggerWarn(@"The viewWillDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewWillDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillDisappear];
}

static void swizzle_viewDidDisappear(UIViewController *self, SEL _cmd, BOOL animated)
{
    s_viewDidDisappear(self, _cmd, animated);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear]) {
        HLSLoggerWarn(@"The viewDidDisappear: method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidDisappear:] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidDisappear];
}
