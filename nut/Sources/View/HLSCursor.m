//
//  HLSCursor.m
//  nut
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSCursor.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

static const CGFloat kDefaultSpacing = 20.f;

@interface HLSCursor ()

- (void)initialize;

@end

@implementation HLSCursor

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    self.highlightImage = nil;
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)initialize
{
    self.spacing = kDefaultSpacing;
}

#pragma mark Accessors and mutators

@synthesize spacing = m_spacing;

@synthesize highlightImage = m_highlightImage;

@synthesize highlightContentStretch = m_highlightContentStretch;

@synthesize selectedIndex = m_selectedIndex;

@synthesize dataSource = m_dataSource;

@synthesize delegate = m_delegate;

#pragma mark Layout

- (void)layoutSubviews
{
    // Check data source
    NSUInteger nbrElements = [self.dataSource numberOfElementsForCursor:self];
    if (nbrElements == 0) {
        HLSLoggerError(@"Cursor data source is empty");
        return;
    }
    
    // Fill with views generated from the data source, and calculate the needed frame size
    CGFloat totalWidth = 0.f;
    if ([self.dataSource respondsToSelector:@selector(cursor:viewAtIndex:selected:)]) {
        for (NSUInteger index = 0; index < nbrElements; ++index) {
            UIView *elementView = [self.dataSource cursor:self viewAtIndex:index selected:NO];
            [self addSubview:elementView];
            
            totalWidth += elementView.frame.size.width;
            if (index != nbrElements - 1) {
                totalWidth += self.spacing;
            }
        }
    }
    else if ([self.dataSource respondsToSelector:@selector(cursor:titleAtIndex:)]) {
        for (NSUInteger index = 0; index < nbrElements; ++index) {
            UIFont *font = nil;
            if ([self.dataSource respondsToSelector:@selector(cursor:fontAtIndex:selected:)]) {
                font = [self.dataSource cursor:self fontAtIndex:index selected:NO];
            }
            else {
                font = [UIFont systemFontOfSize:17.f];
            }
            NSString *title = [self.dataSource cursor:self titleAtIndex:index];
            CGSize titleSize = [title sizeWithFont:font];
            
            UILabel *elementLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, titleSize.width, titleSize.height)] autorelease];
            elementLabel.text = title;
            elementLabel.backgroundColor = [UIColor clearColor];
            if ([self.dataSource respondsToSelector:@selector(cursor:textColorAtIndex:selected:)]) {
                elementLabel.textColor = [self.dataSource cursor:self textColorAtIndex:index selected:NO];
            }
            else {
                elementLabel.textColor = [self.backgroundColor invertColor];
            }
            if ([self.dataSource respondsToSelector:@selector(cursor:shadowColorAtIndex:selected:)]) {
                elementLabel.shadowColor = [self.dataSource cursor:self shadowColorAtIndex:index selected:NO];
            }
            if ([self.dataSource respondsToSelector:@selector(cursor:shadowOffsetAtIndex:selected:)]) {
                elementLabel.shadowOffset = [self.dataSource cursor:self shadowOffsetAtIndex:index selected:NO];
            }
            [self addSubview:elementLabel];
            
            totalWidth += elementLabel.frame.size.width;
            if (index != nbrElements - 1) {
                totalWidth += self.spacing;
            }
        }
    }
    else {
        HLSLoggerError(@"Cursor data source must either implement cursor:viewAtIndex: or cursor:titleAtIndex:");
        return;
    }
    
    // Adjust individual frames so that the subviews are centered within the available frame; warn if too large (will still
    // be centered)
    CGFloat xPos = floorf(fabs(self.frame.size.width - totalWidth) / 2.f);
    if (floatgt(totalWidth, self.frame.size.width)) {
        HLSLoggerWarn(@"Cursor frame not wide enough");
        xPos = -xPos;
    }
    for (UIView *subView in self.subviews) {
        CGFloat yPos = floorf(fabs(self.frame.size.height - subView.frame.size.height) / 2.f);
        if (floatgt(subView.frame.size.height, self.frame.size.height)) {
            HLSLoggerWarn(@"Cursor frame not tall enough");
            yPos = -yPos;
        }
        
        subView.frame = CGRectMake(xPos, yPos, subView.frame.size.width, subView.frame.size.height);
        xPos += subView.frame.size.width + self.spacing;
    }
}

@end
