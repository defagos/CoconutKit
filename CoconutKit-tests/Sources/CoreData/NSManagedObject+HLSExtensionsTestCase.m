//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSManagedObject+HLSExtensionsTestCase.h"

#import "NSBundle+Tests.h"
#import "Person.h"

@interface NSManagedObject_HLSExtensionsTestCase ()

@property (nonatomic, strong) Person *person1;
@property (nonatomic, strong) Person *person2;

@end

@implementation NSManagedObject_HLSExtensionsTestCase

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
    
    // Idea: We work with three test classes: Person, Account and House. A person can have several accounts, and 
    //       owns them (once the person dies, the account disappears). Moreover, an account is owned by a single
    //       person. On the other hand, a house can have several owners and does not get destroyed once one of
    //       its owners dies.
    self.person1 = [Person insert];
    self.person1.firstName = @"Tony";
    self.person1.lastName = @"Soprano";
    
    self.person2 = [Person insert];
    self.person2.firstName = @"Carmela";
    self.person2.lastName = @"Soprano";
    
    House *house = [House insert];
    house.name = @"Mafia blues";
    house.owners = [NSSet setWithObjects:self.person1, self.person2, nil];
    
    BankAccount *bankAccount1 = [BankAccount insert];
    bankAccount1.name = @"Clean account";
    bankAccount1.balanceValue = 15450039.50;
    bankAccount1.owner = self.person1;
    
    BankAccount *bankAccount2 = [BankAccount insert];
    bankAccount2.name = @"Dirty account";
    bankAccount2.balanceValue = 79340087.;
    bankAccount2.owner = self.person1;
    
    NSAssert([HLSModelManager saveCurrentModelContext:NULL], @"Failed to insert test data");
}

#pragma mark Tests

- (void)testDuplicate
{
    Person *person1Duplicate = [self.person1 duplicate];
    person1Duplicate.firstName = @"Anthony";
    
    // Test duplication
    XCTAssertTrue(person1Duplicate != self.person1);
    XCTAssertFalse([person1Duplicate.firstName isEqualToString:self.person1.firstName]);
    XCTAssertTrue([person1Duplicate.lastName isEqualToString:self.person1.lastName]);
    
    // The house is not owned and therefore shared
    XCTAssertTrue([person1Duplicate.houses isEqualToSet:self.person1.houses]);
    
    // The accounts are owned and therefore deeply copied
    XCTAssertFalse([person1Duplicate.accounts isEqualToSet:self.person1.accounts]);
    
    // Test overall consistency of the object hiearchy which has been duplicated
    XCTAssertTrue([HLSModelManager saveCurrentModelContext:NULL]);
}

@end
