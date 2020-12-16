//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSContainerGroupView.h"

#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

@implementation HLSContainerGroupView

#pragma mark Object creation and destruction

- (instancetype)initWithFrame:(CGRect)frame frontContentView:(UIView *)frontContentView
{
    NSParameterAssert(frontContentView);
    
    if (self = [super initWithFrame:frame]) {        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = HLSViewAutoresizingAll;
        
        // Wrap into a transparent view with alpha = 1.f. This ensures that no animation applied on frontContentView relies
        // on its initial alpha. The transform is always set to identity, corresponding to an initial portrait orientation
        UIView *frontView = [[UIView alloc] initWithFrame:self.bounds];
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)initWithFrame:(CGRect)frame
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma clang diagnostic pop

#pragma mark Accessors and mutators

- (UIView *)frontContentView
{
    return self.frontView.subviews.firstObject;
}

- (UIView *)frontView
{
    return self.subviews.lastObject;
}

- (UIView *)backContentView
{
    return self.backView.subviews.firstObject;
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
        backView = [[UIView alloc] initWithFrame:self.bounds];
        backView.backgroundColor = [UIColor clearColor];
        backView.autoresizingMask = HLSViewAutoresizingAll;
        [self insertSubview:backView atIndex:0];
    }
    
    // Remark: If backContentView was previously added to another superview, it is removed while kept alive. No need for
    //         reference counting gymmastics, see UIView documentation
    [backView addSubview:backContentView];
}

- (UIView *)backView
{
    if (self.subviews.count == 2) {
        return self.subviews.firstObject;
    }
    else {
        return nil;
    }    
}

@end
