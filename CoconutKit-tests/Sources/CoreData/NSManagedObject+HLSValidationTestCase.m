//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSManagedObject+HLSValidationTestCase.h"

#import "AbstractClassA.h"
#import "ConcreteClassD.h"
#import "ConcreteSubclassB.h"
#import "ConcreteSubclassC.h"
#import "ConcreteClassD.h"
#import "NSBundle+Tests.h"
#import "TestErrors.h"

HLSEnableNSManagedObjectValidation();

@interface NSManagedObject_HLSValidationTestCase ()

@property (nonatomic, strong) ConcreteClassD *lockedDInstance;

@end

@implementation NSManagedObject_HLSValidationTestCase

#pragma mark Test setup and tear down

- (void)setUp
{
    [super setUp];
    
    // Destroy any existing previous store
    NSString *storeFilePath = [HLSModelManager storeFilePathForModelFileName:@"CoconutKitTestData"
                                                              storeDirectory:HLSApplicationLibraryDirectoryPath()
                                                                 fileManager:nil];
    if (storeFilePath) {
        NSError *error = nil;
        if (! [[HLSStandardFileManager defaultManager] removeItemAtPath:storeFilePath error:&error]) {
            HLSLoggerWarn(@"Could not remove store at path %@", storeFilePath);
        }
    }
    
    // Freshly create a test store
    HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"CoconutKitTestData"
                                                                           inBundle:[NSBundle testBundle]
                                                                      configuration:nil 
                                                                     storeDirectory:HLSApplicationLibraryDirectoryPath()
                                                                        fileManager:nil
                                                                            options:HLSModelManagerLightweightMigrationOptions];
    [HLSModelManager pushModelManager:modelManager];
    
    // Create an object which cannot be destroyed
    self.lockedDInstance = [ConcreteClassD insert];
    self.lockedDInstance.noValidationStringD = @"LOCKED";
    NSAssert([HLSModelManager saveCurrentModelContext:NULL], @"Failed to insert test data");
}

- (void)tearDown
{
    [super tearDown];
    
    [HLSModelManager popModelManager];
}

#pragma mark Tests

- (void)testIndividualChecks
{   
    ConcreteSubclassC *cInstance = [ConcreteSubclassC insert];
    
    // Field codeMandatoryNotEmptyStringA
    NSError *errorA1 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryNotEmptyStringA" error:&errorA1]);
    XCTAssertTrue([errorA1 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain]);
    
    NSError *errorA2 = nil;
    XCTAssertFalse([cInstance checkValue:@"      " forKey:@"codeMandatoryNotEmptyStringA" error:&errorA2]);
    XCTAssertTrue([errorA2 hasCode:TestValidationIncorrectValueError withinDomain:TestValidationErrorDomain]);
    
    NSError *errorA3 = nil;
    XCTAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"codeMandatoryNotEmptyStringA" error:&errorA3]);    
    XCTAssertNil(errorA3);
    
    // Field noValidationNumberB
    NSError *errorB1 = nil;
    XCTAssertTrue([cInstance checkValue:nil forKey:@"noValidationNumberB" error:&errorB1]);
    XCTAssertNil(errorB1);
    
    NSError *errorB2 = nil;
    XCTAssertTrue([cInstance checkValue:@3 forKey:@"noValidationNumberB" error:&errorB2]);
    XCTAssertNil(errorB2);
    
    // Field codeMandatoryNumberB
    NSError *errorB3 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryNumberB" error:&errorB3]);
    XCTAssertTrue([errorB3 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain]);
    
    NSError *errorB4 = nil;
    XCTAssertTrue([cInstance checkValue:@7 forKey:@"codeMandatoryNumberB" error:&errorB4]);
    XCTAssertNil(errorB4);
    
    // Field modelMandatoryBoundedNumberB
    NSError *errorB5 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryBoundedNumberB" error:&errorB5]);
    XCTAssertTrue([errorB5 hasCode:NSValidationMissingMandatoryPropertyError withinDomain:NSCocoaErrorDomain]);

    NSError *errorB6 = nil;
    XCTAssertFalse([cInstance checkValue:@11 forKey:@"modelMandatoryBoundedNumberB" error:&errorB6]);
    XCTAssertTrue([errorB6 hasCode:NSValidationNumberTooLargeError withinDomain:NSCocoaErrorDomain]);

    // TODO: Strange... When a lower bound is set in the xcdatamodel, testing against a smaller value does not fail, though it should (if we do the
    //       same with a value that exceeds the upper bound we also have set, it works, see the corresponding test above. Is this a bug in the Core 
    //       Data framework?  It seems to be an Xcode bug (set a minimum value, save the project, close and reopen Xcode; the settings have disappeared)
#if 0
    NSError *errorB7 = nil;
    XCTAssertFalse([cInstance checkValue:[NSNumber numberWithInt:2] forKey:@"modelMandatoryBoundedNumberB" error:&errorB7]);
    XCTAssertTrue([errorB7 hasCode:NSValidationNumberTooSmallError withinDomain:NSCocoaErrorDomain]);
#endif
    
    NSError *errorB8 = nil;
    XCTAssertTrue([cInstance checkValue:@10 forKey:@"modelMandatoryBoundedNumberB" error:&errorB8]);
    XCTAssertNil(errorB8);
    
    NSError *errorB9 = nil;
    XCTAssertTrue([cInstance checkValue:@3 forKey:@"modelMandatoryBoundedNumberB" error:&errorB9]);
    XCTAssertNil(errorB9);
    
    // Field modelMandatoryCodeNotZeroNumberB
    // TODO: Both the xcdatamodel validation and the manually written validation are triggered. We get
    //       a multiple error with two embedded errors. Document: It appears that the custom validate... method
    //       is called before the inner xcdatamodel validations (or at least the xcdatamodel error is bundled
    //       with the custom validation method error after this custom method has been executed)
    NSError *errorB10 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB10]);
    XCTAssertTrue([errorB10 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]);
    NSArray *subErrorsB10 = [[errorB10 userInfo] objectForKey:NSDetailedErrorsKey];
    XCTAssertEqual([subErrorsB10 count], (NSUInteger)2);
    
    NSError *errorB11 = nil;
    XCTAssertFalse([cInstance checkValue:@0 forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB11]);
    XCTAssertTrue([errorB11 hasCode:TestValidationIncorrectValueError withinDomain:TestValidationErrorDomain]);
    
    NSError *errorB12 = nil;
    XCTAssertTrue([cInstance checkValue:@9 forKey:@"modelMandatoryCodeNotZeroNumberB" error:&errorB12]);
    XCTAssertNil(errorB12);
    
    // Field codeMandatoryConcreteClassesD
    NSError *errorB13 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryConcreteClassesD" error:&errorB13]);
    XCTAssertTrue([errorB13 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain]);
    
    // Field noValidationStringC
    NSError *errorC1 = nil;
    XCTAssertTrue([cInstance checkValue:nil forKey:@"noValidationStringC" error:&errorC1]);
    XCTAssertNil(errorC1);
    
    NSError *errorC2 = nil;
    XCTAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"noValidationStringC" error:&errorC2]);
    XCTAssertNil(errorC2);
    
    // Field codeMandatoryStringC
    NSError *errorC3 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"codeMandatoryStringC" error:&errorC3]);
    XCTAssertTrue([errorC3 hasCode:TestValidationMandatoryValueError withinDomain:TestValidationErrorDomain]);
    
    NSError *errorC4 = nil;
    XCTAssertTrue([cInstance checkValue:@"Hello, World!" forKey:@"codeMandatoryStringC" error:&errorC4]);
    XCTAssertNil(errorC4);
    
    // Field modelMandatoryBoundedPatternStringC (pattern regex: ^H.*!$)
    NSError *errorC5 = nil;
    XCTAssertFalse([cInstance checkValue:nil forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC5]);
    XCTAssertTrue([errorC5 hasCode:NSValidationMissingMandatoryPropertyError withinDomain:NSCocoaErrorDomain]);
    
    // TODO: Document this Core Data behavior: When a validation defined in the xcdatamodel fails (and there are several of them),
    //       the corresponding errors ARE chained, the validation does not stop after the first condition fails (except if the
    //       mandatory test fails)
    NSError *errorC6 = nil;
    XCTAssertFalse([cInstance checkValue:@"This string is too long" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC6]);
    XCTAssertTrue([errorC6 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]);
    NSArray *subErrorsC6 = [[errorC6 userInfo] objectForKey:NSDetailedErrorsKey];
    XCTAssertEqual([subErrorsC6 count], (NSUInteger)2);
    
    // TODO: Strange... When a lower bound is set in the xcdatamodel, testing against a smaller value does not fail, though it should (if we do the
    //       same with a value that exceeds the upper bound we also have set, it works, see the corresponding test above. Is this a bug in the Core 
    //       Data framework? It seems to be an Xcode bug (set a minimum value, save the project, close and reopen Xcode; the settings have disappeared)
#if 0
    NSError *errorC7 = nil;
    XCTAssertFalse([cInstance checkValue:@"A" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC7]);
    XCTAssertTrue([errorC7 hasCode:NSValidationStringTooShortError withinDomain:NSCocoaErrorDomain]);
#endif
    
    NSError *errorC8 = nil;
    XCTAssertFalse([cInstance checkValue:@"Bad pattern" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC8]);
    XCTAssertTrue([errorC8 hasCode:NSValidationStringPatternMatchingError withinDomain:NSCocoaErrorDomain]);
    
    NSError *errorC9 = nil;
    XCTAssertTrue([cInstance checkValue:@"He!" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC9]);
    XCTAssertNil(errorC9);
    
    NSError *errorC10 = nil;
    XCTAssertTrue([cInstance checkValue:@"Helloooooooooo!" forKey:@"modelMandatoryBoundedPatternStringC" error:&errorC10]);
    XCTAssertNil(errorC10);
    
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
    cInstance1.codeMandatoryNumberB = @0;
    cInstance1.modelMandatoryBoundedNumberB = @6;
    cInstance1.modelMandatoryCodeNotZeroNumberB = @3;
    cInstance1.noValidationNumberB = @-12;
    cInstance1.codeMandatoryStringC = @"Mandatory C";
    cInstance1.modelMandatoryBoundedPatternStringC = @"Hello, World!";
    cInstance1.noValidationNumberC = @1012;
    cInstance1.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, dInstance2, nil];
    
    NSError *error1 = nil;
    XCTAssertTrue([cInstance1 check:&error1]);
    XCTAssertNil(error1);

    // Invalid ConcreteSubclassC instance (1 inconsistency error only, all individual validations are successful)
    ConcreteSubclassC *cInstance2 = [ConcreteSubclassC insert];
    cInstance2.noValidationStringA = @"Consistency check";
    cInstance2.codeMandatoryNotEmptyStringA = @"Mandatory A";
    cInstance2.codeMandatoryNumberB = @0;
    cInstance2.modelMandatoryBoundedNumberB = @6;
    cInstance2.modelMandatoryCodeNotZeroNumberB = @3;
    cInstance2.codeMandatoryStringC = @"Mandatory C";
    cInstance2.modelMandatoryBoundedPatternStringC = @"Hello, World!";
    cInstance2.noValidationNumberC = @1012;
    cInstance2.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, nil];
    
    NSError *error2 = nil;
    XCTAssertFalse([cInstance2 check:&error2]);
    XCTAssertTrue([error2 hasCode:TestValidationInconsistencyError withinDomain:TestValidationErrorDomain]);
    
    // Invalid ConcreteSubclassC instance (5 errors: 4 invidual validation errors and 3 consistency error). Also tests
    // that the error hierarchy is correctly flattened out
    ConcreteSubclassC *cInstance3 = [ConcreteSubclassC insert];
    cInstance3.noValidationStringA = @"Unexpected string for consistency check";
    cInstance3.codeMandatoryNotEmptyStringA = nil;                      // <-- 1 individual error
    cInstance3.codeMandatoryNumberB = @0;
    cInstance3.modelMandatoryBoundedNumberB = @6;
    cInstance3.modelMandatoryCodeNotZeroNumberB = @0;                   // <-- 1 individual error
    cInstance3.codeMandatoryStringC = @"Mandatory C";
    cInstance3.modelMandatoryBoundedPatternStringC = @"This string is too long, and does not match the expected pattern";       // <-- 2 individual errors
    cInstance3.codeMandatoryConcreteClassesD = [NSSet setWithObjects:dInstance1, dInstance2, nil];
    
    NSError *error3 = nil;
    XCTAssertFalse([cInstance3 check:&error3]);
    XCTAssertTrue([error3 hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]);
    NSArray *subErrors3 = [[error3 userInfo] objectForKey:NSDetailedErrorsKey];
    XCTAssertEqual([subErrors3 count], (NSUInteger)7);
    
    // Not testing insertion here. Rollback
    [HLSModelManager rollbackCurrentModelContext];
}

- (void)testDelete
{    
    [HLSModelManager deleteObjectFromCurrentModelContext:self.lockedDInstance];
    
    NSError *error = nil;
    XCTAssertFalse([HLSModelManager saveCurrentModelContext:&error]);
    XCTAssertTrue([error hasCode:TestValidationLockedObjectError withinDomain:TestValidationErrorDomain]);
    [HLSModelManager rollbackCurrentModelContext];
}

@end
