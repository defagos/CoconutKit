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
static void *kContainerContentKey = &kContainerContentKey;

static id (*UIViewController__navigationController)(id, SEL) = NULL;
static id (*UIViewController__navigationItem)(id, SEL) = NULL;
static id (*UIViewController__interfaceOrientation)(id, SEL) = NULL;

static void (*UIViewController__setTitle)(id, SEL, id) = NULL;
static id swizzledGetter(UIViewController *self, SEL _cmd);
static id swizzledForwardGetter(UIViewController *self, SEL _cmd);
static void swizzledForwardSetter(UIViewController *self, SEL _cmd, id value);

@interface HLSContainerContent ()

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign) id containerController;           // weak ref
@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedToContainerView;
@property (nonatomic, retain) IBOutlet UIView *blockingView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView;

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration;

@end

static id swizzledGetter(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, kContainerContentKey);
    
    // We could not forward parentViewController (see why in the .h documentation), we must therefore swizzle
    // interfaceOrientation to fix its behaviour
    if (_cmd == @selector(interfaceOrientation)) {
        if (containerContent
                && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
            return UIViewController__interfaceOrientation(containerContent.containerController, _cmd);
        }
        else {
            return UIViewController__interfaceOrientation(self, _cmd);
        }
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property getter (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }    
}

static id swizzledForwardGetter(UIViewController *self, SEL _cmd)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, kContainerContentKey);
    
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
    
    // Forwarding only makes sense if the controller itself is a view controller; if not, call original implementation
    if (containerContent
            && containerContent.viewControllerContainerForwardingEnabled 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        return UIViewControllerMethod(containerContent.containerController, _cmd);
    }
    else {
        return UIViewControllerMethod(self, _cmd);
    }
}

static void swizzledForwardSetter(UIViewController *self, SEL _cmd, id value)
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(self, kContainerContentKey);
    
    void (*UIViewControllerMethod)(id, SEL, id) = NULL;
    if (_cmd == @selector(setTitle:)) {
        UIViewControllerMethod = UIViewController__setTitle;
    }
    else {
        NSString *reason = [NSString stringWithFormat:@"Unsupported property setter forwarding (%@)", NSStringFromSelector(_cmd)];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    // Forwarding only makes sense if the controller itself is a view controller; if not, call original implementation
    if (containerContent
            && containerContent.viewControllerContainerForwardingEnabled 
            && [containerContent.containerController isKindOfClass:[UIViewController class]]) {
        UIViewControllerMethod(containerContent.containerController, _cmd, value);
    }
    else {
        UIViewControllerMethod(self, _cmd, value);
    }
}

@implementation HLSContainerContent

#pragma mark Class methods

+ (void)load
{
    // Swizzle methods ASAP. Cannot be in +initialize since those methods might be called before an HLSContainerContent is actually created for the
    // first tiime
    UIViewController__navigationController = (id (*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationController), (IMP)swizzledForwardGetter, NULL);
    UIViewController__navigationItem = (id (*)(id, SEL))class_replaceMethod([UIViewController class], @selector(navigationItem), (IMP)swizzledForwardGetter, NULL);
    
    UIViewController__interfaceOrientation = (id (*)(id, SEL))class_replaceMethod([UIViewController class], @selector(interfaceOrientation), (IMP)swizzledGetter, NULL);
    
    UIViewController__setTitle = (void (*)(id, SEL, id))class_replaceMethod([UIViewController class], @selector(setTitle:), (IMP)swizzledForwardSetter, NULL);
}

+ (id)containerControllerKindOfClass:(Class)containerControllerClass forViewController:(UIViewController *)viewController;
{
    HLSContainerContent *containerContent = objc_getAssociatedObject(viewController, kContainerContentKey);
    if ([containerContent.containerController isKindOfClass:containerControllerClass]) {
        return containerContent.containerController;
    }
    else {
        return nil;
    }
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
        self.containerController = containerController;
                
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

- (id)initWithViewController:(UIViewController *)viewController
         containerController:(id)containerController
             transitionStyle:(HLSTransitionStyle)transitionStyle
{
    return [self initWithViewController:viewController 
                    containerController:containerController 
                        transitionStyle:transitionStyle 
                               duration:kAnimationTransitionDefaultDuration];
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
        
    // Remove the association of the view controller with its content container object
    NSAssert(objc_getAssociatedObject(self.viewController, kContainerContentKey), @"The view controller was not associated with a content container");
    objc_setAssociatedObject(self.viewController, kContainerContentKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
    self.viewController = nil;
    self.containerController = nil;
    self.blockingView = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize containerController = m_containerController;

@synthesize addedToContainerView = m_addedToContainerView;

@synthesize blockingView = m_blockingView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

- (void)setDuration:(NSTimeInterval)duration
{
    // Sanitize input
    if (doublelt(duration, 0.) && ! doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        HLSLoggerWarn(@"Duration must be non-negative or %f. Fixed to 0", kAnimationTransitionDefaultDuration);
        m_duration = 0.;
    }
    else {
        m_duration = duration;
    }
}

@synthesize viewControllerContainerForwardingEnabled = m_viewControllerContainerForwardingEnabled;

- (void)setViewControllerContainerForwardingEnabled:(BOOL)viewControllerContainerForwardingEnabled
{
    if (m_viewControllerContainerForwardingEnabled == viewControllerContainerForwardingEnabled) {
        return;
    }
    
    m_viewControllerContainerForwardingEnabled = viewControllerContainerForwardingEnabled;
    
    if (viewControllerContainerForwardingEnabled) {
        if ([self.containerController isKindOfClass:[UIViewController class]]) {
            UIViewController *containerViewController = (UIViewController *)self.containerController;
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

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

- (UIView *)view
{
    if (! self.addedToContainerView) {
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
       inContainerContentStack:(NSArray *)containerContentStack
{
    if (self.addedToContainerView) {
        HLSLoggerInfo(@"View controller's view already added as to a container view");
        return NO;
    }
    
    // If a non-empty stack has been provided, find insertion point
    HLSAssertObjectsInEnumerationAreKindOfClass(containerContentStack, HLSContainerContent);
    if ([containerContentStack count] != 0) {
        NSUInteger index = [containerContentStack indexOfObject:self];
        if (index == NSNotFound) {
            HLSLoggerError(@"Receiver not found in the container content stack");
            return NO;
        }
        
        // Last element? Add to top
        if (index == [containerContentStack count] - 1) {
            [containerView addSubview:self.viewController.view];
        }
        // Otherwise add below first content above for which a view is available (most probably the nearest neighbour above)
        else {
            BOOL added = NO;
            for (NSUInteger i = index + 1; i < [containerContentStack count]; ++i) {
                HLSContainerContent *aboveContainerContent = [containerContentStack objectAtIndex:i];
                if ([aboveContainerContent view]) {
                    NSAssert(self.containerController == aboveContainerContent.containerController,
                             @"Both container contents must be associated with the same container controller");
                    NSAssert([aboveContainerContent view].superview == containerView, 
                             @"Other container contents has not been added to the same container view");
                    
                    [containerView insertSubview:self.viewController.view belowSubview:aboveContainerContent.blockingView];
                    added = YES;
                    break;
                }                
            }
            
            if (! added) {
                HLSLoggerError(@"Could not insert the view; no view found above in the stack");
                return NO;
            }            
        }
    }
    // If no stack provided, simply add at the top
    else {
        [containerView addSubview:self.viewController.view];
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
    
    // The transitions of the contents above in the stack might move views below in the stack. To account for this
    // effect, we must replay them so that the view we have inserted is put at the proper location
    if ([containerContentStack count] != 0) {
        NSUInteger index = [containerContentStack indexOfObject:self];
        for (NSUInteger i = index + 1; i < [containerContentStack count]; ++i) {
            HLSContainerContent *aboveContainerContent = [containerContentStack objectAtIndex:i];
            HLSAnimation *animation = [HLSContainerContent animationWithTransitionStyle:aboveContainerContent.transitionStyle 
                                                              appearingContainerContent:nil 
                                                          disappearingContainerContents:[NSArray arrayWithObject:self]
                                                                          containerView:containerView 
                                                                               duration:0.];
            [animation playAnimated:NO];
        }
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
    
    if ([self.viewController isViewLoaded]) {
        self.viewController.view = nil;
        [self.viewController viewDidUnload];
    }
}

#pragma mark Animation

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                           disappearingContainerContents:(NSArray *)disappearingContainerContents
                                           containerView:(UIView *)containerView
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(disappearingContainerContents, HLSContainerContent);
    
    NSMutableArray *animationSteps = [NSMutableArray array];
    switch (transitionStyle) {
        case HLSTransitionStyleNone: {
            break;
        }
            
        case HLSTransitionStyleCoverFromBottom: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromTop: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleCoverFromRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }  
            
        case HLSTransitionStyleCoverFromTopRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCoverFromBottomLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }   
            
        case HLSTransitionStyleCoverFromBottomRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleFadeIn: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-appearingContainerContent.originalViewAlpha];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:appearingContainerContent.originalViewAlpha];
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStyleCrossDissolve: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-appearingContainerContent.originalViewAlpha];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:-disappearingContainerContent.originalViewAlpha];
                [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]];                 
            }
            HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStepUpdatingViewWithAlphaVariation:appearingContainerContent.originalViewAlpha];
            [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }
            
        case HLSTransitionStylePushFromBottom: {            
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                      deltaY:-CGRectGetHeight(containerView.frame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
            }
            HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStylePushFromTop: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:-CGRectGetHeight(containerView.frame)];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                      deltaY:CGRectGetHeight(containerView.frame)];
                [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
            }
            HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:0.f
                                                                                                                  deltaY:CGRectGetHeight(containerView.frame)];
            [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        }    
            
        case HLSTransitionStylePushFromLeft: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                      deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
            }
            HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStylePushFromRight: {
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            for (HLSContainerContent *disappearingContainerContent in disappearingContainerContents) {
                HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                      deltaY:0.f];
                [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[disappearingContainerContent view]]; 
            }
            HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStepTranslatingViewWithDeltaX:-CGRectGetWidth(containerView.frame)
                                                                                                                  deltaY:0.f];
            [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:[appearingContainerContent view]]; 
            animationStep2.duration = 0.4;
            [animationSteps addObject:animationStep2];
            break;
        } 
            
        case HLSTransitionStyleEmergeFromCenter: {
            CGAffineTransform shrinkTransform = CGAffineTransformMakeScale(0.01f, 0.01f);      // cannot use 0.f, otherwise infinite matrix elements
            
            HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
            viewAnimationStep11.transform = shrinkTransform;
            [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:[appearingContainerContent view]]; 
            animationStep1.duration = 0.;
            [animationSteps addObject:animationStep1];
            
            HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
            HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
            viewAnimationStep21.transform = CGAffineTransformInvert(shrinkTransform);
            [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:[appearingContainerContent view]]; 
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

+ (HLSAnimation *)animationWithTransitionStyle:(HLSTransitionStyle)transitionStyle
                     appearingContainerContent:(HLSContainerContent *)appearingContainerContent
                 disappearingContainerContents:(NSArray *)disappearingContainerContents
                                 containerView:(UIView *)containerView
                                      duration:(NSTimeInterval)duration
{
    HLSAnimation *animation = [HLSContainerContent animationWithTransitionStyle:transitionStyle 
                                                      appearingContainerContent:appearingContainerContent 
                                                  disappearingContainerContents:disappearingContainerContents 
                                                                  containerView:containerView];    
    if (doubleeq(duration, kAnimationTransitionDefaultDuration)) {
        return animation;
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


- (HLSAnimation *)animationWithContainerContentStack:(NSArray *)containerContentStack
                                       containerView:(UIView *)containerView
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(containerContentStack, HLSContainerContent);
    
    // Make the receiver appear. Locate it in the stack
    NSUInteger index = [containerContentStack indexOfObject:self];
    if (index == NSNotFound) {
        HLSLoggerError(@"Container content to animate must be part of the stack");
        return nil;
    }
    
    // Make all container contents below in the stack disappear
    NSArray *belowContainerContents = [containerContentStack subarrayWithRange:NSMakeRange(0, index)];
    
    return [HLSContainerContent animationWithTransitionStyle:self.transitionStyle
                                   appearingContainerContent:self 
                               disappearingContainerContents:belowContainerContents
                                               containerView:containerView 
                                                    duration:self.duration];
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
