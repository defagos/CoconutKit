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
#import "NSBundle+HLSExtensions.h"

typedef enum {
    BindingInformationEnumBegin = 0,
    BindingInformationObject = BindingInformationEnumBegin,
    BindingInformationKeyPath,
    BindingInformationFormatterName,
    BindingInformationFormattingTarget,
    BindingInformationFormattingSelector,
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
        return [NSString stringWithFormat:@"'%@' instance (%p)", [object class], object];
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
    
    self.contentSizeForViewInPopover = CGSizeMake(320.f, 492.f);
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
        case BindingInformationFormattingTarget:
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
            
        case BindingInformationFormatterName: {
            name = CoconutKitLocalizedString(@"Formatter name", nil);
            value = self.bindingInformation.formatterName ?: @"-";
            break;
        }
            
        case BindingInformationFormattingTarget: {
            name = CoconutKitLocalizedString(@"Formatting target", nil);
            value = [HLSBindingInformationViewController identityStringForObject:self.bindingInformation.formattingTarget];
            break;
        }
            
        case BindingInformationFormattingSelector: {
            name = CoconutKitLocalizedString(@"Formatting selector", nil);
            if (self.bindingInformation.formattingSelector) {
                value = [NSString stringWithFormat:@"%@%@", hls_isClass(self.bindingInformation.formattingTarget) ? @"+" : @"-",
                         NSStringFromSelector(self.bindingInformation.formattingSelector)];
            }
            else {
                value = @"-";
            }
            break;
        }
            
        case BindingInformationErrorDescription: {
            name = CoconutKitLocalizedString(@"Description", nil);
            value = self.bindingInformation.errorDescription ?: CoconutKitLocalizedString(@"The binding has been successfully resolved", nil);
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
        case BindingInformationFormattingTarget:
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
