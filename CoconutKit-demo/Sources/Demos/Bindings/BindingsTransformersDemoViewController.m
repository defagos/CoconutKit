//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsTransformersDemoViewController.h"

#import "DemoErrors.h"
#import "DemoTransformer.h"
#import "Employee.h"

@interface BindingsTransformersDemoViewController ()

@property (nonatomic, assign) CGPoint point;

@end

@implementation BindingsTransformersDemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.point = CGPointMake(42.f, 42.f);
    }
    return self;
}

#pragma mark Accessors and mutators

- (Employee *)employee
{
    return [[Employee employees] firstObject];
}

- (NSArray *)employees
{
    return [Employee employees];
}

- (NSDate *)date
{
    return [NSDate date];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Transformers", nil);
}

#pragma mark Transformers

+ (NSDateFormatter *)classDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

- (NSDateFormatter *)instanceDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

- (HLSBlockTransformer *)pointTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSValue *pointValue) {
        return NSStringFromCGPoint([pointValue CGPointValue]);
    } reverseBlock:nil];
}

- (HLSBlockTransformer *)otherPointTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSValue *pointValue) {
        CGPoint point = [pointValue CGPointValue];
        return [NSString stringWithFormat:@"(%.0f, %.0f)", point.x, point.y];
    } reverseBlock:^(__autoreleasing NSValue **pPointValue, NSString *string, NSError *__autoreleasing *pError) {
        // Regular expression: \(\s*(.*)\s*,\s*(.*)\s*\)
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\(\\s*(.*)\\s*,\\s*(.*)\\s*\\)" options:0 error:NULL];
        
        __block BOOL found = NO;
        [regularExpression enumerateMatchesInString:string options:0 range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            static NSNumberFormatter *s_numberFormatter = nil;
            static dispatch_once_t s_onceToken;
            dispatch_once(&s_onceToken, ^{
                s_numberFormatter = [[NSNumberFormatter alloc] init];
                [s_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            });
            
            // Extract capture group information
            NSString *xString = [string substringWithRange:[result rangeAtIndex:1]];
            NSNumber *x = [s_numberFormatter numberFromString:xString];
            
            NSString *yString = [string substringWithRange:[result rangeAtIndex:2]];
            NSNumber *y = [s_numberFormatter numberFromString:yString];
            
            if (! x || ! y) {
                if (pError) {
                    *pError = [NSError errorWithDomain:DemoErrorDomain
                                                  code:DemoInputError
                                  localizedDescription:NSLocalizedString(@"Incorrect format", nil)];
                }
                return;
            }
            
            if (pPointValue) {
                *pPointValue = [NSValue valueWithCGPoint:CGPointMake([x floatValue], [y floatValue])];
            }
            
            found = YES;
        }];
        
        return found;
    }];
}

@end
