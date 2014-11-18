//
//  HLSTransformerTestCase.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 06.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSTransformerTestCase.h"

#import "UppercaseValueTransformer.h"

@implementation HLSTransformerTestCase

- (void)testOneWayBlockTransformer
{
    HLSBlockTransformer *blockTransformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return @(floorf([number floatValue]));
    } reverseBlock:nil];
    
    NSNumber *roundedNumber = [blockTransformer transformObject:@(M_PI)];
    GHAssertEqualObjects(roundedNumber, @3, nil);
    GHAssertFalse([blockTransformer respondsToSelector:@selector(getObject:fromObject:error:)], nil);
    GHAssertThrows([blockTransformer getObject:NULL fromObject:roundedNumber error:NULL], nil);
}

- (void)testTwoWayBlockTransformer
{
    static NSNumberFormatter *s_numberFormatter = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setPositiveFormat:@"###0"];
    });
    
    HLSBlockTransformer *blockTransformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
        return [s_numberFormatter stringFromNumber:number];
    } reverseBlock:^(__autoreleasing NSNumber **pNumber, NSString *string, NSError *__autoreleasing *pError) {
        NSRange range = NSMakeRange(0, [string length]);
        return [s_numberFormatter getObjectValue:pNumber forString:string range:&range error:pError];
    }];
    
    NSString *numberString = [blockTransformer transformObject:@1012];
    GHAssertEqualStrings(numberString, @"1012", nil);
    
    NSNumber *number1 = nil;
    NSError *error1 = nil;
    GHAssertTrue([blockTransformer getObject:&number1 fromObject:numberString error:&error1], nil);
    GHAssertEqualObjects(number1, @1012, nil);
    GHAssertNil(error1, nil);
    
    NSNumber *number2 = nil;
    NSError *error2 = nil;
    GHAssertFalse([blockTransformer getObject:&number2 fromObject:@"not a number" error:&error2], nil);
    GHAssertNil(number2, nil);
    GHAssertNotNil(error2, nil);
}

- (void)testBlockTransformerFromFormatter
{
    static NSNumberFormatter *s_numberFormatter = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        [s_numberFormatter setPositiveFormat:@"###0"];
    });
    
    HLSBlockTransformer *blockTransformer = [HLSBlockTransformer blockTransformerFromFormatter:s_numberFormatter];
    
    NSString *numberString = [blockTransformer transformObject:@1012];
    GHAssertEqualStrings(numberString, @"1012", nil);
    
    NSNumber *number = nil;
    NSError *error = nil;
    GHAssertTrue([blockTransformer getObject:&number fromObject:numberString error:&error], nil);
    GHAssertEqualObjects(number, @1012, nil);
    GHAssertNil(error, nil);
}

- (void)testBlockTransformerFromValueTransformer
{
    HLSBlockTransformer *blockTransformer = [HLSBlockTransformer blockTransformerFromValueTransformer:[[UppercaseValueTransformer alloc] init]];
    
    NSString *uppercaseString = [blockTransformer transformObject:@"Hello, world!"];
    GHAssertEqualStrings(uppercaseString, @"HELLO, WORLD!", nil);
    
    GHAssertFalse([blockTransformer respondsToSelector:@selector(getObject:fromObject:error:)], nil);
    GHAssertThrows([blockTransformer getObject:NULL fromObject:uppercaseString error:NULL], nil);
}

@end
