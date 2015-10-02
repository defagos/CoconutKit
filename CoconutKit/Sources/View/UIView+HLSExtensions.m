//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIView+HLSExtensions.h"

#import "CALayer+HLSExtensions.h"
#import "HLSAnyGestureRecognizer.h"
#import "HLSKeyboardInformation.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "UIScrollView+HLSExtensions.h"

// Keys for associated objects
static void *s_tagKey = &s_tagKey;
static void *s_userInfoKey = &s_userInfoKey;
static void *s_modalOutsideActionBlockKey = &s_modalOutsideActionBlockKey;
static void *s_outsideGestureRecognizerKey = &s_outsideGestureRecognizerKey;

// Original implementation of the methods we swizzle
static BOOL (*s_UIView_becomeFirstResponder)(id, SEL) = NULL;
static void (*s_UIView_didMoveToWindow)(id, SEL) = NULL;

// Swizzled method implementations
static BOOL swizzle_becomeFirstResponder(UIView *self, SEL _cmd);
static void swizzle_didMoveToWindow(UIView *self, SEL _cmd);

@interface UIView (HLSExtensionsPrivate)

@property (nonatomic, copy) void (^modalOutsideActionBlock)(void);
@property (nonatomic, strong) HLSAnyGestureRecognizer *outsideGestureRecognizer;        // strong to keep setup if later installed

@end

@implementation UIView (HLSExtensions)

#pragma mark Class methods

+ (void)load
{
    HLSSwizzleSelector(self, @selector(becomeFirstResponder), swizzle_becomeFirstResponder, &s_UIView_becomeFirstResponder);
    HLSSwizzleSelector(self, @selector(didMoveToWindow), swizzle_didMoveToWindow, &s_UIView_didMoveToWindow);
}

#pragma mark Accessors and mutators

- (UIViewController *)viewController
{
    if ([self.nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self.nextResponder;
    }
    else {
        return nil;
    }
}

- (UIViewController *)nearestViewController
{
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

- (NSString *)tag_hls
{
    return hls_getAssociatedObject(self, s_tagKey);
}

- (void)setTag_hls:(NSString *)tag_hls
{
    hls_setAssociatedObject(self, s_tagKey, tag_hls, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

- (NSDictionary *)userInfo_hls
{
    return hls_getAssociatedObject(self, s_userInfoKey);
}

- (void)setUserInfo_hls:(NSDictionary *)userInfo_hls
{
    hls_setAssociatedObject(self, s_userInfoKey, userInfo_hls, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

- (UIImage *)flattenedImage
{
    return [self.layer flattenedImage];
}

- (UIView *)firstResponderView
{
    if ([self isFirstResponder]) {
        return self;
    }
    
    for (UIView *subview in self.subviews) {
        UIView *firstResponderSubview = [subview firstResponderView];
        if (firstResponderSubview) {
            return firstResponderSubview;
        }
    }
    
    return nil;
}

- (BOOL)hasOutsideAction
{
    return self.outsideGestureRecognizer != nil;
}

- (void (^)(void))modalOutsideActionBlock
{
    return objc_getAssociatedObject(self, s_modalOutsideActionBlockKey);
}

- (void)setModalOutsideActionBlock:(void (^)(void))modalOutsideActionBlock
{
    objc_setAssociatedObject(self, s_modalOutsideActionBlockKey, modalOutsideActionBlock, OBJC_ASSOCIATION_COPY);
}

- (HLSAnyGestureRecognizer *)outsideGestureRecognizer
{
    return objc_getAssociatedObject(self, s_outsideGestureRecognizerKey);
}

- (void)setOutsideGestureRecognizer:(HLSAnyGestureRecognizer *)outsideGestureRecognizer
{
    objc_setAssociatedObject(self, s_outsideGestureRecognizerKey, outsideGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark Modal behavior

- (void)enableOutsideActionWithBlock:(void (^)())outsideActionBlock
{
    NSParameterAssert(outsideActionBlock);
    
    if ([self hasOutsideAction]) {
        HLSLoggerWarn(@"The view already has an outside action");
        return;
    }
    
    self.outsideGestureRecognizer = [[HLSAnyGestureRecognizer alloc] initWithTarget:self action:@selector(outsideAction:)];
    self.modalOutsideActionBlock = outsideActionBlock;
    
    if (self.window) {
        [self.window addGestureRecognizer:self.outsideGestureRecognizer];
    }
}

- (void)disableOutsideAction
{
    if (! [self hasOutsideAction]) {
        HLSLoggerWarn(@"The view does not have any outside action");
        return;
    }
    
    [self.outsideGestureRecognizer.view removeGestureRecognizer:self.outsideGestureRecognizer];
    self.outsideGestureRecognizer = nil;
    
    self.modalOutsideActionBlock = nil;
}

#pragma mark View fading

- (void)fadeLeft:(CGFloat)left right:(CGFloat)right
{
    if (isless(left, 0.f) || isless(right, 0.f) || isgreater(left + right, 1.f)) {
        HLSLoggerWarn(@"Invalid values for fading parameters. Must be >= 0 and must not add up to a value larger than 1");
        return;
    }
    
    CAGradientLayer *gradientLayer = [self gradientMaskLayer];
    gradientLayer.locations = @[@(0.f), @(left), @(1.f - right), @(1.f)];
    gradientLayer.startPoint = CGPointMake(0.f, 0.f);
    gradientLayer.endPoint = CGPointMake(1.f, 0.f);
    self.layer.mask = gradientLayer;
}

- (void)fadeTop:(CGFloat)top bottom:(CGFloat)bottom
{
    if (isless(top, 0.f) || isless(bottom, 0.f) || isgreater(top + bottom, 1.f)) {
        HLSLoggerWarn(@"Invalid values for fading parameters. Must be >= 0 and must not add up to a value larger than 1");
        return;
    }
    
    CAGradientLayer *gradientLayer = [self gradientMaskLayer];
    gradientLayer.locations = @[@(0.f), @(top), @(1.f - bottom), @(1.f)];
    gradientLayer.startPoint = CGPointMake(0.f, 0.f);
    gradientLayer.endPoint = CGPointMake(0.f, 1.f);
    self.layer.mask = gradientLayer;
}

- (CAGradientLayer *)gradientMaskLayer
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    UIColor *outerColor = [UIColor colorWithWhite:1.f alpha:0.f];
    UIColor *innerColor = [UIColor colorWithWhite:1.f alpha:1.f];
    
    maskLayer.colors = @[(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor];
    
    maskLayer.bounds = self.bounds;
    maskLayer.anchorPoint = CGPointZero;
    
    // FIXME: Bug: Must resize with the parent layer
    
    return maskLayer;
}

#pragma mark Actions

- (void)outsideAction:(UIGestureRecognizer *)gestureRecognizer
{
    NSAssert(self.modalOutsideActionBlock, @"An action block is mandatory");
    
    // Check the gesture happens outside the receiver
    CGPoint point = [gestureRecognizer locationInView:nil];
    CGRect frameInWindow = [self convertRect:self.bounds toCoordinateSpace:self.window];
    if (! CGRectContainsPoint(frameInWindow, point)) {
        self.modalOutsideActionBlock();
    }
}

@end

#pragma mark Swizzled method implementations

static BOOL swizzle_becomeFirstResponder(UIView *self, SEL _cmd)
{
    // Scroll any scroll view avoiding the keyboard when the focus changes. This is implemented for free by UIKit for UITextField,
    // but not for UITextView, for example
    if (! [self isKindOfClass:[UITextField class]]) {
        // The keyboard is visible (and thus keyboard information is available) only -becomeFirstResponder original implementation
        // has been called. If a keyboard is available before, this means we are setting the focus on another responder while
        // the keyboard was already visible. In such cases, find the topmost scroll view which is set to avoid the keyboard,
        // and ensure the responder view is visible
        if ([HLSKeyboardInformation keyboardInformation]) {
            UIScrollView *topmostAvoidingKeyboardScrollView = nil;
            UIView *view = self;
            while (view) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)view;
                    if (scrollView.avoidingKeyboard) {
                        topmostAvoidingKeyboardScrollView = scrollView;
                    }
                }
                view = view.superview;
            }
            
            if (topmostAvoidingKeyboardScrollView) {
                CGRect frameInTopmostAvoidingKeyboardScrollView = [topmostAvoidingKeyboardScrollView convertRect:self.bounds fromView:self];
                [topmostAvoidingKeyboardScrollView scrollRectToVisible:frameInTopmostAvoidingKeyboardScrollView animated:YES];
            }
        }
    }
    
    return s_UIView_becomeFirstResponder(self, _cmd);
}

static void swizzle_didMoveToWindow(UIView *self, SEL _cmd)
{
    s_UIView_didMoveToWindow(self, _cmd);
    
    if (self.window && self.outsideGestureRecognizer && ! self.outsideGestureRecognizer.view) {
        [self.window addGestureRecognizer:self.outsideGestureRecognizer];
    }
}

#ifdef DEBUG

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIView (HLSDebugging)

@end

#pragma clang diagnostic pop

#endif
