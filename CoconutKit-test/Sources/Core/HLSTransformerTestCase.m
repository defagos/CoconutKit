//
//  HLSTransformerTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 22/03/14.
//  Copyright (c) 2014 Hortis. All rights reserved.
//

#import "HLSTransformerTestCase.h"

#import "TestErrors.h"

@interface CustomTestTransformer : NSObject <HLSTransformer>

@end

@implementation CustomTestTransformer

#pragma mark HLSTransformer protocol implementation

- (NSString *)transformObject:(NSNumber *)number
{
    return [NSString stringWithFormat:@"x = %@", number];
}

- (BOOL)getObject:(id *)pNumber fromObject:(id)fromString error:(NSError **)pError
{
    static NSNumberFormatter *s_numberFormatter;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    
    NSString *numberString = [fromString stringByReplacingOccurrencesOfString:@"x = " withString:@""];
    NSNumber *number = [s_numberFormatter numberFromString:numberString];
    if (! number) {
        HLSError *error = [HLSError errorWithDomain:TestErrorDomain
                                               code:TestErrorIncorrectValueError];
        if (pError) {
            *pError = error;
        }
        return NO;
    }
    
    if (pNumber) {
        *pNumber = number;
    }
    return YES;
}

@end

@implementation HLSTransformerTestCase

#pragma  mark Tests

- (void)testNumberFactorTransformer
{
    HLSBlockTransformer *transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return @([number doubleValue] * 2.);
    } reverseBlock:^(NSNumber **pNumber, NSNumber *fromNumber, NSError **pError) {
        NSNumber *number = @([fromNumber doubleValue] / 2.);
        if (pNumber) {
            *pNumber = number;
        }
        return YES;
    }];
    
    GHAssertEqualObjects([transformer transformObject:@10.], @20., nil);
    
    NSNumber *number = nil;
    NSError *error = nil;
    GHAssertTrue([transformer getObject:&number fromObject:@20. error:&error], nil);
    GHAssertEqualObjects(number, @10., nil);
    GHAssertNil(error, nil);
}

- (void)testNumberFormatterTransformer
{
    // This example is quite contrived. In general you should use NSNumberFormatter directly
    static NSNumberFormatter *s_numberFormatter;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    
    HLSBlockTransformer *transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return [s_numberFormatter stringFromNumber:number];
    } reverseBlock:^(NSNumber **pNumber, NSString *fromString, NSError **pError) {
        NSNumber *number = [s_numberFormatter numberFromString:fromString];
        if (! number) {
            HLSError *error = [HLSError errorWithDomain:TestErrorDomain
                                                   code:TestErrorIncorrectValueError];
            if (pError) {
                *pError = error;
            }
            return NO;
        }
        
        if (pNumber) {
            *pNumber = number;
        }
        return YES;
    }];
    
    GHAssertEqualObjects([transformer transformObject:@10.], @"10", nil);
    
    NSNumber *number = nil;
    NSError *error = nil;
    GHAssertTrue([transformer getObject:&number fromObject:@"10" error:&error], nil);
    GHAssertEqualObjects(number, @10., nil);
    GHAssertNil(error, nil);
    
    number = nil;
    error = nil;
    GHAssertFalse([transformer getObject:&number fromObject:@"incorrect input" error:&error], nil);
    GHAssertNil(number, nil);
    GHAssertNotNil(error, nil);
}

- (void)testOneWayBlockTransformer
{
    // Rounding. Loses information, therefore a reverse transformation does not make sense
    HLSBlockTransformer *transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return @(floor([number doubleValue]));
    } reverseBlock:nil];
    
    GHAssertEqualObjects([transformer transformObject:@"3.14159"], @3., nil);
    
    GHAssertFalse([transformer respondsToSelector:@selector(getObject:fromObject:error:)], nil);
    GHAssertThrows([transformer getObject:NULL fromObject:nil error:NULL], nil);
}

- (void)testCustomTransformer
{
    CustomTestTransformer *transformer = [[CustomTestTransformer alloc] init];
    
    GHAssertEqualObjects([transformer transformObject:@10.], @"x = 10", nil);
    
    NSNumber *number = nil;
    NSError *error = nil;
    GHAssertTrue([transformer getObject:&number fromObject:@"x = 10" error:&error], nil);
    GHAssertEqualObjects(number, @10, nil);
    GHAssertNil(error, nil);
    
    number = nil;
    error = nil;
    GHAssertFalse([transformer getObject:&number fromObject:@"incorrect input" error:&error], nil);
    GHAssertNil(number, nil);
    GHAssertNotNil(error, nil);
}

@end
