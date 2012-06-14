//
//  HLSExpandingSearchBar.m
//  CoconutKit
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSExpandingSearchBar.h"

#import "HLSLogger.h"
#import "NSBundle+HLSExtensions.h"

static const CGFloat kSearchBarStandardHeight = 44.f;

@interface HLSExpandingSearchBar ()

- (void)hlsExpandingSearchBarInit;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIButton *searchButton;

- (HLSAnimation *)expansionAnimation;

- (void)toggleSearchBar:(id)sender;

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
    self.delegate = nil;

    [super dealloc];
}

- (void)hlsExpandingSearchBarInit
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, kSearchBarStandardHeight, kSearchBarStandardHeight)] autorelease];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.alpha = 0.f;
    self.searchBar.delegate = self;
    [self addSubview:self.searchBar];
    
    self.searchButton = [[[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, kSearchBarStandardHeight, kSearchBarStandardHeight)] autorelease];
    self.searchButton.autoresizingMask = UIViewAutoresizingNone;
    NSString *imagePath = [[NSBundle coconutKitBundle] pathForResource:@"SearchFieldIcon" ofType:@"png"];
    [self.searchButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
    [self.searchButton addTarget:self 
                          action:@selector(toggleSearchBar:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.searchButton];
}

#pragma mark Accessors and mutators

// TODO: When HLSRestrictedProtocolProxy is available, use it to restrict the UISearchBar interface to those methods,
//       and make interface and implementation simpler (can then get rid of the methods below)

- (NSString *)text
{
    return self.searchBar.text;
}

- (void)setText:(NSString *)text
{
    self.searchBar.text = text;
}

- (NSString *)prompt
{
    return self.searchBar.prompt;
}

- (void)setPrompt:(NSString *)prompt
{
    self.searchBar.prompt = prompt;
}

- (NSString *)placeholder
{
    return self.searchBar.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.searchBar.placeholder = placeholder;
}

- (BOOL)showsBookmarkButton
{
    return self.searchBar.showsBookmarkButton;
}

- (void)setShowsBookmarkButton:(BOOL)showsBookmarkButton
{
    self.searchBar.showsBookmarkButton = showsBookmarkButton;
}

- (BOOL)showsCancelButton
{
    return self.searchBar.showsCancelButton;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    self.searchBar.showsCancelButton = showsCancelButton;
}

- (BOOL)showsSearchResultsButton
{
    return self.searchBar.showsSearchResultsButton;
}

- (void)setShowsSearchResultsButton:(BOOL)showsSearchResultsButton
{
    self.searchBar.showsSearchResultsButton = showsSearchResultsButton;
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return self.searchBar.autocapitalizationType;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
    self.searchBar.autocapitalizationType = autocapitalizationType;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return self.searchBar.autocorrectionType;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    self.searchBar.autocorrectionType = autocorrectionType;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return self.searchBar.spellCheckingType;
}

- (void)setSpellCheckingType:(UITextSpellCheckingType)spellCheckingType
{
    self.searchBar.spellCheckingType = spellCheckingType;
}

- (UIKeyboardType)keyboardType
{
    return self.searchBar.keyboardType;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    self.searchBar.keyboardType = keyboardType;
}

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

@synthesize delegate = m_delegate;

#pragma mark Layout

- (void)layoutSubviews
{
    // First layout
    if (! m_layoutDone) {
        // Layout subviews
        if (self.alignment == HLSExpandingSearchBarAlignmentLeft) {
            self.searchBar.center = CGPointMake(roundf(kSearchBarStandardHeight / 2.f), roundf(CGRectGetMidY(self.bounds)));
        }
        else {
            self.searchBar.center = CGPointMake(roundf(CGRectGetWidth(self.bounds) - kSearchBarStandardHeight / 2.f), roundf(CGRectGetMidY(self.bounds)));
        }
        self.searchButton.frame = self.searchBar.frame;
        
        m_layoutDone = YES;
    }
    
    // As for the embedded UISearchBar, force vertical dimensions
    self.frame = CGRectMake(CGRectGetMinX(self.frame), 
                            CGRectGetMinY(self.frame), 
                            CGRectGetWidth(self.frame), 
                            kSearchBarStandardHeight);    
}

#pragma mark Animation

// We do not cache the animation: The source and target frames can vary depending on rotations. We
// therefore need a way to generate the animation easily when we need it
- (HLSAnimation *)expansionAnimation
{
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
    animationStep1.duration = 0.15;
    HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
    viewAnimationStep11.alphaVariation = 1.f;
    [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:self.searchBar];
    
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
    animationStep2.duration = 0.25;
    if (self.alignment == HLSExpandingSearchBarAlignmentLeft) {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 transformFromRect:CGRectMake(0.f,
                                                          CGRectGetMinY(self.searchBar.frame),
                                                          kSearchBarStandardHeight, 
                                                          CGRectGetHeight(self.searchBar.frame))
                                        toRect:CGRectMake(0.f, 
                                                          CGRectGetMinY(self.searchBar.frame),
                                                          CGRectGetWidth(self.bounds), 
                                                          CGRectGetHeight(self.searchBar.frame))];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:self.searchBar];
    }
    else {
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep21 transformFromRect:CGRectMake(CGRectGetMaxX(self.bounds) - kSearchBarStandardHeight,
                                                          CGRectGetMinY(self.searchBar.frame),
                                                          kSearchBarStandardHeight, 
                                                          CGRectGetHeight(self.searchBar.frame))
                                        toRect:CGRectMake(0.f, 
                                                          CGRectGetMinY(self.searchBar.frame),
                                                          CGRectGetWidth(self.bounds), 
                                                          CGRectGetHeight(self.searchBar.bounds))];
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:self.searchBar];
        
        HLSViewAnimationStep *viewAnimationStep22 = [HLSViewAnimationStep viewAnimationStep];
        [viewAnimationStep22 transformFromRect:CGRectMake(CGRectGetMaxX(self.bounds) - kSearchBarStandardHeight,
                                                          CGRectGetMinY(self.searchButton.frame),
                                                          kSearchBarStandardHeight, 
                                                          CGRectGetHeight(self.searchButton.frame))
                                        toRect:CGRectMake(0.f, 
                                                          CGRectGetMinY(self.searchButton.frame),
                                                          kSearchBarStandardHeight, 
                                                          CGRectGetHeight(self.searchButton.frame))];
        [animationStep2 addViewAnimationStep:viewAnimationStep22 forView:self.searchButton];
    }
    
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, nil]];
    animation.tag = @"searchBar";
    animation.lockingUI = YES;
    animation.resizeViews = YES;
    animation.delegate = self;
    
    return animation;
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated
{
    if (expanded) {
        if (m_expanded) {
            HLSLoggerInfo(@"The search bar is already expanded");
            return;
        }
        HLSAnimation *animation = [self expansionAnimation];
        [animation playAnimated:animated];        
    }
    else {
        if (! m_expanded) {
            HLSLoggerInfo(@"The search bar is already collapsed");
            return;
        }
        HLSAnimation *reverseAnimation = [[self expansionAnimation] reverseAnimation];
        [reverseAnimation playAnimated:animated];
    }
}

#pragma mark Action callbacks

- (void)toggleSearchBar:(id)sender
{
    [self setExpanded:! m_expanded animated:YES];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"reverse_searchBar"]) {
        self.searchBar.text = nil;
        
        [self.searchBar resignFirstResponder];
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"searchBar"]) {
        m_expanded = YES;
        
        // At the end of the animation so that the blinking cursor does not move during the animation (ugly)
        [self.searchBar becomeFirstResponder];
    }
    else if ([animation.tag isEqualToString:@"reverse_searchBar"]) {
        m_expanded = NO;
    }
}

#pragma mark UISearchBarDelegate protocol implementation

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate expandingSearchBarShouldBeginEditing:self];
    }
    else {
        return YES;
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate expandingSearchBarTextDidEndEditing:self];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate expandingSearchBarShouldEndEditing:self];
    }
    else {
        return YES;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate expandingSearchBarTextDidEndEditing:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate expandingSearchBar:self textDidChange:searchText];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate expandingSearchBar:self shouldChangeTextInRange:range replacementText:text];
    }
    else {
        return YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate expandingSearchBarSearchButtonClicked:self];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [self.delegate expandingSearchBarBookmarkButtonClicked:self];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate expandingSearchBarCancelButtonClicked:self];
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
        [self.delegate expandingSearchBarResultsListButtonClicked:self];
    }
}

@end
