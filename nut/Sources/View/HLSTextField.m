//
//  HLSTextField.m
//  nut
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTextField.h"

#import "HLSFloat.h"

// Estimation of the keyboard size at the bottom of the screen. Could be catched by listening to the keyboard
// events, but overkill
#define KEYBOARD_RESERVED_HEIGHT                350.f

@interface HLSTextField ()

/**
 * The first scroll view up the view hierarchy is the one whose content offset is adjusted to keep the field visible
 *
 * Remark:
 * To keep a field visible, some implementations directly move the parent view (not the content offset of a scroll view).
 * This is only possible in a view controller implementation, where the UI appearance is precisely known (since managed 
 * by the view controller). Here, to get the same behavior at the UIView level (where we cannot know how the UI is
 * supposed to look, which fields are grouped, etc.), we cannot simply adjust the parent view frame. What we need is a
 * way to identify which view up the caller hierarchy can be adjusted when some of its content needs to stay visible. 
 * The most natural such object is a scroll view, namely the first one encountered when climbing up the view hierarchy.
 */
@property (nonatomic, assign) UIScrollView *scrollView;

@end

@implementation HLSTextField

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc
{
    self.scrollView = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize scrollView = m_scrollView;

#pragma mark Focus events

- (BOOL)becomeFirstResponder
{
    if (! [super becomeFirstResponder]) {
        return NO;
    }
    
    // If scroll view already moved to display the keyboard, nothing to do
    if (self.scrollView) {
        return YES;
    }
    
    // Look for the first encountered scroll view up the view hierarchy
    UIView *parentView = [self superview];
    while (parentView) {
        if ([parentView isKindOfClass:[UIScrollView class]]) {            
            self.scrollView = (UIScrollView *)parentView;
            
            // Scroll so that the view becomes visible (if hidden from view, e.g. when tabbing); could lead
            // to a motion in both x and y directions
            CGRect frameInScrollView = [self convertRect:self.bounds toView:self.scrollView];
            [self.scrollView scrollRectToVisible:frameInScrollView animated:YES];
            
            // Get the new view frame
            CGRect newFrameInScrollView = [self convertRect:self.bounds toView:self.scrollView];
            
            // Convert them in the window coordinate system
            CGRect newFrameInWindow = [self.scrollView convertRect:newFrameInScrollView toView:nil];
            
            // Screen size
            CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
            
            // If covered up by the keyboard, scroll again
            CGFloat deltaY = newFrameInWindow.origin.y + newFrameInWindow.size.height - applicationFrame.size.height + KEYBOARD_RESERVED_HEIGHT;
            if (floatge(deltaY, 0)) {
                // No animation, otherwise incorrect behavior (may offsetting too much when tabbing between fields)
                m_deltaY = deltaY;
                CGPoint scrollViewOffset = self.scrollView.contentOffset;
                [self.scrollView setContentOffset:CGPointMake(scrollViewOffset.x,
                                                              scrollViewOffset.y + m_deltaY) 
                                         animated:NO];
            }
            else {
                m_deltaY = 0.f;
            }
            
            break;
        }
        parentView = [parentView superview];
    }
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    if (! [super resignFirstResponder]) {
        return NO;
    }
    
    // No animation, otherwise incorrect behavior (may offsetting too much when tabbing between fields)
    CGPoint scrollViewOffset = self.scrollView.contentOffset;
    [self.scrollView setContentOffset:CGPointMake(scrollViewOffset.x, 
                                                  scrollViewOffset.y - m_deltaY) 
                             animated:NO];
    
    // No more scroll view moved
    self.scrollView = nil;
    
    return YES;
}

@end
