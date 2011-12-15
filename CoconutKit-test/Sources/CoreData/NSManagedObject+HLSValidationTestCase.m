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
}

@end
