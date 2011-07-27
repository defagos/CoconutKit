//
//  HLSContainedViewControllerInfo.m
//  nut
//
//  Created by Samuel Défago on 27.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSContainedViewControllerInfo.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSContainedViewControllerInfo ()

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, assign, getter=isAddedAsSubview) BOOL addedAsSubview;
@property (nonatomic, retain) IBOutlet UIView *blockingView;
@property (nonatomic, assign) HLSTransitionStyle transitionStyle;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGRect originalViewFrame;
@property (nonatomic, assign) CGFloat originalViewAlpha;

@end

@implementation HLSContainedViewControllerInfo

#pragma mark Object creation and destruction

- (id)initWithViewController:(UIViewController *)viewController
             transitionStyle:(HLSTransitionStyle)transitionStyle
                    duration:(NSTimeInterval)duration
{
    if ((self = [super init])) {
        NSAssert(viewController != nil, @"View controller cannot be nil");

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
    // The cleanest we can do in such cases is to restore all 
    
    self.viewController = nil;
    self.blockingView = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize viewController = m_viewController;

@synthesize addedAsSubview = m_addedAsSubview;

@synthesize blockingView = m_blockingView;

@synthesize transitionStyle = m_transitionStyle;

@synthesize duration = m_duration;

@synthesize originalViewFrame = m_originalViewFrame;

@synthesize originalViewAlpha = m_originalViewAlpha;

- (UIView *)containedView
{
    if (! self.addedAsSubview) {
        HLSLoggerWarn(@"View not loaded");
        return nil;
    }
    else {
        return self.viewController.view;
    }
}

- (void)releaseContainedView
{
    self.viewController.view = nil;
}

#pragma mark View management

- (void)addContainedViewToContainerView:(UIView *)containerView 
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

- (void)removeContainedViewFromSuperview
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
