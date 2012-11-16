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
        // on its initial alpha. The transform is always set to identity, corresponding to an initial portrait orientation
        UIView *frontView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        frontView.transform = CGAffineTransformIdentity;
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
    return [self.frontView.subviews firstObject_hls];
}

- (UIView *)frontView
{
    return [self.subviews lastObject];
}

- (UIView *)backContentView
{
    return [self.backView.subviews firstObject_hls];
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
        return [self.subviews firstObject_hls];
    }
    else {
        return nil;
    }    
}

@end
