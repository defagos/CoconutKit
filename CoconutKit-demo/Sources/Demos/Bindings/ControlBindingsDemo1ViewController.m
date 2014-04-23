//
//  ControlBindingsDemo1ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "ControlBindingsDemo1ViewController.h"

@interface ControlBindingsDemo1ViewController ()

@property (nonatomic, strong) NSNumber *switchEnabled;

@end

@implementation ControlBindingsDemo1ViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.switchEnabled = @YES;
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSNumber *)completion
{
    return @60.f;
}

- (NSNumber *)completionPercentage
{
    return @0.8f;
}

- (NSNumber *)category
{
    return @1;
}

- (NSString *)name
{
    return @"CoconutKit";
}

- (NSString *)summary
{
    return @"CoconutKit is a library of high-quality iOS components written at hortis le studio and in my spare time. It includes several tools for dealing with view controllers, multi-threading, animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.";
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

- (void)view:(UIView *)view didValidateValue:(id)value forObject:(id)object keyPath:(NSString *)keyPath
{
    NSLog(@"Validate value %@ of object %@ bound to view %@ with keypath %@", value, object, view, keyPath);
}

- (void)view:(UIView *)view didFailValidationForValue:(id)value object:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    NSLog(@"Failed validation for value %@ of object %@ bound to view %@ with keypath %@; reason: %@", value, object, view, keyPath, error);
}

#pragma mark Validation

- (BOOL)validateSwitchEnabled:(NSNumber **)pSwitchEnabled error:(NSError **)pError
{
    return YES;
}

@end
