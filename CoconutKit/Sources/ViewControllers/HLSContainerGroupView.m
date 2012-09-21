//
//  HLSContainerGroupView.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/5/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSContainerGroupView.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

@interface HLSContainerGroupView ()

@property (nonatomic, retain) UIView *savedFrontContentView;
@property (nonatomic, retain) UIView *savedBackContentView;

@end

@implementation HLSContainerGroupView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame frontContentView:(UIView *)frontContentView
{
    if ((self = [super initWithFrame:frame])) {
        if (! frontContentView) {
            HLSLoggerError(@"A front content view is mandatory");
            [self release];
            return nil;
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = HLSViewAutoresizingAll;
        
        // Wrap into a transparent view with alpha = 1.f. This ensures that no animation applied on frontContentView relies
        // on its initial alpha
        UIView *frontView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        frontView.backgroundColor = [UIColor clearColor];
        frontView.autoresizingMask = HLSViewAutoresizingAll;

        // Remark: If frontContentView was previously added to another superview, it is removed while kept alive. No need
        //         to call -removeFromSuperview and no need for a retain-autorelease. See UIView documentation
        [frontView addSubview:frontContentView];
        
        [self addSubview:frontView];
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
    self.savedFrontContentView = nil;
    self.savedBackContentView = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize savedFrontContentView = m_savedFrontContentView;

@synthesize savedBackContentView = m_savedBackContentView;

- (UIView *)frontContentView
{
    return [self.frontView.subviews firstObject];
}

- (UIView *)frontView
{
    return [self.subviews lastObject];
}

- (UIView *)backContentView
{
    return [self.backView.subviews firstObject];
}

- (void)setBackContentView:(UIView *)backContentView
{
    UIView *backView = self.backView;
    if (! backContentView) {
        [backView removeFromSuperview];
        return;
    }
    
    if (! backView) {
        // Wrap into a transparent view with alpha = 1.f. This ensures that no animation applied on backContentView relies
        // on its initial alpha
        backView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        backView.backgroundColor = [UIColor clearColor];
        backView.autoresizingMask = HLSViewAutoresizingAll;
        [self insertSubview:backView atIndex:0];
    }
    
    // Remark: If backContentView was previously added to another superview, it is removed while kept alive. No need to
    //         call -removeFromSuperview and no need for a retain-autorelease. See UIView documentation
    [backView addSubview:backContentView];
}

- (UIView *)backView
{
    if ([self.subviews count] == 2) {
        return [self.subviews firstObject];
    }
    else {
        return nil;
    }    
}

#pragma mark Flattening views for improved performance during animations

- (void)flatten
{
    if (m_flattened) {
        HLSLoggerWarn(@"The group view has already been flattened");
        return;
    }
    
    // Flatten frontContentView hierarchy as a UIImageView
    UIView *frontContentView = self.frontContentView;
    
    UIView *frontContentImageView = [[[UIImageView alloc] initWithImage:[frontContentView flattenedImage]] autorelease];
    [self.frontView addSubview:frontContentImageView];
    
    self.savedFrontContentView = frontContentView;
    [frontContentView removeFromSuperview];
    
    // Flatten backContentView hierarchy as a UIImageView
    UIView *backContentView = self.backContentView;
    
    UIImageView *backContentImageView = [[[UIImageView alloc] initWithImage:[backContentView flattenedImage]] autorelease];
    [self.backView addSubview:backContentImageView];
    
    self.savedBackContentView = backContentView;
    [backContentView removeFromSuperview];
    
    m_flattened = YES;
}

- (void)unflatten
{
    if (! m_flattened) {
        HLSLoggerWarn(@"The group view has not been flattened");
        return;
    }
    
    // Unflatten frontContentView
    UIView *frontContentImageView = self.frontContentView;
    [self.frontView addSubview:self.savedFrontContentView];
    [frontContentImageView removeFromSuperview];
    self.savedFrontContentView = nil;
    
    // Unflatten the backContentView
    UIView *backContentImageView = self.backContentView;
    [self.backView addSubview:self.savedBackContentView];
    [backContentImageView removeFromSuperview];
    self.savedBackContentView = nil;
    
    m_flattened = NO;
}

@end
