//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsControlsDemoViewController.h"

#import "DemoTransformer.h"
#import "Employee.h"
#import "UppercaseValueTransformer.h"

@interface BindingsControlsDemoViewController ()

@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) Employee *randomEmployee;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimer *timer;

// Custom getter / setter names, not necessarily those expected according to KVC conventions
@property (nonatomic, assign, getter=isThisSwitchEnabled, setter=setThisSwitchEnabled:) BOOL switchEnabled;

@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) float completion;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSDateFormatter *localizedDateFormatter;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet HLSCursor *cursor;

@property (nonatomic, readonly, strong) UIImage *apple1Image;

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

- (NSURL *)apple4ImageFileURL
{
    return [[NSBundle mainBundle] URLForResource:@"img_apple4" withExtension:@"jpg"];
}

- (void)setTimer:(NSTimer *)timer
{
    if (_timer) {
        [_timer invalidate];
    }
    
    _timer = timer;
}

- (NSNumber *)answerToEverything
{
    return @42;
}

- (NSString *)hello
{
    return @"Hello, world!";
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
    self.scrollView.canCancelContentTouches = NO;
    
    self.cursor.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    
    // Force an initial refresh
    [self.timer fire];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
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
    
    // Ensure that all displayed values are correctly localized
    [self updateBoundViewHierarchy];
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

- (NSNumberFormatter *)decimalNumberFormatter
{
    return [DemoTransformer decimalNumberFormatter];
}

- (NSValueTransformer *)uppercaseValueTransformer
{
    return [[UppercaseValueTransformer alloc] init];
}

#pragma mark HLSCursorDataSource protocol implementation

- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor
{
    return 8;
}

- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index
{
    return [@(index) stringValue];
}

#pragma mark HLSViewBindingDelegate protocol implementation

- (void)boundView:(UIView *)boundView checkDidSucceedWithObject:(id)object
{
    HLSLoggerInfo(@"Check did succeed for object %@ bound to view %@ with keypath %@", object, boundView, boundView.bindKeyPath);
}

- (void)boundView:(UIView *)boundView checkDidFailWithObject:(id)object error:(NSError *)error
{
    HLSLoggerInfo(@"Check did fail for object %@ bound to view %@ with keypath %@; reason %@", object, boundView, boundView.bindKeyPath, error);
}

- (void)boundView:(UIView *)boundView updateDidSucceedWithObject:(id)object
{
    HLSLoggerInfo(@"Update did succeed for object %@ bound to view %@ with keypath %@", object, boundView, boundView.bindKeyPath);
}

- (void)boundView:(UIView *)boundView updateDidFailWithObject:(id)object error:(NSError *)error
{
    HLSLoggerInfo(@"Update did fail for object %@ bound to view %@ with keypath %@; reason %@", object, boundView, boundView.bindKeyPath, error);
}

#pragma mark Validation

- (BOOL)validateSwitchEnabled:(NSNumber *__autoreleasing *)pSwitchEnabled error:(NSError *__autoreleasing *)pError
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
