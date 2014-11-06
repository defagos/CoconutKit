//
//  LabelBindingsDemo1ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "LabelBindingsDemo1ViewController.h"

#import "DemoTransformer.h"
#import "Employee.h"

@interface LabelBindingsDemo1ViewController ()

@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) Employee *randomEmployee;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LabelBindingsDemo1ViewController

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

#pragma mark Action callbacks

- (IBAction)refresh:(id)sender
{
    [self refreshBindingsForced:NO];
}

#pragma mark Timer callbacks

- (void)tick:(NSTimer *)timer
{
    self.currentDate = [NSDate date];
}

@end
