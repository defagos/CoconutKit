//
//  NSManagedObject+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 17.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSManagedObject+HLSExtensionsTestCase.h"

#import "Person.h"

@interface NSManagedObject_HLSExtensionsTestCase ()

@property (nonatomic, retain) Person *person1;
@property (nonatomic, retain) Person *person2;

@end

@implementation NSManagedObject_HLSExtensionsTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.person1 = nil;
    self.person2 = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize person1 = m_person1;

@synthesize person2 = m_person2;

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Destroy any existing previous store
    NSString *libraryDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *storeFilePath = [HLSModelManager storeFilePathForModelFileName:@"CoconutKitTestData" storeDirectory:libraryDirectoryPath];
    if (storeFilePath) {
        NSError *error = nil;
        if (! [[NSFileManager defaultManager] removeItemAtPath:storeFilePath error:&error]) {
            HLSLoggerWarn(@"Could not remove store at path %@", storeFilePath);
        }
    }
    
    // Freshly create a test store
    HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"CoconutKitTestData"
                                                                           inBundle:nil
                                                                      configuration:nil
                                                                     storeDirectory:libraryDirectoryPath
                                                                            options:HLSModelManagerLightweightMigrationOptions];
    [HLSModelManager pushModelManager:modelManager];
    
    // Idea: We work with three test classes: Person, Account and House. A person can have several accounts, and 
    //       owns them (once the person dies, the account disappears). Moreover, an account is owned by a single
    //       person. On the other hand, a house can have several owners and does not get destroyed once one of
    //       its owners dies.
    self.person1 = [Person insert];
    self.person1.firstName = @"Tony";
    self.person1.lastName = @"Slowprano";
    
    self.person2 = [Person insert];
    self.person2.firstName = @"Carmela";
    self.person2.lastName = @"Slowprano";
    
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
    GHAssertTrue(person1Duplicate != self.person1, @"Not a deep copy");
    GHAssertFalse([person1Duplicate.firstName isEqualToString:self.person1.firstName], @"First name");
    GHAssertTrue([person1Duplicate.lastName isEqualToString:self.person1.lastName], @"Last name");
    
    // The house is not owned and therefore shared
    GHAssertTrue([person1Duplicate.houses isEqualToSet:self.person1.houses], @"Houses are incorrect");
    
    // The accounts are owned and therefore deeply copied
    GHAssertFalse([person1Duplicate.accounts isEqualToSet:self.person1.accounts], @"Accounts are incorrect");
    
    // Test overall consistency of the object hiearchy which has been duplicated
    GHAssertTrue([HLSModelManager saveCurrentModelContext:NULL], @"Invalid objects");
}

@end
