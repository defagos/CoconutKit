//
//  HLSContainerStackView.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSContainerStackView.h"

#import "HLSLogger.h"
#import "UIView+HLSExtensions.h"

@interface HLSContainerStackView ()

@property (nonatomic, strong) NSMutableArray *groupViews;           // The HLSContainerGroupView in the hierarchy, from the bottommost to the topmost one

@end

@implementation HLSContainerStackView

#pragma mark Object creation and destruction

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.groupViews = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = HLSViewAutoresizingAll;
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)setFrame:(CGRect)frame
{
    [self.delegate containerStackViewWillChangeFrame:self];
    [super setFrame:frame];
    [self.delegate containerStackViewDidChangeFrame:self];
}

#pragma mark View management

- (NSUInteger)indexOfContentView:(UIView *)contentView
{
    NSUInteger i = 0;
    for (HLSContainerGroupView *groupView in self.groupViews) {
        if (groupView.frontContentView == contentView) {
            return i;
        }
        ++i;
    }
    return NSNotFound;
}

- (NSArray *)contentViews
{
    NSMutableArray *contentViews = [NSMutableArray array];
    for (HLSContainerGroupView *groupView in self.groupViews) {
        [contentViews addObject:groupView.frontContentView];
    }
    return [NSArray arrayWithArray:contentViews];
}

- (void)insertContentView:(UIView *)contentView atIndex:(NSInteger)index
{
    if (index > [self.groupViews count]) {
        HLSLoggerWarn(@"Invalid index %ld. Expected in [0;%lu]", (long)index, (unsigned long)[self.groupViews count]);
        return;
    }
    
    // Add to the top
    if (index == [self.groupViews count]) {
        HLSContainerGroupView *topGroupView = [self.groupViews lastObject];
        
        HLSContainerGroupView *newGroupView = [[HLSContainerGroupView alloc] initWithFrame:self.bounds frontContentView:contentView];
        newGroupView.backContentView = topGroupView;
        
        [self.groupViews addObject:newGroupView];
        [self addSubview:newGroupView];
    }
    // Insert in the middle
    else {
        HLSContainerGroupView *groupViewAtIndex = [self.groupViews objectAtIndex:index];
        HLSContainerGroupView *belowGroupViewAtIndex = (index > 0) ? [self.groupViews objectAtIndex:index - 1] : nil;
        
        HLSContainerGroupView *newGroupView = [[HLSContainerGroupView alloc] initWithFrame:self.bounds frontContentView:contentView];
        newGroupView.backContentView = belowGroupViewAtIndex;
        groupViewAtIndex.backContentView = newGroupView;
        
        [self.groupViews insertObject:newGroupView atIndex:index];
    }
}

- (void)removeContentView:(UIView *)contentView
{
    NSUInteger index = [self indexOfContentView:contentView];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"Content view not found");
        return;
    }
    
    HLSContainerGroupView *groupView = [self.groupViews objectAtIndex:index];
    HLSContainerGroupView *belowGroupView = (index > 0) ? [self.groupViews objectAtIndex:index - 1] : nil;
    
    // Remove at the top
    if (index == [self.groupViews count] - 1) {
        // No need to call -removeFromSuperview, the view is moved between superviews automatically. No need
        // for a retain-autorelease: The view is kept alive during this process. See UIView documentation
        [self insertSubview:belowGroupView atIndex:0];
    }
    // Remove in the middle
    else {
        HLSContainerGroupView *aboveGroupView = [self.groupViews objectAtIndex:index + 1];
        aboveGroupView.backContentView = belowGroupView;
    }
    
    [groupView removeFromSuperview];
    [self.groupViews removeObjectAtIndex:index];
}

- (HLSContainerGroupView *)groupViewForContentView:(UIView *)contentView
{
    NSUInteger i = 0;
    for (HLSContainerGroupView *groupView in self.groupViews) {
        if (groupView.frontContentView == contentView) {
            return groupView;
        }
        ++i;
    }
    return nil;
}

@end
