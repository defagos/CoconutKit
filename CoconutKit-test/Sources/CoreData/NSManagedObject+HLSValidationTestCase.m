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
    
    NSError *errorB11 = nil;
    GHAssertFalse([bInstance checkValue:nil forKey:@"codeMandatoryStringA" error:&errorB11], @"Incorrect validation");
    GHAssertEquals([errorB11 code], TestValidationMandatoryValueError, @"Incorrect error code");
    
    NSError *errorB12 = nil;
    GHAssertTrue([bInstance checkValue:@"" forKey:@"codeMandatoryStringA" error:&errorB12], @"Incorrect validation");
    GHAssertNil(errorB12, @"Error incorrectly returned");
    
    NSError *errorB13 = nil;
    GHAssertTrue([bInstance checkValue:@"Hello, World!" forKey:@"codeMandatoryStringA" error:&errorB13], @"Incorrect validation");
    GHAssertNil(errorB13, @"Error incorrectly returned");
    
    NSError *errorB14 = nil;
    GHAssertFalse([bInstance checkValue:nil forKey:@"modelMandatoryCodeNotEmptyStringA" error:&errorB14], @"Incorrect validation");
    GHAssertEquals([errorB14 code], NSValidationMissingMandatoryPropertyError, @"Incorrect error code");
    
    // We were just testing insertions
    [HLSModelManager rollbackDefaultModelContext];
}

@end
