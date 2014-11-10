//
//  BindingsControlsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "BindingsControlsDemoViewController.h"

#import "DemoTransformer.h"
#import "Employee.h"

@interface BindingsControlsDemoViewController ()

@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) Employee *randomEmployee;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign, getter=isSwitchEnabled) BOOL switchEnabled;

@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) float completion;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSDateFormatter *localizedDateFormatter;

@end

@implementation BindingsControlsDemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        Employee *employee1 = [[Employee alloc] init];
        employee1.fullName = @"Jack Bauer";
        employee1.age = @40;
        
        Employee *employee2 = [[Employee alloc] init];
        employee2.fullName = @"Tony Soprano";
        employee2.age = @46;
        
        Employee *employee3 = [[Employee alloc] init];
        employee3.fullName = @"Walter White";
        employee3.age = @52;
        
        self.employees = @[employee1, employee2, employee3];
        self.randomEmployee = [self.employees objectAtIndex:arc4random_uniform((u_int32_t)[self.employees count])];
        
        self.currentDate = [NSDate date];
        
        self.switchEnabled = YES;
        self.category = 1;
        self.completion = 60.f;
        self.text = @"Hello, World!";
        
        self.page = 3;
        self.date = [NSDate dateWithTimeIntervalSince1970:0.];
    }
    return self;
}

- (void)dealloc
{
    // Invalidate the timer
    self.timer = nil;
}

#pragma mark Accessors and mutators

- (NSString *)entryDateString
{
    return [[DemoTransformer mediumDateFormatter] stringFromDate:[NSDate date]];
}

#pragma mark Accessors and mutators

- (UIImage *)apple1Image
{
    return [UIImage imageNamed:@"img_apple1.jpg"];
}

- (NSString *)apple2ImageName
{
    return @"img_apple2.jpg";
}

- (NSString *)apple3ImagePath
{
    return [[NSBundle mainBundle] pathForResource:@"img_apple3" ofType:@"jpg"];
}

- (void)setTimer:(NSTimer *)timer
{
    if (_timer) {
        [_timer invalidate];
    }
    
    _timer = timer;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    
    // Force an initial refresh
    [self.timer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.timer = nil;
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
    
    NSDateFormatter *localizedDateFormatter = [[NSDateFormatter alloc] init];
    [localizedDateFormatter setDateFormat:NSLocalizedString(@"yyyy/MM/dd", nil)];
    
    // Changing the date formatter object automatically triggers a bound view update
    self.localizedDateFormatter = localizedDateFormatter;
}

#pragma mark Transformers

- (NSFormatter *)mediumDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

- (HLSBlockTransformer *)stringArrayToStringFormatter
{
    static dispatch_once_t s_onceToken;
    static HLSBlockTransformer *s_transformer;
    dispatch_once(&s_onceToken, ^{
        s_transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSArray *array) {
            return [array componentsJoinedByString:@", "];
        } reverseBlock:nil];
    });
    return s_transformer;
}

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

#pragma mark Timer callbacks

- (void)tick:(NSTimer *)timer
{
    self.currentDate = [NSDate date];
}

@end
