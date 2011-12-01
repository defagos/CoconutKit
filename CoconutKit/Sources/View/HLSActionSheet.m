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

// Only one action sheet can be opened at a time. Remember it here
static HLSActionSheet *s_actionSheet = nil;                 // strong ref

// Variables used to fix UIActionShet behavior when shown from a bar button. See .h documentation
static UIBarButtonItem *s_barButtonItem = nil;              // strong ref
static id s_barButtonItemTarget = nil;                      // weak ref
static SEL s_barButtonItemAction = NULL;
static BOOL s_barButtonItemShowAnimated = NO;

@interface HLSActionSheet () <UIActionSheetDelegate>

@property (nonatomic, retain) NSArray *targets;
@property (nonatomic, retain) NSArray *actions;
@property (nonatomic, assign) id<UIActionSheetDelegate> realDelegate;

- (void)replaceBehaviorForBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;
- (void)restoreBehaviorOfBarButtonItem;

- (void)dismissActionSheetForBarButtonItem:(id)sender;

@end

@implementation HLSActionSheet

#pragma mark Class methods

+ (void)initialize
{
    if (self != [HLSActionSheet class]) {
        return;
    }
    
    NSAssert([self implementsProtocol:@protocol(UIActionSheetDelegate)], @"Incomplete implementation");
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

#pragma mark Showing the action sheet

- (void)showFromToolbar:(UIToolbar *)toolbar
{
    // If an action sheet was visible, dismiss it first
    [s_actionSheet dismissWithClickedButtonIndex:s_actionSheet.cancelButtonIndex animated:NO]; 
    [s_actionSheet release];
    s_actionSheet = [self retain];
    [super showFromToolbar:toolbar];
}

- (void)showFromTabBar:(UITabBar *)tabBar
{
    // If an action sheet was visible, dismiss it first
    [s_actionSheet dismissWithClickedButtonIndex:s_actionSheet.cancelButtonIndex animated:NO]; 
    [s_actionSheet release];
    s_actionSheet = [self retain];
    [super showFromTabBar:tabBar];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{
    // If an action sheet was visible, dismiss it first
    [s_actionSheet dismissWithClickedButtonIndex:s_actionSheet.cancelButtonIndex animated:NO];
    
    // Replace bar button item actions. This way we can trigger a close if the same button is tapped again
    [self replaceBehaviorForBarButtonItem:barButtonItem animated:animated];
    
    [s_actionSheet release];
    s_actionSheet = [self retain];
    [super showFromBarButtonItem:barButtonItem animated:animated];    
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    // If an action sheet was visible, dismiss it first
    [s_actionSheet dismissWithClickedButtonIndex:s_actionSheet.cancelButtonIndex animated:NO];
    [s_actionSheet release];
    s_actionSheet = [self retain];
    [super showFromRect:rect inView:view animated:animated];
}

- (void)showInView:(UIView *)view
{
    // If an action sheet was visible, dismiss it first
    [s_actionSheet dismissWithClickedButtonIndex:s_actionSheet.cancelButtonIndex animated:NO]; 
    [s_actionSheet release];
    s_actionSheet = [self retain];
    [super showInView:view];
}

#pragma mark Fixing special case of bar button items

- (void)replaceBehaviorForBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{
    if (s_barButtonItem) {
        HLSLoggerWarn(@"A button behavior has already been replaced");
        return;
    }
    
    s_barButtonItem = [barButtonItem retain];
    s_barButtonItemTarget = barButtonItem.target;
    s_barButtonItemAction = barButtonItem.action;
    s_barButtonItemShowAnimated = animated;
    
    s_barButtonItem.target = self;
    s_barButtonItem.action = @selector(dismissActionSheetForBarButtonItem:);
}

- (void)restoreBehaviorOfBarButtonItem
{
    if (! s_barButtonItem) {
        return;
    }
    
    s_barButtonItem.target = s_barButtonItemTarget;
    s_barButtonItem.action = s_barButtonItemAction;
    s_barButtonItemShowAnimated = NO;
    
    [s_barButtonItem release];
    s_barButtonItem = nil;
}

#pragma mark UIActionSheetDelegate protocol implementation

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != -1) {
        id target = [[self.targets objectAtIndex:buttonIndex] pointerValue];
        SEL action = [[self.actions objectAtIndex:buttonIndex] pointerValue];
        
        if ([target respondsToSelector:action]) {
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
    
    // Pop-up dismissed. If it was presented by a bar button item, this is not the case anymore. Restore
    // original behavior
    [self restoreBehaviorOfBarButtonItem];
    
    [s_actionSheet release];
    s_actionSheet = nil;
}

#pragma mark Action callbacks

- (void)dismissActionSheetForBarButtonItem:(id)sender
{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:s_barButtonItemShowAnimated];
}

@end
