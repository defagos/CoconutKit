//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
    XCTAssertEqualObjects(roundedNumber, @3);
    XCTAssertFalse([blockTransformer respondsToSelector:@selector(getObject:fromObject:error:)]);
    XCTAssertThrows([blockTransformer getObject:NULL fromObject:roundedNumber error:NULL]);
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
    XCTAssertEqualObjects(numberString, @"1012");
    
    NSNumber *number1 = nil;
    NSError *error1 = nil;
    XCTAssertTrue([blockTransformer getObject:&number1 fromObject:numberString error:&error1]);
    XCTAssertEqualObjects(number1, @1012);
    XCTAssertNil(error1);
    
    NSNumber *number2 = nil;
    NSError *error2 = nil;
    XCTAssertFalse([blockTransformer getObject:&number2 fromObject:@"not a number" error:&error2]);
    XCTAssertNil(number2);
    XCTAssertNotNil(error2);
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
    XCTAssertEqualObjects(numberString, @"1012");
    
    NSNumber *number = nil;
    NSError *error = nil;
    XCTAssertTrue([blockTransformer getObject:&number fromObject:numberString error:&error]);
    XCTAssertEqualObjects(number, @1012);
    XCTAssertNil(error);
}

- (void)testBlockTransformerFromValueTransformer
{
    HLSBlockTransformer *blockTransformer = [HLSBlockTransformer blockTransformerFromValueTransformer:[[UppercaseValueTransformer alloc] init]];
    
    NSString *uppercaseString = [blockTransformer transformObject:@"Hello, world!"];
    XCTAssertEqualObjects(uppercaseString, @"HELLO, WORLD!");
    
    XCTAssertFalse([blockTransformer respondsToSelector:@selector(getObject:fromObject:error:)]);
    XCTAssertThrows([blockTransformer getObject:NULL fromObject:uppercaseString error:NULL]);
}

@end
