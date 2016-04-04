//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsPerformance2DemoViewController.h"

@interface BindingsPerformance2DemoViewController ()

@property (nonatomic, copy) NSString *name;

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
    return [HLSBlockTransformer blockTransformerWithBlock:^(NSString *  _Nullable name) {
        return name.uppercaseString;
    } reverseBlock:^(NSString  * _Nullable __autoreleasing * _Nonnull pName, NSString *  _Nonnull uppercaseName, NSError * _Nullable __autoreleasing * _Nullable pError) {
        if (pName) {
            *pName = uppercaseName.lowercaseString;
        }
        return YES;
    }];
}

@end
