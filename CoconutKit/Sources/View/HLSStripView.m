//
//  HLSStripView.m
//  CoconutKit
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripView.h"

#import "HLSAnimation.h"
#import "HLSAssert.h"
#import "HLSLogger.h"

const CGFloat kStripViewHandleWidth = 22.f;
const CGFloat kStripViewHandleHeight = 22.f;

@interface HLSStripView () <HLSAnimationDelegate>

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *leftHandleView;
@property (nonatomic, retain) UIView *rightHandleView;
@property (nonatomic, retain) UILabel *leftLabel;
@property (nonatomic, retain) UILabel *rightLabel;
@property (nonatomic, retain) HLSAnimation *editModeAnimation;

@end

// TODO: Text at both ends. Adjust size, apply fast fade out effect when text are brought near enough so that no
//       overlap occurs

@implementation HLSStripView

#pragma mark Object creation and destruction

- (id)initWithStrip:(HLSStrip *)strip contentView:(UIView *)contentView
{
    // CGRectZero. Dimensions will be set in layoutSubviews
    if ((self = [super initWithFrame:CGRectZero])) {
        self.strip = strip;
        
        self.contentView = contentView;
        [self addSubview:contentView];
        
        self.contentFrameInParent = CGRectZero;
        
        self.backgroundColor = [UIColor clearColor];
        
        // Add labels at strip ends. When the strip is large enough, this makes it possible to display
        // some text (e.g. the values at the end)
        // TODO
#if 0
        self.leftLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.leftLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.leftLabel];
        self.rightLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.rightLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.rightLabel];
#endif
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.strip = nil;
    self.contentView = nil;
    self.leftHandleView = nil;
    self.rightHandleView = nil;
    self.leftLabel = nil;
    self.rightLabel = nil;
    self.editModeAnimation = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize strip = m_strip;

@synthesize contentView = m_contentView;

@synthesize contentFrameInParent = m_contentFrameInParent;

- (void)setContentFrameInParent:(CGRect)contentFrameInParent
{
    m_contentFrameInParent = contentFrameInParent;
    [self setNeedsLayout];
}

- (CGRect)leftHandleFrameInParent
{
    return CGRectMake(self.contentFrameInParent.origin.x - kStripViewHandleWidth,
                      self.contentFrameInParent.origin.y,
                      kStripViewHandleWidth,
                      self.contentFrameInParent.size.height);
}

- (CGRect)rightHandleFrameInParent
{
    return CGRectMake(self.contentFrameInParent.origin.x + self.contentFrameInParent.size.width,
                      self.contentFrameInParent.origin.y,
                      kStripViewHandleWidth,
                      self.contentFrameInParent.size.height);
}

@synthesize leftHandleView = m_leftHandleView;

@synthesize rightHandleView = m_rightHandleView;

@synthesize leftLabel = m_leftLabel;

@synthesize rightLabel = m_rightLabel;

@synthesize edited = m_edited;

@synthesize editModeAnimation = m_editModeAnimation;

@synthesize delegate = m_delegate;

#pragma mark Layout

- (void)layoutSubviews
{
    if (self.edited) {
        self.frame = CGRectMake(self.contentFrameInParent.origin.x - kStripViewHandleWidth,
                                self.contentFrameInParent.origin.y, 
                                self.contentFrameInParent.size.width + 2 * kStripViewHandleWidth,
                                self.contentFrameInParent.size.height);
        self.leftHandleView.frame = CGRectMake(0.f, 
                                               (self.contentFrameInParent.size.height - kStripViewHandleHeight) / 2.f , 
                                               kStripViewHandleWidth, 
                                               kStripViewHandleHeight);
        self.rightHandleView.frame = CGRectMake(kStripViewHandleWidth + self.contentFrameInParent.size.width, 
                                                (self.contentFrameInParent.size.height - kStripViewHandleHeight) / 2.f , 
                                                kStripViewHandleWidth, 
                                                kStripViewHandleHeight);
        self.contentView.frame = CGRectMake(kStripViewHandleWidth,
                                            0.f,
                                            self.contentFrameInParent.size.width,
                                            self.contentFrameInParent.size.height);
    }
    else {
        self.frame = self.contentFrameInParent;
        self.contentView.frame = CGRectMake(0.f, 
                                            0.f, 
                                            self.contentFrameInParent.size.width, 
                                            self.contentFrameInParent.size.height);
    }
}

#pragma mark Edit mode

- (void)enterEditModeAnimated:(BOOL)animated
{
    if (self.edited) {
        HLSLoggerWarn(@"Already in edit mode");
        return;
    }
    
    // TODO: Add a view all around to trap clicks outside the strip view (triggering exitMode)
    
    // Add handles around the strip view
    self.leftHandleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CoconutKit_handle_default_left.png"]] autorelease];
    self.leftHandleView.exclusiveTouch = YES;
    [self addSubview:self.leftHandleView];
    
    self.rightHandleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CoconutKit_handle_default_right.png"]] autorelease];
    self.rightHandleView.exclusiveTouch = YES;
    [self addSubview:self.rightHandleView];
    
    self.edited = YES;
    
    // Calling directly. We want the layout to be up-to-date before the animation takes place
    [self layoutSubviews];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepUpdatingViews:[NSArray arrayWithObjects:self.leftHandleView, self.rightHandleView, nil] 
                                                                 withAlphaVariation:-1.f];
    animationStep1.duration = 0.;
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepUpdatingViews:[NSArray arrayWithObjects:self.leftHandleView, self.rightHandleView, nil] 
                                                                 withAlphaVariation:1.f];
    self.editModeAnimation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, nil]];
    self.editModeAnimation.tag = @"editMode";
    self.editModeAnimation.delegate = self;
    self.editModeAnimation.lockingUI = YES;
    [self.editModeAnimation playAnimated:animated];
}

- (void)exitEditModeAnimated:(BOOL)animated
{
    if (! self.edited) {
        HLSLoggerWarn(@"Not in edit mode");
        return;
    }
    
    HLSAnimation *reverseEditModeAnimation = [self.editModeAnimation reverseAnimation];
    [reverseEditModeAnimation playAnimated:animated];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    // Forward animation
    if ([animation.tag isEqual:@"editMode"]) {
        [self.delegate stripView:self didEnterEditModeAnimated:animated];
    }
    // Reverse animation
    else {
        [self.leftHandleView removeFromSuperview];
        self.leftHandleView = nil;
        
        [self.rightHandleView removeFromSuperview];
        self.rightHandleView = nil;
        
        self.edited = NO;
        [self setNeedsLayout];
        
        [self.delegate stripView:self didExitEditModeAnimated:animated];
    }
}

@end
