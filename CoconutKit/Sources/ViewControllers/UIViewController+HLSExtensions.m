//
//  UIViewController+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 21.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIViewController+HLSExtensions.h"

#import <objc/runtime.h>
#import "HLSAutorotationCompatibility.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UITextField+HLSExtensions.h"
#import "UITextView+HLSExtensions.h"

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
static void (*s_UIViewController__viewWillUnload_Imp)(id, SEL) = NULL;
static void (*s_UIViewController__viewDidUnload_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static id swizzled_UIViewController__initWithNibName_bundle_Imp(UIViewController *self, SEL _cmd, NSString *nibName, NSBundle *bundle);
static id swizzled_UIViewController__initWithCoder_Imp(UIViewController *self, SEL _cmd, NSCoder *aDecoder);
static void swizzled_UIViewController__viewDidLoad_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__viewWillAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidAppear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewWillDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewDidDisappear_Imp(UIViewController *self, SEL _cmd, BOOL animated);
static void swizzled_UIViewController__viewWillUnload_Imp(UIViewController *self, SEL _cmd);
static void swizzled_UIViewController__viewDidUnload_Imp(UIViewController *self, SEL _cmd);

@interface UIViewController (HLSExtensionsPrivate) <HLSAutorotationCompatibility>

- (void)uiViewControllerHLSExtensionsInit;

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
        BOOL isRunningIOS6 = (class_getInstanceMethod([UIViewController class], @selector(shouldAutorotate)) != NULL);
        
        if (! isRunningIOS6) {
            // The -viewWillUnload method is available starting with iOS 5 and deprecated starting with iOS 6, but was
            // in fact already privately implemented on iOS 4 (with empty implementation). Does not harm to call it here
            [self viewWillUnload];
        }
        self.view = nil;
        if (! isRunningIOS6) {
            [self viewDidUnload];
        }
    }
}

#pragma mark Accessors and mutators

- (HLSViewControllerLifeCyclePhase)lifeCyclePhase
{
    return [objc_getAssociatedObject(self, s_lifeCyclePhaseKey) intValue];
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
    HLSViewControllerLifeCyclePhase lifeCyclePhase = [self lifeCyclePhase];
    return HLSViewControllerLifeCyclePhaseViewWillAppear <= lifeCyclePhase
        && lifeCyclePhase < HLSViewControllerLifeCyclePhaseViewDidUnload;
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
            
        case HLSViewControllerLifeCyclePhaseViewWillUnload: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidLoad
                || currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewDidDisappear;
            break;
        }
            
        case HLSViewControllerLifeCyclePhaseViewDidUnload: {
            return currentLifeCyclePhase == HLSViewControllerLifeCyclePhaseViewWillUnload;
            break;
        }
            
        default: {
            HLSLoggerWarn(@"Invalid lifecycle phase, or testing for initialization");
            return NO;
            break;
        }
    }
}

- (BOOL)implementsNewAutorotationMethods
{
    return [self respondsToSelector:@selector(shouldAutorotate)]
        && [self respondsToSelector:@selector(supportedInterfaceOrientations)];
}

- (BOOL)shouldAutorotateForOrientations:(UIInterfaceOrientationMask)orientations
{
    if ([self implementsNewAutorotationMethods]) {
        return [self shouldAutorotate] && (orientations & [self supportedInterfaceOrientations]);
    }
    else {
        if (orientations & UIInterfaceOrientationMaskPortrait
                && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskLandscapeLeft
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskLandscapeRight
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return YES;
        }
        else if (orientations & UIInterfaceOrientationMaskPortraitUpsideDown
                 && [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)isOrientationCompatibleWithViewController:(UIViewController *)viewController
{
    if (! viewController) {
        return NO;
    }
    
    if ([viewController implementsNewAutorotationMethods]) {
        return [self shouldAutorotateForOrientations:[viewController supportedInterfaceOrientations]];
    }
    else {
        if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]
                && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return YES;
        }
        else if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]
                 && [viewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)autorotatesToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self implementsNewAutorotationMethods]) {
        return [self shouldAutorotate] && ([self supportedInterfaceOrientations] & (1 << interfaceOrientation));
    }
    else {
        return [self shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
}

- (UIInterfaceOrientation)compatibleOrientationWithOrientations:(UIInterfaceOrientationMask)orientations
{
    if (orientations & UIInterfaceOrientationMaskPortrait) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait))
                || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait]) {
            return UIInterfaceOrientationPortrait;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeRight) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeRight))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight]) {
            return UIInterfaceOrientationLandscapeRight;
        }
    }
    if (orientations & UIInterfaceOrientationMaskLandscapeLeft) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft]) {
            return UIInterfaceOrientationLandscapeLeft;
        }
    }
    if (orientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        if (([self implementsNewAutorotationMethods] && ([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortraitUpsideDown))
            || [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) {
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
    s_UIViewController__initWithNibName_bundle_Imp = (id (*)(id, SEL, id, id))HLSSwizzleSelector(self, 
                                                                                                 @selector(initWithNibName:bundle:), 
                                                                                                 (IMP)swizzled_UIViewController__initWithNibName_bundle_Imp);
    s_UIViewController__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, 
                                                                                    @selector(initWithCoder:), 
                                                                                    (IMP)swizzled_UIViewController__initWithCoder_Imp);
    s_UIViewController__viewDidLoad_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, 
                                                                                @selector(viewDidLoad), 
                                                                                (IMP)swizzled_UIViewController__viewDidLoad_Imp);
    s_UIViewController__viewWillAppear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, 
                                                                                         @selector(viewWillAppear:), 
                                                                                         (IMP)swizzled_UIViewController__viewWillAppear_Imp);
    s_UIViewController__viewDidAppear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, 
                                                                                        @selector(viewDidAppear:), 
                                                                                        (IMP)swizzled_UIViewController__viewDidAppear_Imp);
    s_UIViewController__viewWillDisappear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, 
                                                                                            @selector(viewWillDisappear:), 
                                                                                            (IMP)swizzled_UIViewController__viewWillDisappear_Imp);
    s_UIViewController__viewDidDisappear_Imp = (void (*)(id, SEL, BOOL))HLSSwizzleSelector(self, 
                                                                                           @selector(viewDidDisappear:),
                                                                                           (IMP)swizzled_UIViewController__viewDidDisappear_Imp);
    s_UIViewController__viewWillUnload_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                   @selector(viewWillUnload),
                                                                                   (IMP)swizzled_UIViewController__viewWillUnload_Imp);
    s_UIViewController__viewDidUnload_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self,
                                                                                  @selector(viewDidUnload),
                                                                                  (IMP)swizzled_UIViewController__viewDidUnload_Imp);
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

@end

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
    
    (*s_UIViewController__viewDidLoad_Imp)(self, _cmd);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidLoad]) {
        HLSLoggerWarn(@"The viewDidLoad method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidLoad] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setOriginalViewSize:self.view.bounds.size];
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
        UITextField *currentTextField = [UITextField currentTextField];
        if ([currentTextField isDescendantOfView:self.view]) {
            [currentTextField resignFirstResponder];                
        }
        
        UITextView *currentTextView = [UITextView currentTextView];
        if ([currentTextView isDescendantOfView:self.view]) {
            [currentTextView resignFirstResponder];                
        }
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

static void swizzled_UIViewController__viewWillUnload_Imp(UIViewController *self, SEL _cmd)
{
    (s_UIViewController__viewWillUnload_Imp)(self, _cmd);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillUnload]) {
        HLSLoggerWarn(@"The viewWillUnload method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewWillUnload] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewWillUnload];
}

static void swizzled_UIViewController__viewDidUnload_Imp(UIViewController *self, SEL _cmd)
{
    (s_UIViewController__viewDidUnload_Imp)(self, _cmd);
    
    if (! [self isReadyForLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidUnload]) {
        HLSLoggerWarn(@"The viewDidUnload method has been called on %@, but its current view lifecycle state is not compatible. "
                      "Maybe the view controller is displayed using a container object with incorrect view lifecycle management, "
                      "or maybe [super viewDidUnload] has not been called by class %@ or one of its parents", self, [self class]);
    }
    
    [self setLifeCyclePhase:HLSViewControllerLifeCyclePhaseViewDidUnload];
}
