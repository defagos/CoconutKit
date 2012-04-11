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

@interface NSManagedObject_HLSValidationTestCase ()

@property (nonatomic, retain) ConcreteClassD *lockedDInstance;

@end

@implementation NSManagedObject_HLSValidationTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.lockedDInstance = nil;
    
    [super dealloc];
}

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Destroy any existing previous store
    NSString *storeFilePath = [HLSModelManager storeFilePathForModelFileName:@"CoconutKitTestData" storeDirectory:HLSApplicationLibraryDirectoryPath()];
    if (storeFilePath) {
        NSError *error = nil;
        if (! [[HLSFileManager defaultManager] removeItemAtPath:storeFilePath error:&error]) {
            HLSLoggerWarn(@"Could not remove store at path %@", storeFilePath);
        }
    }
    
    // Freshly create a test store
    HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"CoconutKitTestData"
                                                                           inBundle:nil
                                                                      configuration:nil 
                                                                     storeDirectory:HLSApplicationLibraryDirectoryPath()
                                                                            options:HLSModelManagerLightweightMigrationOptions];
    [HLSModelManager pushModelManager:modelManager];
    
    // Create an object which cannot be destroyed
    self.lockedDInstance = [ConcreteClassD insert];
    self.lockedDInstance.noValidationStringD = @"LOCKED";
    NSAssert([HLSModelManager saveCurrentModelContext:NULL], @"Failed to insert test data");
}

- (void)tearDownClass
{
    [super tearDownClass];
    
    [HLSModelManager popModelManager];
}

#pragma mark Tests

- (void)testIndividualChecks
{   
    ConcreteSubclassC *cInstance = [ConcreteSubclassC insert];
    
    // Field codeMandatoryNotEmptyStringA
    NSError *errorA1 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryNotEmptyStringA" error:&errorA1], nil);
    GHAssertTrue([errorA1 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain], nil);
    
    NSError *errorA2 = nil;
    GHAssertFalse([cInstance checkValue:@"      " forKey:@"codeMandatoryNotEmptyStringA" error:&errorA2], nil);
    GHAssertTrue([errorA2 hasCode:TestValidationIncorrectValueError withinDomain:TestValidationErrorDomain], nil);
    
    NSError *errorA3 = nil;
    GHAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"codeMandatoryNotEmptyStringA" error:&errorA3], nil);    
    GHAssertNil(errorA3, nil);
    
    // Field noValidationNumberB
    NSError *errorB1 = nil;
    GHAssertTrue([cInstance checkValue:nil forKey:@"noValidationNumberB" error:&errorB1], nil);
    GHAssertNil(errorB1, nil);
    
    NSError *errorB2 = nil;
    GHAssertTrue([cInstance checkValue:[NSNumber numberWithInt:3] forKey:@"noValidationNumberB" error:&errorB2], nil);
    GHAssertNil(errorB2, nil);
    
    // Field codeMandatoryNumberB
    NSError *errorB3 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryNumberB" error:&errorB3], nil);
    GHAssertTrue([errorB3 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain], nil);
    
    NSError *errorB4 = nil;
    GHAssertTrue([cInstance checkValue:[NSNumber numberWithInt:7] forKey:@"codeMandatoryNumberB" error:&errorB4], nil);
    GHAssertNil(errorB4, nil);
    
    // Field modelMandatoryBoundedNumberB
    NSError *errorB5 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryBoundedNumberB" error:&errorB5], nil);
    GHAssertTrue([errorB5 hasCode:NSValidationMissingMandatoryPropertyError withinDomain:NSCocoaErrorDomain], nil);

    NSError *errorB6 = nil;
    GHAssertFalse([cInstance checkValue:[NSNumber numberWithInt:11] forKey:@"modelMandatoryBoundedNumberB" error:&errorB6], nil);
    GHAssertTrue([errorB6 hasCode:NSValidationNumberTooLargeError withinDomain:NSCocoaErrorDomain], nil);

    // TODO: Strange... When a lower bound is set in the xcdatamodel, testing against a smaller value does not fail, though it should (if we do the
    //       same with a value that exceeds the upper bound we also have set, it works, see the corresponding test above. Is this a bug in the Core 
    //       Data framework?  It seems to be an Xcode bug (set a minimum value, save the project, close and reopen Xcode; the settings have disappeared)
#if 0
    NSError *errorB7 = nil;
    GHAssertFalse([cInstance checkValue:[NSNumber numberWithInt:2] forKey:@"modelMandatoryBoundedNumberB" error:&errorB7], nil);
    GHAssertTrue([errorB7 hasCode:NSValidationNumberTooSmallError withinDomain:NSCocoaErrorDomain], nil);
#endif
    
    NSError *errorB8 = nil;
    GHAssertTrue([cInstance checkValue:[NSNumber numberWithInt:10] forKey:@"modelMandatoryBoundedNumberB" error:&errorB8], nil);
    GHAssertNil(errorB8, nil);
    
    NSError *errorB9 = nil;
    GHAssertTrue([cInstance checkValue:[NSNumber numberWithInt:3] forKey:@"modelMandatoryBoundedNumberB" error:&errorB9], nil);
    GHAssertNil(errorB9, nil);
    
    // Field modelMandatoryCodeNotZeroNumberB
    // TODO: Both the xcdatamodel validation and the manually written validation are triggered. We get
    //       a multiple error with two embedded errors. Document: It appears that the custom validate... method
    //       is called before the inner xcdatamodel validations (or at least the xcdatamodel error is bundled
    //       with the custom validation method error after this custom method has been executed)
    NSError *errorB10 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB10], nil);
    GHAssertTrue([errorB10 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain], nil);
    NSArray *subErrorsB10 = [[errorB10 userInfo] objectForKey:NSDetailedErrorsKey];
    GHAssertEquals([subErrorsB10 count], 2U, nil);
    
    NSError *errorB11 = nil;
    GHAssertFalse([cInstance checkValue:[NSNumber numberWithInt:0] forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB11], nil);
    GHAssertTrue([errorB11 hasCode:TestValidationIncorrectValueError withinDomain:TestValidationErrorDomain], nil);
    
    NSError *errorB12 = nil;
    GHAssertTrue([cInstance checkValue:[NSNumber numberWithInt:9] forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB12], nil);
    GHAssertNil(errorB12, nil);
    
    // Field codeMandatoryConcreteClassesD
    NSError *errorB13 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryConcreteClassesD" error:&errorB13], nil);
    GHAssertTrue([errorB13 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain], nil);
    
    // Field noValidationStringC
    NSError *errorC1 = nil;
    GHAssertTrue([cInstance checkValue:nil forKey:@"noValidationStringC" error:&errorC1], nil);
    GHAssertNil(errorC1, nil);
    
    NSError *errorC2 = nil;
    GHAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"noValidationStringC" error:&errorC2], nil);
    GHAssertNil(errorC2, nil);
    
    // Field codeMandatoryStringC
    NSError *errorC3 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryStringC" error:&errorC3], nil);
    GHAssertTrue([errorC3 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain], nil);
    
    NSError *errorC4 = nil;
    GHAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"codeMandatoryStringC" error:&errorC4], nil);
    GHAssertNil(errorC4, nil);
    
    // Field modelMandatoryBoundedPatternStringC (pattern regex: ^H.*!$)
    NSError *errorC5 = nil;
    GHAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC5], nil);
    GHAssertTrue([errorC5 hasCode:NSValidationMissingMandatoryPropertyError withinDomain:NSCocoaErrorDomain], nil);
    
    // TODO: Document this Core Data behavior: When a validation defined in the xcdatamodel fails (and there are several of them),
    //       the corresponding errors ARE chained, the validation does not stop after the first condition fails (except if the
    //       mandatory test fails)
    NSError *errorC6 = nil;
    GHAssertFalse([cInstance checkValue:@"This string is too long" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC6], nil);
    GHAssertTrue([errorC6 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain], nil);
    NSArray *subErrorsC6 = [[errorC6 userInfo] objectForKey:NSDetailedErrorsKey];
    GHAssertEquals([subErrorsC6 count], 2U, nil);
    
    // TODO: Strange... When a lower bound is set in the xcdatamodel, testing against a smaller value does not fail, though it should (if we do the
    //       same with a value that exceeds the upper bound we also have set, it works, see the corresponding test above. Is this a bug in the Core 
    //       Data framework? It seems to be an Xcode bug (set a minimum value, save the project, close and reopen Xcode; the settings have disappeared)
#if 0
    NSError *errorC7 = nil;
    GHAssertFalse([cInstance checkValue:@"A" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC7], nil);
    GHAssertTrue([errorC7 hasCode:NSValidationStringTooShortError withinDomain:NSCocoaErrorDomain], nil);
#endif
    
    NSError *errorC8 = nil;
    GHAssertFalse([cInstance checkValue:@"Bad pattern" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC8], nil);
    GHAssertTrue([errorC8 hasCode:NSValidationStringPatternMatchingError withinDomain:NSCocoaErrorDomain], nil);
    
    NSError *errorC9 = nil;
    GHAssertTrue([cInstance checkValue:@"He!" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC9], nil);
    GHAssertNil(errorC9, nil);
    
    NSError *errorC10 = nil;
    GHAssertTrue([cInstance checkValue:@"Helloooooooooo!" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC10], nil);
    GHAssertNil(errorC10, nil);
    
    // Not testing insertion here. Rollback
    [HLSModelManager rollbackCurrentModelContext];
}

- (void)testCheck
{
    ConcreteClassD *dInstance1 = [ConcreteClassD insert];
    dInstance1.noValidationStringD = @"D1";

    ConcreteClassD *dInstance2 = [ConcreteClassD insert];
    dInstance2.noValidationStringD = @"D2";
    
    // Valid ConcreteSubclassC instance
    ConcreteSubclassC *cInstance1 = [ConcreteSubclassC insert];
    cInstance1.noValidationStringA = @"Consistency check";
    cInstance1.codeMandatoryNotEmptyStringA = @"Mandatory A";
    cInstance1.codeMandatoryNumberB = [NSNumber numberWithInteger:0];
    cInstance1.modelMandatoryBoundedNumberB = [NSNumber numberWithInteger:6];
    cInstance1.modelMandatoryCodeNotZeroNumberB = [NSNumber numberWithInteger:3];
    cInstance1.noValidationNumberB = [NSNumber numberWithInteger:-12];
    cInstance1.codeMandatoryStringC = @"Mandatory C";
    cInstance1.modelMandatoryBoundedPatternStringC = @"Hello, World!";
    cInstance1.noValidationNumberC = [NSNumber numberWithInteger:1012];
    cInstance1.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, dInstance2, nil];
    
    NSError *error1 = nil;
    GHAssertTrue([cInstance1 check:&error1], nil);
    GHAssertNil(error1, nil);

    // Invalid ConcreteSubclassC instance (1 inconsistency error only, all individual validations are successful)
    ConcreteSubclassC *cInstance2 = [ConcreteSubclassC insert];
    cInstance2.noValidationStringA = @"Consistency check";
    cInstance2.codeMandatoryNotEmptyStringA = @"Mandatory A";
    cInstance2.codeMandatoryNumberB = [NSNumber numberWithInteger:0];
    cInstance2.modelMandatoryBoundedNumberB = [NSNumber numberWithInteger:6];
    cInstance2.modelMandatoryCodeNotZeroNumberB = [NSNumber numberWithInteger:3];
    cInstance2.codeMandatoryStringC = @"Mandatory C";
    cInstance2.modelMandatoryBoundedPatternStringC = @"Hello, World!";
    cInstance2.noValidationNumberC = [NSNumber numberWithInteger:1012];
    cInstance2.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, nil];
    
    NSError *error2 = nil;
    GHAssertFalse([cInstance2 check:&error2], nil);
    GHAssertTrue([error2 hasCode:TestValidationInconsistencyError withinDomain:TestValidationErrorDomain], nil);
    
    // Invalid ConcreteSubclassC instance (5 errors: 4 invidual validation errors and 3 consistency error). Also tests
    // that the error hierarchy is correctly flattened out
    ConcreteSubclassC *cInstance3 = [ConcreteSubclassC insert];
    cInstance3.noValidationStringA = @"Unexpected string for consistency check";
    cInstance3.codeMandatoryNotEmptyStringA = nil;               // <-- 1 individual error
    cInstance3.codeMandatoryNumberB = [NSNumber numberWithInteger:0];
    cInstance3.modelMandatoryBoundedNumberB = [NSNumber numberWithInteger:6];
    cInstance3.modelMandatoryCodeNotZeroNumberB = [NSNumber numberWithInteger:0];       // <-- 1 individual error
    cInstance3.codeMandatoryStringC = @"Mandatory C";
    cInstance3.modelMandatoryBoundedPatternStringC = @"This string is too long, and does not match the expected pattern";       // <-- 2 individual errors
    cInstance3.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, dInstance2, nil];
    
    NSError *error3 = nil;
    GHAssertFalse([cInstance3 check:&error3], nil);
    GHAssertTrue([error3 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain], nil);
    NSArray *subErrors3 = [[error3 userInfo] objectForKey:NSDetailedErrorsKey];
    GHAssertEquals([subErrors3 count], 7U, nil);
    
    // Not testing insertion here. Rollback
    [HLSModelManager rollbackCurrentModelContext];
}

- (void)testDelete
{    
    [HLSModelManager deleteObjectFromCurrentModelContext:self.lockedDInstance];
    
    NSError *error = nil;
    GHAssertFalse([HLSModelManager saveCurrentModelContext:&error], nil);
    GHAssertTrue([error hasCode:TestValidationLockedObjectError withinDomain:TestValidationErrorDomain], nil);
    [HLSModelManager rollbackCurrentModelContext];
}

@end
