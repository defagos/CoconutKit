//
//  HLSContainerStackView.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerStackView.h"

#import "HLSLogger.h"
#import "UIView+HLSExtensions.h"

@interface HLSContainerStackView ()

@property (nonatomic, retain) NSMutableArray *groupViews;

- (NSUInteger)indexOfSubview:(UIView *)view;

@end

@implementation HLSContainerStackView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.groupViews = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = HLSViewAutoresizingAll;
    }
    return self;
}

- (void)dealloc
{
    self.groupViews = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize groupViews = m_groupViews;

#pragma mark View management

- (HLSContainerGroupView *)groupViewForSubview:(UIView *)subview
{
    NSUInteger i = 0;
    for (HLSContainerGroupView *groupView in self.groupViews) {
        if (groupView.frontView == subview) {
            return groupView;
        }
        ++i;
    }
    return nil;
}

- (NSUInteger)indexOfSubview:(UIView *)view
{
    NSUInteger i = 0;
    for (HLSContainerGroupView *groupView in self.groupViews) {
        if (groupView.frontView == view) {
            return i;
        }
        ++i;
    }
    return NSNotFound;
}

- (NSArray *)subviews
{
    NSMutableArray *subviews = [NSMutableArray array];
    for (HLSContainerGroupView *groupView in self.groupViews) {
        [subviews addObject:groupView.frontView];
    }
    return [NSArray arrayWithArray:subviews];
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index
{
    if (index > [self.groupViews count]) {
        HLSLoggerWarn(@"Invalid index %d. Expected in [0;%d]", index, [self.groupViews count]);
        return;
    }
    
    if (index == [self.groupViews count]) {
        HLSContainerGroupView *topGroupView = [self.groupViews lastObject];
        
        HLSContainerGroupView *newGroupView = [[[HLSContainerGroupView alloc] initWithFrame:self.bounds frontView:subview] autorelease];
        newGroupView.backGroupView = topGroupView;
        
        [self.groupViews addObject:newGroupView];
        [super addSubview:newGroupView];
    }
    else {
        HLSContainerGroupView *groupViewAtIndex = [self.groupViews objectAtIndex:index];
        HLSContainerGroupView *belowGroupViewAtIndex = (index > 0) ? [self.groupViews objectAtIndex:index - 1] : nil;
        
        HLSContainerGroupView *newGroupView = [[[HLSContainerGroupView alloc] initWithFrame:self.bounds frontView:subview] autorelease];
        groupViewAtIndex.backGroupView = newGroupView;
        newGroupView.backGroupView = belowGroupViewAtIndex;
        
        [self.groupViews insertObject:newGroupView atIndex:index];
    }
}

- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2
{
    // No time to lose implementing this method which will never be used anyway :)
    HLSMissingMethodImplementation();
}

- (void)addSubview:(UIView *)subview
{
    [self insertSubview:subview atIndex:[self.groupViews count]];
}

- (void)insertSubview:(UIView *)subview belowSubview:(UIView *)siblingSubview
{
    NSUInteger index = [self indexOfSubview:siblingSubview];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The given sibling subview does not belong to view hierarchy");
        return;
    }
    [self insertSubview:subview atIndex:index];
}

- (void)insertSubview:(UIView *)subview aboveSubview:(UIView *)siblingSubview
{
    NSUInteger index = [self indexOfSubview:siblingSubview];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"The given sibling subview does not belong to view hierarchy");
        return;
    }
    [self insertSubview:subview atIndex:index + 1];
}

- (void)removeSubview:(UIView *)subview
{
    NSUInteger index = [self indexOfSubview:subview];
    if (index == NSNotFound) {
        HLSLoggerWarn(@"Subview not found");
        return;
    }
    
    HLSContainerGroupView *groupView = [self.groupViews objectAtIndex:index];
    HLSContainerGroupView *belowGroupView = (index > 0) ? [self.groupViews objectAtIndex:index - 1] : nil;
    if (index == [self.groupViews count] - 1) {
        groupView.backGroupView = nil;
        
        [super insertSubview:belowGroupView atIndex:0];
    }
    else {
        HLSContainerGroupView *aboveGroupView = [self.groupViews objectAtIndex:index + 1];
        aboveGroupView.backGroupView = belowGroupView;
    }
    
    [groupView removeFromSuperview];
    [self.groupViews removeObjectAtIndex:index];
}

@end
