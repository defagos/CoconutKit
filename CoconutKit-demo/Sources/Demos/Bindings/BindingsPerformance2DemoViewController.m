//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsPerformance2DemoViewController.h"

@interface BindingsPerformance2DemoViewController ()

@property (nonatomic, strong) NSString *name;

@end

@implementation BindingsPerformance2DemoViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Tom";
    }
    return self;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Performance 2", nil);
}

#pragma mark Transformers

- (id<HLSTransformer>)uppercaseTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSString *name) {
        return [name uppercaseString];
    } reverseBlock:^(__autoreleasing NSString **pName, NSString *uppercaseName, NSError *__autoreleasing *pError) {
        if (pName) {
            *pName = [uppercaseName lowercaseString];
        }
        return YES;
    }];
}

@end
