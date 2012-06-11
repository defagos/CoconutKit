//
//  HLSExpandingSearchBar.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSExpandingSearchBar.h"

#import "HLS3DTransform.h"
#import "HLSLogger.h"
#import "NSBundle+HLSExtensions.h"

static const CGFloat kSearchBarStandardHeight = 44.f;

@interface HLSExpandingSearchBar ()

- (void)hlsExpandingSearchBarInit;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIButton *searchButton;

- (void)showSearchBar:(id)sender;

@end

@implementation HLSExpandingSearchBar

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsExpandingSearchBarInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsExpandingSearchBarInit];
    }
    return self;
}

- (void)dealloc
{
    self.searchBar = nil;
    self.searchButton = nil;

    [super dealloc];
}

- (void)hlsExpandingSearchBarInit
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, kSearchBarStandardHeight, kSearchBarStandardHeight)] autorelease];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.alpha = 0.f;
    [self addSubview:self.searchBar];
    
    self.searchButton = [[[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, kSearchBarStandardHeight, kSearchBarStandardHeight)] autorelease];
    self.searchButton.autoresizingMask = UIViewAutoresizingNone;
    NSString *imagePath = [[NSBundle coconutKitBundle] pathForResource:@"SearchFieldIcon" ofType:@"png"];
    [self.searchButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
    [self.searchButton addTarget:self 
                          action:@selector(showSearchBar:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.searchButton];
}

#pragma mark Accessors and mutators

@synthesize searchBar = m_searchBar;

@synthesize searchButton = m_searchButton;

@synthesize alignment = m_alignment;

- (void)setAlignment:(HLSExpandingSearchBarAlignment)alignment
{
    if (m_layoutDone) {
        HLSLoggerWarn(@"The alignment cannot be changed once the search bar has been displayed");
        return;
    }
    
    m_alignment = alignment;
}

#pragma mark Layout

- (void)layoutSubviews
{
    // First layout
    if (! m_layoutDone) {
        // Layout subviews
        if (self.alignment == HLSExpandingSearchBarAlignmentLeft) {
            self.searchBar.center = CGPointMake(kSearchBarStandardHeight / 2.f, CGRectGetMidY(self.bounds));
        }
        else {
            self.searchBar.center = CGPointMake(CGRectGetWidth(self.bounds) - kSearchBarStandardHeight / 2.f, CGRectGetMidY(self.bounds));
        }
        self.searchButton.frame = self.searchBar.frame;
        
        m_layoutDone = YES;
    }
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame), 
                            CGRectGetMinY(self.frame), 
                            CGRectGetWidth(self.frame), 
                            kSearchBarStandardHeight);
}

#pragma mark Action callbacks

- (void)showSearchBar:(id)sender
{
    // Create the animation
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 0.1;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = -1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:self.searchButton];
    HLSViewAnimationStep *viewAnimationStep12 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep12.alphaVariation = 1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep12 forView:self.searchBar];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.duration = 0.3;
    HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep21.transform = [HLS3DTransform transformFromRect:self.searchBar.frame 
                                                               toRect:CGRectMake(0.f, 
                                                                                 CGRectGetMinY(self.searchBar.frame),
                                                                                 CGRectGetWidth(self.frame), 
                                                                                 CGRectGetHeight(self.searchBar.frame))];
    [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:self.searchBar];
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, nil]];
    animation.tag = @"searchBar";
    animation.resizeViews = YES;
    animation.delegate = self;
    
    [animation playAnimated:YES];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{

}

@end
