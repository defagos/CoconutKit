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
#import "HLSLogger.h"
#import <objc/runtime.h>

static void *s_parallaxScrollViews = &s_parallaxScrollViews;
static void *s_parallaxBounces = &s_parallaxBounces;

@implementation UIScrollView (HLSExtensions)

- (void)synchronizeWithScrollViews:(NSArray *)scrollViews bounces:(BOOL)bounces
{
    HLSAssertObjectsInEnumerationAreKindOfClass(scrollViews, UIScrollView);
    
    if (! scrollViews || [scrollViews count] == 0) {
        HLSLoggerError(@"No scroll views to bind");
        return;
    }
    
    if ([scrollViews containsObject:self]) {
        HLSLoggerError(@"The master scroll view cannot be bound to itself");
        return;
    }
    
    [self addObserver:self 
           forKeyPath:@"contentOffset"
              options:NSKeyValueObservingOptionNew 
              context:NULL];
    objc_setAssociatedObject(self, s_parallaxScrollViews, scrollViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, s_parallaxBounces, [NSNumber numberWithBool:bounces], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeSynchronization
{
    objc_setAssociatedObject(self, s_parallaxScrollViews, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, s_parallaxBounces, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
        
        CGFloat relativeYPos = 0.f;
        if (floateq(self.contentSize.height, CGRectGetHeight(self.frame))) {
            relativeYPos = 0.f;
        }
        else {
            relativeYPos = self.contentOffset.y / (self.contentSize.height - CGRectGetHeight(self.frame));
        }
                
        // If reaching the top or the bottom of the master scroll view, prevent the other scroll views from
        // scrolling further (if enabled)
        BOOL bounces = [objc_getAssociatedObject(self, s_parallaxBounces) boolValue];
        if (! bounces) {
            if (floatlt(relativeXPos, 0.f)) {
                relativeXPos = 0.f;
            }
            else if (floatgt(relativeXPos, 1.f)) {
                relativeXPos = 1.f;
            }
            
            if (floatlt(relativeYPos, 0.f)) {
                relativeYPos = 0.f;
            }
            else if (floatgt(relativeYPos, 1.f)) {
                relativeYPos = 1.f;
            }            
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
