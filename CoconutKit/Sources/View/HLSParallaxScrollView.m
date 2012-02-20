//
//  HLSParallaxScrollView.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSParallaxScrollView.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

@interface HLSParallaxScrollView ()

- (void)hlsParallaxScrollViewInitWithFrame:(CGRect)frame;

@property (nonatomic, retain) UIScrollView *contentScrollView;
@property (nonatomic, retain) NSArray *backgroundScrollViews;

@end

@implementation HLSParallaxScrollView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsParallaxScrollViewInitWithFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsParallaxScrollViewInitWithFrame:self.bounds];
    }
    return self;
}

- (void)dealloc
{
    self.contentScrollView = nil;
    self.backgroundScrollViews = nil;
    
    [super dealloc];
}

- (void)hlsParallaxScrollViewInitWithFrame:(CGRect)frame
{
    self.contentScrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    self.contentScrollView.bounces = NO;
    self.contentScrollView.delegate = self;
    [self addSubview:self.contentScrollView];
    
    self.backgroundScrollViews = [NSArray array];
}

#pragma mark Accessors and mutators

@synthesize contentScrollView = m_contentScrollView;

- (void)setContentView:(UIView *)contentView
{
    if (m_contentViewSet) {
        HLSLoggerError(@"The content view cannot be changed once set");
        return;
    }
    
    if (! floateq(CGRectGetMinX(contentView.frame), 0.f) || ! floateq(CGRectGetMinY(contentView.frame), 0.f)) {
        HLSLoggerError(@"The view must have (0, 0) as origin");
        return;
    }
    
    [self.contentScrollView addSubview:contentView];
    self.contentScrollView.contentSize = contentView.frame.size;
    
    m_contentViewSet = YES;
}

@synthesize backgroundScrollViews = m_backgroundScrollViews;

#pragma mark Content

- (void)addBackgroundView:(UIView *)backgroundView
{
    if (! m_contentViewSet) {
        HLSLoggerError(@"Cannot add backgrounds if no content view has been set");
        return;
    }
    
    if (! floateq(CGRectGetMinX(backgroundView.frame), 0.f) || ! floateq(CGRectGetMinY(backgroundView.frame), 0.f)) {
        HLSLoggerError(@"The view must have (0, 0) as origin");
        return;
    }
    
    // TODO: Check that rectangles are nested
    
    UIScrollView *backgroundScrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    [backgroundScrollView addSubview:backgroundView];
    backgroundScrollView.contentSize = backgroundView.frame.size;
    
    [self addSubview:backgroundScrollView];
    [self sendSubviewToBack:backgroundScrollView];
    
    self.backgroundScrollViews = [self.backgroundScrollViews arrayByAddingObject:backgroundScrollView];
}

#pragma mark UIScrollViewDelegate protocol implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSAssert(scrollView == self.contentScrollView, @"Incorrect scroll view");
    
    CGFloat relativeXPos = 0.f;
    if (floateq(self.contentScrollView.contentSize.width, CGRectGetWidth(self.contentScrollView.frame))) {
        relativeXPos = 0.f;
    }
    else {
        relativeXPos = self.contentScrollView.contentOffset.x / (self.contentScrollView.contentSize.width - CGRectGetWidth(self.contentScrollView.frame));
    }
    
    CGFloat relativeYPos = 0.f;
    if (floateq(self.contentScrollView.contentSize.height, CGRectGetHeight(self.contentScrollView.frame))) {
        relativeYPos = 0.f;
    }
    else {
        relativeYPos = self.contentScrollView.contentOffset.y / (self.contentScrollView.contentSize.height - CGRectGetHeight(self.contentScrollView.frame));
    }
    
    for (UIScrollView *backgroundScrollView in self.backgroundScrollViews) {
        CGFloat xPos = relativeXPos * (backgroundScrollView.contentSize.width - CGRectGetWidth(backgroundScrollView.frame));
        CGFloat yPos = relativeYPos * (backgroundScrollView.contentSize.height - CGRectGetHeight(backgroundScrollView.frame));
        backgroundScrollView.contentOffset = CGPointMake(xPos, yPos);
    }
}

@end
