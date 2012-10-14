//
//  HLSTextField.m
//  CoconutKit
//
//  Created by Samuel Défago on 10/12/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTextField.h"

#import "HLSFloat.h"
#import "HLSKeyboardInformation.h"
#import "HLSLogger.h"
#import "HLSTextFieldTouchDetector.h"

/**
 * Test workflow:
 * --------------
 * To understand this code, create a form with at least two HLSTextFields, supporting all orientations. Then debug the 
 * code using the following test workflow (covering all possible cases). Setting a breakpoint on each method can
 * help you understand when each method gets called and why:
 *   1) With the keyboard dismissed, click on a field A (A receives becomeFirstResponder)
 *   2) Rotate the device (keyboardWillHide, then keyboardWillShow are called for A)
 *   3) Click on another field B (B receives becomeFirstResponder, which calls resignFirstResponder on A)
 *   4) Rotate the device (keyboardWillHide, then keyboardWillShow are called for B)
 *   5) Dismiss the keyboard (B receives resignFirstResponder)
 */

// The minimal distance to be kept between the active text field and the top of the scroll view top or the keyboard. If the 
// scroll view area is too small to fulfill both, visibility at the top wins
const CGFloat kTextFieldMinVisibilityDistance = 20.f;           // Corresponds to IB guides

/**
 * Keep a reference to the currently active HLSTextField (if any) and to its original offset. This is safe since UIKit 
 * is not meant to be used in multi-threaded code. Moreover, at most one text field can be active at any time, and there 
 * is no risk of dangling pointers (a -viewDidUnload, which would invalidate the ref we keep, can only appear
 * when the view is not visible, i.e. when no text field is active)
 *
 * Saving the original offset (and not the total offset which is applied) is made on purpose. Since we have very little
 * control over offset animations, offset animations which not have ended when other are started (especially when we
 * fast switch between fields in the iOS simulator). In such cases the total offset gets unreliable.
 */
static HLSTextField *s_currentTextField = nil;
static CGFloat s_originalYOffset = 0.f;

/**
 * When a text field must be made visible, we climb up the view hierarchy to find the bottommost scroll view (i.e. the 
 * one which is not contained in any other scroll view). This is the one we adjust to make the field visible. Originally
 * the nearest parent scroll view of a text field was used, but this was a bad idea (it is easier to couple scroll
 * view motions vertically if using the bottommost one)
 *
 * Remark:
 * To keep a field visible, some implementations directly move the parent view (not the content offset of a scroll view).
 * This is only possible in a view controller implementation, where the UI appearance is precisely known (since managed 
 * by the view controller). Here, to get the same behavior without a using view controller (i.e. we cannot know how the UI is
 * supposed to look, which fields are grouped, etc.), we cannot simply adjust the parent view frame. What we need is a
 * way to identify which view up the caller hierarchy can be adjusted when some of its content needs to stay visible. 
 * The most natural such object is the scroll view.
 */
static UIScrollView *s_scrollView = nil;

@interface HLSTextField ()

@property (nonatomic, retain) HLSTextFieldTouchDetector *touchDetector;

+ (void)offsetScrollForTextField:(HLSTextField *)textField animated:(BOOL)animated;
+ (void)restoreScrollAnimated:(BOOL)animated;

- (void)hlsTextFieldInit;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation HLSTextField

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsTextFieldInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self hlsTextFieldInit];
}

// Common initialization code
- (void)hlsTextFieldInit
{
    self.minVisibilityDistance = kTextFieldMinVisibilityDistance;
    
    self.touchDetector = [[[HLSTextFieldTouchDetector alloc] initWithTextField:self] autorelease];
    super.delegate = self.touchDetector;
}

- (void)dealloc
{
    self.touchDetector = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize touchDetector = m_touchDetector;

@synthesize minVisibilityDistance = m_minVisibilityDistance;

- (void)setTextFieldMinVisibilityDistance:(CGFloat)minVisibilityDistance
{
    // Sanitize input
    if (floatlt(minVisibilityDistance, 0.f)) {
        HLSLoggerWarn(@"Invalid value; must be positive");
        m_minVisibilityDistance = 0.f;
    }
    else {
        m_minVisibilityDistance = minVisibilityDistance;
    }
}

- (BOOL)resigningFirstResponderOnTap
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    return touchDetector.resigningFirstResponderOnTap;
}

- (void)setResigningFirstResponderOnTap:(BOOL)resigningFirstResponderOnTap
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    touchDetector.resigningFirstResponderOnTap = resigningFirstResponderOnTap;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    touchDetector.delegate = delegate;
}

- (id<UITextFieldDelegate>)delegate
{
    HLSTextFieldTouchDetector *touchDetector = (HLSTextFieldTouchDetector *)super.delegate;
    return touchDetector.delegate;
}

#pragma mark Focus events

- (BOOL)becomeFirstResponder
{
    // The same HLSTextField is clicked several times; nothing more to do
    if (s_currentTextField == self) {
        return [super becomeFirstResponder];        // UITextField implementation always return YES, see documentation
    }
    
    // We must update the current text field before calling becomeFirstResponder on super. The reason is that
    // when switching between text fields, the becomeFirstResponder of the new field is called, and when
    // its super becomeFirstResponder method is called, it calls the resignFirstResponder method of the old text
    // field! But in the old text field resignFirstResponder method, we want to know the identity of the new
    // field
    s_currentTextField = self;
    
    // Calling the super method first; two cases can lead to becomeFirstResponder being called:
    //   - we are entering input mode. The keyboard appears, which fires a UIKeyboardWillShowNotification during
    //     the becomeFirstResponder call. We do not want to catch such events yet (we use them to detect interface
    //     orientation changes only), we must therefore register with the notification center after the call to
    //     the super becomeFirstResponder method has returned
    //   - when clicking a text field while another one was already active, the keyboard stays visible and no
    //     keyboard events are fired. Even if a text field is registered with the notification center, the
    //     keyboardWillShow: method will not be called (which is what we want; we only want this method to be
    //     called when orientation changes)
    [super becomeFirstResponder];       // UITextField implementation always return YES, see documentation
    
    // Move the scroll view so that the field is visible (if not already)
    [HLSTextField offsetScrollForTextField:self animated:YES];    
    
    // Register for keyboard notifications so that the new responder can answer to keyboard events (the registration
    // is here carefully made so that those events always correspond to device rotation)
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil]; 
    
    return YES;
}

- (BOOL)resignFirstResponder
{
    // If no text field is currently active, nothing to do
    if (! s_currentTextField) {
        HLSLoggerDebug(@"No text field is active");
        return YES;
    }
        
    // Unregister from the notification center first; important since we only want to track rotation events
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];    
    
    // Calling the super method first; two cases can lead to resignFirstResponder being called:
    //   - we are exiting input mode. The keyboard disappears, which fires a UIKeyboardWillHideNotification during
    //     the resignFirstResponder call. We do not want to catch such events (we will use them to detect interface
    //     orientation changes only), we had therefore to unregister from the notification center before the call to
    //     the super resignFirstResponder method is made
    //   - when clicking a text field while another one was already active, the keyboard stays visible and no
    //     keyboard events are fired. Even if a text field is registered with the notification center, the
    //     keyboardWillHide: method will not be called (which is what we want; we only want this method to be
    //     called when orientation changes)
    [super resignFirstResponder];       // UITextField implementation always return YES, see documentation
    
    // The current HLSTextField is losing the focus, reset scroll view offset
    if (s_currentTextField == self) {
        [HLSTextField restoreScrollAnimated:YES];
        s_currentTextField = nil;
    }
    
    return YES;
}

#pragma mark Locating a scroll view and using it to keep the text field visible

/**
 * Make the text visible by offsetting a scroll view (if needed and if a scroll view is available)
 */
+ (void)offsetScrollForTextField:(HLSTextField *)textField animated:(BOOL)animated
{
    // Locate the bottommost scroll view containing the text field
    UIScrollView *bottomMostscrollView = nil;
    UIView *parentView = [textField superview];
    while (parentView) {
        if ([parentView isKindOfClass:[UIScrollView class]]) {    
            bottomMostscrollView = (UIScrollView *)parentView;
        }
        parentView = [parentView superview];
    }
    
    // If a different scroll view was already assigned an offset, reset it. We must offset at most one scroll 
    // view at a time, and we are done with the old one since the field we are now tracking is wrapped in 
    // another scroll view    
    if (s_scrollView != bottomMostscrollView) {
        [HLSTextField restoreScrollAnimated:YES];
        
        // Changing scroll view (or set to nil). Save the original offset to be able to restore it later
        if (bottomMostscrollView) {
            s_originalYOffset = bottomMostscrollView.contentOffset.y;
        }
        else {
            s_originalYOffset = 0.f;
        }
    }
    
    s_scrollView = bottomMostscrollView;
    
    // If no scroll view found, we are done
    if (! s_scrollView) {
        return;
    }
    
    CGPoint scrollViewOffset = s_scrollView.contentOffset;
    
    // Text field frame in the scroll view coordinate system;
    CGRect frameInScrollView = [textField convertRect:textField.bounds toView:s_scrollView];
    
    // If the text field is hidden at the top, adjust the scroll view offset to make it visible; must take
    // the current offset (if any) into account
    CGFloat yOffsetTop = frameInScrollView.origin.y - scrollViewOffset.y - textField.minVisibilityDistance;
    if (floatle(yOffsetTop, 0.f)) {
        // Move
        [s_scrollView setContentOffset:CGPointMake(scrollViewOffset.x,
                                                   scrollViewOffset.y + yOffsetTop) 
                              animated:animated];
        
        // We are done
        return;
    }
    
    // Get the keyboard frame (should be available, unless the keyboard is floating); the text field might be covered by it
    HLSKeyboardInformation *keyboardInformation = [HLSKeyboardInformation keyboardInformation];
    if (! keyboardInformation) {
        return;
    }
    
    // Work in the scroll view coordinate system
    // Remark: Initially, I intended to work in the window coordinate system, but this is a bad idea
    //         (the window coordinate system is in portrait mode, and this does not make conversion
    //         of coordinates easy for views displayed in landscape mode). But we can pick any 
    //         coordinate system (as long as all coordinates are converted back to it, of course),
    //         and the most natural is the scroll view coordinate system
    
    // Get the area covered by the keyboard in the scroll view coordinate system
    CGRect keyboardFrameInScrollView = [s_scrollView convertRect:keyboardInformation.endFrame fromView:nil];
    
    // Find if the text field is covered by the keyboard, and scroll if this is the case
    //
    //                                                  Scroll view
    //                                     +    +--------------------------+    +
    //                                     |    |                          |    |
    //      a (text field origin in scroll |    |                          |    | b (keyboard origin in scroll)
    //         view coordinate system)     |    |                          |    |    view coordinate system)
    //                                     |    |                          |    |
    //                                     |    |                          |    |
    //                                     +    |   +---------+            |    |        +
    //                                          |   |  Field  |            |    |        |   f (text field height)
    //                                          |   +---------+            |    |        +
    //                                          |                          |    |
    //                                          |                          |    |
    //                                          +--------------------------+    +
    //                                          |                          |
    //                                          |         Keyboard         |
    //                                          |                          |
    //                                          +--------------------------+
    //
    //
    // Let d be the minimal distance to be kept between text field and keyboard. Then, in order for the field to
    // be visible, we must have:
    //   a + f + d < b
    // or
    //   a + f + d - b < 0
    // Let delta := a + f + d - b, then we must shift the scroll view content offset if this condition is not satisfied,
    // i.e. when
    //   delta >= 0
    // The shift to apply is just delta
    CGFloat yOffset = frameInScrollView.origin.y + frameInScrollView.size.height + textField.minVisibilityDistance - keyboardFrameInScrollView.origin.y;
    if (floatge(yOffset, 0.f)) {
        // Move
        [s_scrollView setContentOffset:CGPointMake(scrollViewOffset.x,
                                                   scrollViewOffset.y + yOffset) 
                              animated:animated];
        
        // Done
        return;
    }
}

/**
 * Restore the scroll view offset. Must be called for the same orientation as when the makeVisible method was called,
 * otherwise the behavior is undefined
 */
+ (void)restoreScrollAnimated:(BOOL)animated
{
    // If nothing to restore, nothing to do
    if (! s_scrollView) {
        return;
    }
    
    // Restore original offset
    CGPoint scrollViewOffset = s_scrollView.contentOffset;
    [s_scrollView setContentOffset:CGPointMake(scrollViewOffset.x, 
                                               s_originalYOffset) 
                          animated:animated];
    
    // Done with the scroll view
    s_scrollView = nil;
    s_originalYOffset = 0.f;
}

#pragma mark Notification callbacks

/**
 * Extremely important: When rotating the interface with the keyboard enabled, the willShow event is fired after the new
 * orientation has been installed, i.e. coordinates are relative to the new orientation
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    [HLSTextField offsetScrollForTextField:self animated:NO];
}

/**
 * Extremely important: When rotating the interface with the keyboard enabled, the willHide event is fired before the new
 * orientation has been installed, i.e. coordinates are relative to the old orientation
 */
- (void)keyboardWillHide:(NSNotification *)notification
{
    [HLSTextField restoreScrollAnimated:NO];
}

@end
