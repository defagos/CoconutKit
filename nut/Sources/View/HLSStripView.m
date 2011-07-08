//
//  HLSStripView.m
//  nut
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripView.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

static const CGFloat kStripViewHandleWidth = 30.f;

@interface HLSStripView ()

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *leftHandleView;
@property (nonatomic, retain) UIView *rightHandleView;
@property (nonatomic, retain) UILabel *leftLabel;
@property (nonatomic, retain) UILabel *rightLabel;

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

#pragma mark Layout

- (void)layoutSubviews
{
    if (self.edited) {
        self.frame = CGRectMake(self.contentFrameInParent.origin.x - kStripViewHandleWidth,
                                self.contentFrameInParent.origin.y, 
                                self.contentFrameInParent.size.width + 2 * kStripViewHandleWidth,
                                self.contentFrameInParent.size.height);
        self.leftHandleView.frame = CGRectMake(0.f, 
                                               0.f, 
                                               kStripViewHandleWidth, 
                                               self.contentFrameInParent.size.height);
        self.rightHandleView.frame = CGRectMake(kStripViewHandleWidth + self.contentFrameInParent.size.width, 
                                                0.f, 
                                                kStripViewHandleWidth, 
                                                self.contentFrameInParent.size.height);
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

- (void)enterEditMode
{
    if (self.edited) {
        HLSLoggerWarn(@"Already in edit mode");
        return;
    }
    
    // TODO: Add a view all around to trap clicks outside the strip view (triggering exitMode)
    
    // Add handles around the strip view
    self.leftHandleView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.leftHandleView.backgroundColor = [UIColor blueColor];
    self.leftHandleView.exclusiveTouch = YES;
    [self addSubview:self.leftHandleView];
    
    self.rightHandleView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.rightHandleView.backgroundColor = [UIColor blueColor];
    self.rightHandleView.exclusiveTouch = YES;
    [self addSubview:self.rightHandleView];
    
    self.edited = YES;
    [self setNeedsLayout];
}

- (void)exitEditMode
{
    if (! self.edited) {
        HLSLoggerWarn(@"Not in edit mode");
        return;
    }
    
    [self.leftHandleView removeFromSuperview];
    self.leftHandleView = nil;
    
    [self.rightHandleView removeFromSuperview];
    self.rightHandleView = nil;
    
    self.edited = NO;
    [self setNeedsLayout];
}

@end
