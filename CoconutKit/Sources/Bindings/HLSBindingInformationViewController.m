//
//  HLSBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingInformationViewController.h"

#import "HLSAssert.h"
#import "HLSDetailedInfoTableViewCell.h"
#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "NSBundle+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"

typedef enum {
    BindingInformationEnumBegin = 0,
    BindingInformationObject = BindingInformationEnumBegin,
    BindingInformationKeyPath,
    BindingInformationCheckingDisplayedValueAutomatically,
    BindingInformationUpdatingModelAutomatically,
    BindingInformationValue,
    BindingInformationRawValue,
    BindingInformationTransformerName,
    BindingInformationTransformationTarget,
    BindingInformationTransformationSelector,
    BindingInformationDelegate,
    BindingInformationErrorDescription,
    BindingInformationEnumEnd,
    BindingInformationEnumSize = BindingInformationEnumEnd - BindingInformationEnumBegin
} BindingInformation;

@interface HLSBindingInformationViewController ()

@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

@end

@implementation HLSBindingInformationViewController

#pragma mark Class methods

+ (NSString *)identityStringForObject:(id)object
{
    if (! object) {
        return @"-";
    }
    
    // Class objects: Display class name
    if (hls_isClass(object)) {
        return [NSString stringWithFormat:@"'%@' class", object];
    }
    else {
        return [object description];
    }
}

#pragma mark Object creation and destruction

- (id)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.bindingInformation = bindingInformation;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(320.f, 640.f);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return BindingInformationEnumSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case BindingInformationObject:
        case BindingInformationTransformationTarget:
        case BindingInformationErrorDescription: {
            return [HLSDetailedInfoTableViewCell cellForTableView:tableView];
            break;
        }
            
        default: {
            return [HLSInfoTableViewCell cellForTableView:tableView];
            break;
        }
    }
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = nil;
    NSString *value = nil;
    
    switch (indexPath.row) {
        case BindingInformationObject: {
            name = CoconutKitLocalizedString(@"Object", nil);
            value = [HLSBindingInformationViewController identityStringForObject:self.bindingInformation.object];
            break;
        }
            
        case BindingInformationKeyPath: {
            name = CoconutKitLocalizedString(@"Key path", nil);
            value = self.bindingInformation.keyPath ?: @"-";
            break;
        }
            
        case BindingInformationCheckingDisplayedValueAutomatically: {
            name = CoconutKitLocalizedString(@"Check automatically", nil);
            value = HLSStringFromBool(self.bindingInformation.view.checkingDisplayedValueAutomatically);
            break;
        }
            
        case BindingInformationUpdatingModelAutomatically: {
            name = CoconutKitLocalizedString(@"Update automatically", nil);
            value = HLSStringFromBool(self.bindingInformation.view.updatingModelAutomatically);
            break;
        }
            
        case BindingInformationValue: {
            name = CoconutKitLocalizedString(@"Value", nil);
            value = [HLSBindingInformationViewController identityStringForObject:[self.bindingInformation value]];
            break;
        }
            
        case BindingInformationRawValue: {
            name = CoconutKitLocalizedString(@"Raw value", nil);
            value = [HLSBindingInformationViewController identityStringForObject:[self.bindingInformation rawValue]];
            break;
        }
            
        case BindingInformationTransformerName: {
            name = CoconutKitLocalizedString(@"Transformer name", nil);
            value = self.bindingInformation.transformerName ?: @"-";
            break;
        }
            
        case BindingInformationTransformationTarget: {
            name = CoconutKitLocalizedString(@"Resolved transformation target", nil);
            value = [HLSBindingInformationViewController identityStringForObject:self.bindingInformation.transformationTarget];
            break;
        }
            
        case BindingInformationTransformationSelector: {
            name = CoconutKitLocalizedString(@"Resolved transformation selector", nil);
            if (self.bindingInformation.transformationSelector) {
                value = [NSString stringWithFormat:@"%@%@", hls_isClass(self.bindingInformation.transformationTarget) ? @"+" : @"-",
                         NSStringFromSelector(self.bindingInformation.transformationSelector)];
            }
            else {
                value = @"-";
            }
            break;
        }
            
        case BindingInformationDelegate: {
            name = CoconutKitLocalizedString(@"Delegate", nil);
            value = [HLSBindingInformationViewController identityStringForObject:self.bindingInformation.delegate];
            break;
        }
            
        case BindingInformationErrorDescription: {
            name = CoconutKitLocalizedString(@"Description", nil);
            if (self.bindingInformation.verified) {
                value = CoconutKitLocalizedString(@"The binding has been successfully resolved", nil);
            }
            else {
                value = self.bindingInformation.errorDescription ?: CoconutKitLocalizedString(@"The binding information cannot be verified (nil value)", nil);
            }
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown cell index");
            break;
        }
    }
    
    HLSInfoTableViewCell *infoCell = (HLSInfoTableViewCell *)cell;
    infoCell.nameLabel.text = name;
    infoCell.valueLabel.text = value;
    infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case BindingInformationObject:
        case BindingInformationTransformationTarget:
        case BindingInformationErrorDescription: {
            return [HLSDetailedInfoTableViewCell height];
            break;
        }
            
        default: {
            return [HLSInfoTableViewCell height];
            break;
        }
    }
}

@end
