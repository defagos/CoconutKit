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
#import "HLSStripHandleView.h"

static const CGFloat kStripViewHandleWidth = 10.f;

@interface HLSStripView ()

@property (nonatomic, retain) UIView *leftHandleView;
@property (nonatomic, retain) UIView *rightHandleView;
@property (nonatomic, retain) UILabel *leftLabel;
@property (nonatomic, retain) UILabel *rightLabel;

@end

// TODO: Text at both ends. Adjust size, apply fast fade out effect when text are brought near enough so that no
//       overlap occurs

@implementation HLSStripView

#pragma mark Object creation and destruction

- (id)initWithStrip:(HLSStrip *)strip view:(UIView *)view
{
    if ((self = [super initWithFrame:view.frame])) {
        self.strip = strip;
        
        self.backgroundColor = [UIColor clearColor];
        
        // The view inside must stretch with the strip view wrapper
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        
        // Add labels at strip ends. When the strip is large enough, this makes it possible to display
        // some text (e.g. the values at the end)
        self.leftLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.leftLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.leftLabel];
        self.rightLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.rightLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.rightLabel];
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
    self.leftHandleView = nil;
    self.rightHandleView = nil;
    self.leftLabel = nil;
    self.rightLabel = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize strip = m_strip;

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
}

#pragma mark Edit mode

- (void)enterEditMode
{
    if (self.edited) {
        HLSLoggerWarn(@"Already in edit mode");
        return;
    }
    
    // TODO: Add a view all around to trap clicks outside the strip view (triggering exitMode)
    
    // Display handles around the strip view
    self.leftHandleView = [[[HLSStripHandleView alloc] initWithFrame:CGRectMake(-kStripViewHandleWidth, 
                                                                    0.f, 
                                                                    kStripViewHandleWidth, 
                                                                    self.frame.size.height)]
                           autorelease];
    self.leftHandleView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.leftHandleView];
    
    self.rightHandleView = [[[HLSStripHandleView alloc] initWithFrame:CGRectMake(self.frame.size.width, 
                                                                     0.f, 
                                                                     kStripViewHandleWidth, 
                                                                     self.frame.size.height)]
                            autorelease];
    self.rightHandleView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.rightHandleView];
    
    self.edited = YES;
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
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches began");
    [self.delegate stripViewHasBeenClicked:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches moved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    HLSLoggerInfo(@"Touches cancelled");
}

- (void)endTouches:(NSSet *)touches animated:(BOOL)animated
{
    HLSLoggerInfo(@"Touches ended");
}

@end
