//
//  ControlBindingsDemo1ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "ControlBindingsDemo1ViewController.h"

@interface ControlBindingsDemo1ViewController ()

@property (nonatomic, strong) NSNumber *switchEnabled;

@property (nonatomic, strong) NSNumber *category;
@property (nonatomic, strong) NSNumber *completion;

@end

@implementation ControlBindingsDemo1ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.switchEnabled = @YES;
        self.category = @1;
        self.completion = @60.f;
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSNumber *)completionPercentage
{
    return @([self.completion floatValue] / 100.f);
}

- (NSString *)switchStatus
{
    return [self.switchEnabled boolValue] ? @"ON" : @"OFF";
}

- (NSString *)name
{
    return @"CoconutKit";
}

- (NSString *)summary
{
    return @"CoconutKit is a library of high-quality iOS components written in my spare time. It includes several tools for dealing with view controllers, multi-threading, animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.";
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Controls", nil);
}

#pragma mark HLSBindingDelegate protocol implementation

- (void)view:(UIView *)view checkDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    NSLog(@"Check did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
}

- (void)view:(UIView *)view checkDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    NSLog(@"Check did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

- (void)view:(UIView *)view updateDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    NSLog(@"Update did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
    
    [self refreshBindingsForced:NO];
}

- (void)view:(UIView *)view updateDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    NSLog(@"Update did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

#pragma mark Validation

- (BOOL)validateSwitchEnabled:(NSNumber **)pSwitchEnabled error:(NSError **)pError
{
    return YES;
}

@end
