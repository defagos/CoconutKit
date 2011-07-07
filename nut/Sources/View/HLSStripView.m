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

static const CGFloat kStripViewHandleWidth = 20.f;

@interface HLSStripView ()

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) UIView *leftHandleView;
@property (nonatomic, retain) UIView *rightHandleView;
@property (nonatomic, retain) UILabel *leftLabel;
@property (nonatomic, retain) UILabel *rightLabel;

- (void)endTouches:(NSSet *)touches;

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
        
        self.contentFrame = contentView.frame;
        
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
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize strip = m_strip;

@synthesize contentView = m_contentView;

@synthesize contentFrame = m_contentFrame;

- (void)setContentFrame:(CGRect)contentFrame
{
    m_contentFrame = contentFrame;
    [self setNeedsLayout];
}

@synthesize leftHandleView = m_leftHandleView;

@synthesize rightHandleView = m_rightHandleView;

@synthesize leftLabel = m_leftLabel;

@synthesize rightLabel = m_rightLabel;

@synthesize edited = m_edited;

@synthesize delegate = m_delegate;

#pragma mark Layout

- (void)layoutSubviews
{
    HLSLoggerInfo(@"Laying out subviews");
    
    if (self.edited) {
        self.frame = CGRectMake(self.contentFrame.origin.x - kStripViewHandleWidth,
                                self.contentFrame.origin.y, 
                                self.contentFrame.size.width + 2 * kStripViewHandleWidth,
                                self.contentFrame.size.height);
        self.leftHandleView.frame = CGRectMake(0.f, 
                                               0.f, 
                                               kStripViewHandleWidth, 
                                               self.contentFrame.size.height);
        self.rightHandleView.frame = CGRectMake(kStripViewHandleWidth + self.contentFrame.size.width, 
                                                0.f, 
                                                kStripViewHandleWidth, 
                                                self.contentFrame.size.height);
        self.contentView.frame = CGRectMake(kStripViewHandleWidth,
                                            0.f,
                                            self.contentFrame.size.width,
                                            self.contentFrame.size.height);        
    }
    else {
        self.frame = self.contentFrame;
        self.contentView.frame = CGRectMake(0.f, 
                                            0.f, 
                                            self.contentFrame.size.width, 
                                            self.contentFrame.size.height);
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

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches began");
    
    // Has the content view been touched?
    CGPoint pos = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, pos)) {
        [self.delegate stripViewHasBeenClicked:self];    
    }    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Has the left handle been touched?
    CGPoint pos = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.leftHandleView.frame, pos)) {
        if (! m_draggingLeftHandle) {
            m_draggingLeftHandle = YES;
            HLSLoggerInfo(@"Dragging left handle");
        }
    }
    // Has the right handle been touched?
    else if (CGRectContainsPoint(self.rightHandleView.frame, pos)) {
        if (! m_draggingRightHandle) {
            m_draggingRightHandle = YES;
            HLSLoggerInfo(@"Dragging right handle");
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)endTouches:(NSSet *)touches
{
    if (m_draggingLeftHandle) {
        HLSLoggerInfo(@"Stopped dragging left handle");
    }
    if (m_draggingRightHandle) {
        HLSLoggerInfo(@"Stopped dragging right handle");
    }
    
    m_draggingLeftHandle = NO;
    m_draggingRightHandle = NO;
}

@end
