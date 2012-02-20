//
//  UIScrollView+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIScrollView+HLSExtensions.h"

#import "HLSAssert.h"
#import "HLSFloat.h"
#import <objc/runtime.h>

static void *s_parallaxScrollViews = &s_parallaxScrollViews;

@implementation UIScrollView (HLSExtensions)

// TODO: Maybe a remove method or set to nil allowed
- (void)setupParallaxWithScrollViews:(NSArray *)scrollViews
{
    HLSAssertObjectsInEnumerationAreKindOfClass(scrollViews, UIScrollView);
    
    [self addObserver:self 
           forKeyPath:@"contentOffset"
              options:NSKeyValueObservingOptionNew 
              context:NULL];
    objc_setAssociatedObject(self, s_parallaxScrollViews, scrollViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// TODO: What if UIScrollView already implements this method? Swizzle?
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{   
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSArray *parallaxScrollViews = objc_getAssociatedObject(self, s_parallaxScrollViews);
        if (! parallaxScrollViews) {
            return;
        }
                
        // Find where the relative offset position (in [0; 1]) in the receiver
        CGFloat relativeXPos = 0.f;
        if (floateq(self.contentSize.width, CGRectGetWidth(self.frame))) {
            relativeXPos = 0.f;
        }
        else {
            relativeXPos = self.contentOffset.x / (self.contentSize.width - CGRectGetWidth(self.frame));
        }
        if (floatlt(relativeXPos, 0.f)) {
            relativeXPos = 0.f;
        }
        else if (floatgt(relativeXPos, 1.f)) {
            relativeXPos = 1.f;
        }
        
        // If reaching the top or the bottom of the master scroll view, prevent the other scroll views from
        // scrolling further
        CGFloat relativeYPos = 0.f;
        if (floateq(self.contentSize.height, CGRectGetHeight(self.frame))) {
            relativeYPos = 0.f;
        }
        else {
            relativeYPos = self.contentOffset.y / (self.contentSize.height - CGRectGetHeight(self.frame));
        }
        if (floatlt(relativeYPos, 0.f)) {
            relativeYPos = 0.f;
        }
        else if (floatgt(relativeYPos, 1.f)) {
            relativeYPos = 1.f;
        }
        
        // Apply the same relative offset position to all synchronized scroll views
        for (UIScrollView *scrollView in parallaxScrollViews) {
            CGFloat xPos = relativeXPos * (scrollView.contentSize.width - CGRectGetWidth(scrollView.frame));
            CGFloat yPos = relativeYPos * (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame));
            scrollView.contentOffset = CGPointMake(xPos, yPos);
        }
    }
}

@end
