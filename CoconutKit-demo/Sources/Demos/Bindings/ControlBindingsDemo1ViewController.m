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

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSString *text;

@end

@implementation ControlBindingsDemo1ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.switchEnabled = @YES;
        self.category = @1;
        self.completion = @60.f;
        self.text = @"Hello, World!";
    }
    return self;
}

#pragma mark Transformers

- (HLSBlockTransformer *)percentTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return @([number floatValue] / 100.f);
    } reverseBlock:nil];
}

- (HLSBlockTransformer *)statusTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *statusNumber) {
        return [statusNumber boolValue] ? @"ON" : @"OFF";
    } reverseBlock:nil];
}

- (HLSBlockTransformer *)greetingsTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^id(NSString *name) {
        return [NSString stringWithFormat:NSLocalizedString(@"Hello, %@!", nil), ([name length] != 0) ? name : NSLocalizedString(@"John Doe", nil)];
    } reverseBlock:nil];
}

- (HLSBlockTransformer *)ageEvaluationTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *ageNumber) {
        NSInteger age = [ageNumber integerValue];
        if (age <= 0) {
            return NSLocalizedString(@"You are not even born!", nil);
        }
        else if (age < 20) {
            return NSLocalizedString(@"You are young", nil);
        }
        else if (age < 65) {
            return NSLocalizedString(@"You are an adult", nil);
        }
        else {
            return NSLocalizedString(@"You are old", nil);
        }
    } reverseBlock:nil];
}

- (HLSBlockTransformer *)wordCounterTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSString *text) {
        NSArray *words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *word, NSDictionary *bindings) {
            return [word isFilled];
        }];
        NSUInteger numberOfWords = [[words filteredArrayUsingPredicate:predicate] count];
        return [NSString stringWithFormat:NSLocalizedString(@"%@ words", nil), @(numberOfWords)];
    } reverseBlock:nil];
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
    HLSLoggerInfo(@"Check did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
}

- (void)view:(UIView *)view checkDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    HLSLoggerInfo(@"Check did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

- (void)view:(UIView *)view updateDidSucceedForObject:(id)object keyPath:(NSString *)keyPath
{
    HLSLoggerInfo(@"Update did succeed for object %@ bound to view %@ with keypath %@", object, view, keyPath);
}

- (void)view:(UIView *)view updateDidFailForObject:(id)object keyPath:(NSString *)keyPath withError:(NSError *)error
{
    HLSLoggerInfo(@"Update did fail for object %@ bound to view %@ with keypath %@; reason %@", object, view, keyPath, error);
}

#pragma mark Validation

- (BOOL)validateSwitchEnabled:(NSNumber **)pSwitchEnabled error:(NSError **)pError
{
    HLSLoggerInfo(@"Called switch validation method");
    return YES;
}

@end
