//
//  HLSActionSheet.m
//  CoconutKit
//
//  Created by Samuel Défago on 24.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSActionSheet.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"

// Only one action sheet can be opened and one dismissed at any time. More would be possible programmatically, but incorrect. These special cases are 
// ignored for simplicity, they should never occur in practice
static HLSActionSheet *s_currentActionSheet = nil;                  // weak ref to the currently opened sheet, one at most (no need to retain; action 
                                                                    // sheet ownership is automatically managed behind the scenes)
static HLSActionSheet *s_previousActionSheet = nil;                 // weak ref to action sheet which is being dismissed

@interface HLSActionSheet () <UIActionSheetDelegate>

+ (HLSActionSheet *)currentActionSheet;
+ (void)dismissCurrentActionSheetAnimated:(BOOL)animated;

@property (nonatomic, retain) NSArray *targets;
@property (nonatomic, retain) NSArray *actions;
@property (nonatomic, assign) id<UIActionSheetDelegate> realDelegate;

@end

/**
 * All possible use cases to test are listed below:
 *   1) Open an action sheet, tap outside it (if it was open from a bar button item, tap outside the toolbar containing it). This must dismiss
 *      the action sheet
 *   2) Open an action sheet from a toolbar button, then click on the button again. This must dismiss the action sheet
 *   3) Open an action sheet from a toolbar button, then click on another button in the same toolbar. This must dismiss the action sheet and
 *      trigger the action associated with the second button (e.g. open another action sheet!)
 *   4) Open an action sheet, then open another one from one of its buttons. Test the 1) to 3) cases above with this new action sheet, they
 *      should exhibit the same behavior
 */
@implementation HLSActionSheet

#pragma mark Class methods

+ (void)initialize
{
    if (self != [HLSActionSheet class]) {
        return;
    }
    
    NSAssert([self implementsProtocol:@protocol(UIActionSheetDelegate)], @"Incomplete implementation");
}

#pragma mark Managing the current action sheet

+ (HLSActionSheet *)currentActionSheet
{
    return s_currentActionSheet;
}

+ (void)dismissCurrentActionSheetAnimated:(BOOL)animated
{
    // This triggers actionSheet:willDismissWithButtonIndex:. The actionSheet:didDismissWithButtonIndex: method is
    // triggered by this method too if animated = NO. If animated = NO, it will be triggered when the animation ends
    [s_currentActionSheet dismissWithClickedButtonIndex:s_currentActionSheet.cancelButtonIndex animated:animated];
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.targets = [NSArray array];
        self.actions = [NSArray array];
        super.delegate = self;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title 
           delegate:(id<UIActionSheetDelegate>)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle 
destructiveButtonTitle:(NSString *)destructiveButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... 
{
    HLSLoggerError(@"Use the init method to initialize your action sheet");
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.targets = nil;
    self.actions = nil;
    self.realDelegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

- (NSInteger)addCancelButtonWithTitle:(NSString *)cancelButtonTitle 
                               target:(id)target
                               action:(SEL)action
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        HLSLoggerError(@"Cancel button cannot be added to an iPad application");
        return -1;
    }
    
    if (super.cancelButtonIndex != -1) {
        HLSLoggerWarn(@"Cancel button already added");
        return super.cancelButtonIndex;
    }
    
    NSInteger cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle 
                                                    target:target
                                                    action:action];
    super.cancelButtonIndex = cancelButtonIndex;
    
    return cancelButtonIndex;
}

- (NSInteger)addDestructiveButtonWithTitle:(NSString *)destructiveButtonTitle 
                                    target:(id)target
                                    action:(SEL)action
{
    if (super.destructiveButtonIndex != -1) {
        HLSLoggerWarn(@"Destructive button already added");
        return super.destructiveButtonIndex;
    }    
    
    NSInteger destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle 
                                                         target:target 
                                                         action:action];
    super.destructiveButtonIndex = destructiveButtonIndex;
    
    return destructiveButtonIndex;
}

- (NSInteger)addButtonWithTitle:(NSString *)title
                         target:(id)target
                         action:(SEL)action
{
    self.targets = [self.targets arrayByAddingObject:[NSValue valueWithPointer:target]];
    self.actions = [self.actions arrayByAddingObject:[NSValue valueWithPointer:action]];
    return [super addButtonWithTitle:title];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return [self addButtonWithTitle:title target:nil action:NULL];
}

- (id<UIActionSheetDelegate>)delegate
{
    return self.realDelegate;
}

- (void)setDelegate:(id<UIActionSheetDelegate>)delegate
{
    self.realDelegate = delegate;
}

@synthesize targets = m_targets;

@synthesize actions = m_actions;

@synthesize realDelegate = m_realDelegate;

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex
{
    HLSLoggerError(@"Use addCancelButtonWithTitle:withTarget:action to set the cancel button");
}

- (void)setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex
{
    HLSLoggerError(@"Use addDestructiveButtonWithTitle:withTarget:action to set the cancel button");
}

#pragma mark UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != -1) {
        id target = [[self.targets objectAtIndex:buttonIndex] pointerValue];
        SEL action = [[self.actions objectAtIndex:buttonIndex] pointerValue];
        
        // Support both selectors of the form - (void)action:(id)sender and - (void)action
        if (action) {
            [target performSelector:action withObject:self];
        }
    }
    
    if ([self.realDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if ([self.realDelegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.realDelegate actionSheetCancel:actionSheet];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    s_previousActionSheet = s_currentActionSheet;
    s_currentActionSheet = self;
    
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.realDelegate willPresentActionSheet:actionSheet];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if ([self.realDelegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.realDelegate didPresentActionSheet:actionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{    
    if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
        [self.realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }
    
    if (s_currentActionSheet == self) {
        s_currentActionSheet = nil;
    }
    else {
        s_previousActionSheet = nil;
    }
}

@end
