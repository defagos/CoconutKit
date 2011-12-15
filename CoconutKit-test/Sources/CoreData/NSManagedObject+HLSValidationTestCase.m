//
//  NSManagedObject+HLSValidationTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 10.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSManagedObject+HLSValidationTestCase.h"

#import "AbstractClassA.h"
#import "ConcreteClassD.h"
#import "ConcreteSubclassB.h"
#import "ConcreteSubclassC.h"
#import "ConcreteClassD.h"
#import "TestErrors.h"

@implementation NSManagedObject_HLSValidationTestCase

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Destroy any existing previous store and create a new empty one
    NSString *libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    HLSModelManager *modelManager = [[[HLSModelManager alloc] initWithModelFileName:@"CoconutKitTestData"
                                                                     storeDirectory:libraryDirectoryPath 
                                                                              reuse:NO] 
                                     autorelease];
    [HLSModelManager setDefaultModelManager:modelManager];    
}

- (void)tearDownClass
{
    [super tearDownClass];
    
    [HLSModelManager setDefaultModelManager:nil];
}

#pragma mark Tests

- (void)testIndividualChecks
{   
    ConcreteSubclassB *bInstance = [ConcreteSubclassB insert];
    
    // Field noValidationNumberB
    NSError *errorB1 = nil;
    GHAssertTrue([bInstance checkValue:nil forKey:@"noValidationNumberB" error:&errorB1], @"Incorrect validation");
    GHAssertNil(errorB1, @"Error incorrectly returned");
    
    NSError *errorB2 = nil;
    GHAssertTrue([bInstance checkValue:[NSNumber numberWithInt:3] forKey:@"noValidationNumberB" error:&errorB2], @"Incorrect validation");
    GHAssertNil(errorB2, @"Error incorrectly returned");
    
    // Field codeMandatoryNumberB
    NSError *errorB3 = nil;
    GHAssertFalse([bInstance checkValue:nil forKey:@"codeMandatoryNumberB" error:&errorB3], @"Incorrect validation");
    GHAssertEquals([errorB3 code], TestValidationMandatoryValueError, @"Incorrect error code");
    
    NSError *errorB4 = nil;
    GHAssertTrue([bInstance checkValue:[NSNumber numberWithInt:7] forKey:@"codeMandatoryNumberB" error:&errorB4], @"Incorrect validation");
    GHAssertNil(errorB4, @"Error incorrectly returned");
    
    // Field modelMandatoryBoundedNumberB
    NSError *errorB5 = nil;
    GHAssertFalse([bInstance checkValue:nil forKey:@"modelMandatoryBoundedNumberB" error:&errorB5], @"Incorrect validation");
    GHAssertEquals([errorB5 code], NSValidationMissingMandatoryPropertyError, @"Incorrect error code");

    NSError *errorB6 = nil;
    GHAssertFalse([bInstance checkValue:[NSNumber numberWithInt:11] forKey:@"modelMandatoryBoundedNumberB" error:&errorB6], @"Incorrect validation");
    GHAssertEquals([errorB6 code], NSValidationNumberTooLargeError, @"Incorrect error code");

    // TODO: Strange... When a lower bound is set in the xcdatamodel, testing against a smaller value does not fail, though it should (if we do the
    //       same with a value that exceeds the upper bound we also have set, it works, see the corresponding test above. Is this a bug in the Core 
    //       Data framework?
#if 0
    NSError *errorB7 = nil;
    GHAssertFalse([bInstance checkValue:[NSNumber numberWithInt:2] forKey:@"modelMandatoryBoundedNumberB" error:&errorB7], @"Incorrect validation");
    GHAssertEquals([errorB7 code], NSValidationNumberTooSmallError, @"Incorrect error code");
#endif
    
    NSError *errorB8 = nil;
    GHAssertTrue([bInstance checkValue:[NSNumber numberWithInt:10] forKey:@"modelMandatoryBoundedNumberB" error:&errorB8], @"Incorrect validation");
    GHAssertNil(errorB8, @"Error incorrectly returned");
    
    NSError *errorB9 = nil;
    GHAssertTrue([bInstance checkValue:[NSNumber numberWithInt:3] forKey:@"modelMandatoryBoundedNumberB" error:&errorB9], @"Incorrect validation");
    GHAssertNil(errorB9, @"Error incorrectly returned");
    
    // Field modelMandatoryCodeNotZeroNumberB
    // TODO: Both the xcdatamodel validation and the manually written validation are triggered. We get
    //       a multiple error with two embedded errors. Document: It appears that the custom validate... method
    //       is called before the inner xcdatamodel validations (or at least the xcdatamodel error is bundled
    //       with the custom validation method error after this custom method has been executed)
    NSError *errorB10 = nil;
    GHAssertFalse([bInstance checkValue:nil forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB10], @"Incorrect validation");
    GHAssertEquals([errorB10 code], NSValidationMultipleErrorsError, @"Incorrect error code");
    NSArray *subErrorsB10 = [[errorB10 userInfo] objectForKey:NSDetailedErrorsKey];
    GHAssertEquals([subErrorsB10 count], 2U, @"Incorrect number of sub-errors");
    NSError *subErrorB10_1 = [subErrorsB10 firstObject];
    NSError *subErrorB10_2 = [subErrorsB10 objectAtIndex:1];
    GHAssertTrue(([subErrorB10_1 code] == NSValidationMissingMandatoryPropertyError && [subErrorB10_2 code] == TestValidationIncorrectValueError)
                 || ([subErrorB10_1 code] == TestValidationIncorrectValueError && [subErrorB10_2 code] == NSValidationMissingMandatoryPropertyError), 
                 @"Incorrect error codes");
    
    NSError *errorB11 = nil;
    GHAssertFalse([bInstance checkValue:[NSNumber numberWithInt:0] forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB11], @"Incorrect validation");
    GHAssertEquals([errorB11 code], TestValidationIncorrectValueError, @"Incorrect error code");
    
    NSError *errorB12 = nil;
    GHAssertTrue([bInstance checkValue:[NSNumber numberWithInt:9] forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB12], @"Incorrect validation");
    GHAssertNil(errorB12, @"Error incorrectly returned");
}

@end
