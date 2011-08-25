//
//  HLSActionSheet.m
//  CoconutKit
//
//  Created by Samuel Défago on 24.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSActionSheet.h"

#import "HLSAssert.h"

// TODO: When implemented, check all methods of the UIActionSheet interface

@interface HLSActionSheet () <UIActionSheetDelegate>

@property (nonatomic, retain) NSArray *targets;
@property (nonatomic, retain) NSArray *actions;
@property (nonatomic, assign) id<UIActionSheetDelegate> realDelegate;

@end

@implementation HLSActionSheet

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
    return [self addButtonWithTitle:title];
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
        
        if ([target respondsToSelector:action]) {
            [target performSelector:action withObject:self];
        }        
    }
    
    [self.realDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.realDelegate actionSheetCancel:actionSheet];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [self.realDelegate willPresentActionSheet:actionSheet];
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    [self.realDelegate didPresentActionSheet:actionSheet];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.realDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.realDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}

@end
