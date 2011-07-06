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

static const CGFloat kStripViewHandleWidth = 10.f;

@interface HLSStripView ()

@property (nonatomic, retain) IBOutlet UIView *leftHandleView;
@property (nonatomic, retain) IBOutlet UIView *rightHandleView;

@end

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
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize strip = m_strip;

@synthesize leftHandleView = m_leftHandleView;

@synthesize rightHandleView = m_rightHandleView;

@synthesize edited = m_edited;

@synthesize delegate = m_delegate;

#pragma mark Edit mode

- (void)enterEditMode
{
    // Display handles around the strip view
    self.leftHandleView = [[[UIView alloc] initWithFrame:CGRectMake(-kStripViewHandleWidth, 
                                                                    0.f, 
                                                                    kStripViewHandleWidth, 
                                                                    self.frame.size.height)]
                           autorelease];
    self.leftHandleView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.leftHandleView];
    
    self.rightHandleView = [[[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 
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
