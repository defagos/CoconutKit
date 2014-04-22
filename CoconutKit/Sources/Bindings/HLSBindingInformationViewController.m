//
//  HLSBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingInformationViewController.h"

#import "HLSAssert.h"
#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "NSBundle+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"

@interface HLSBindingInformationViewController ()

@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSArray *values;

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
        self.names = @[CoconutKitLocalizedString(@"Object", nil),
                       CoconutKitLocalizedString(@"Key path", nil),
                       CoconutKitLocalizedString(@"Check automatically", nil),
                       CoconutKitLocalizedString(@"Update automatically", nil),
                       CoconutKitLocalizedString(@"Value", nil),
                       CoconutKitLocalizedString(@"Raw value", nil),
                       CoconutKitLocalizedString(@"Transformer name", nil),
                       CoconutKitLocalizedString(@"Resolved transformation target", nil),
                       CoconutKitLocalizedString(@"Resolved transformation selector", nil),
                       CoconutKitLocalizedString(@"Delegate", nil),
                       CoconutKitLocalizedString(@"Description", nil)];
        
        NSString *transformationSelector = nil;
        if (bindingInformation.transformationSelector) {
            transformationSelector = [NSString stringWithFormat:@"%@%@", hls_isClass(bindingInformation.transformationTarget) ? @"+" : @"-",
                                      NSStringFromSelector(bindingInformation.transformationSelector)];
        }
        else {
            transformationSelector = @"-";
        }
        
        NSString *status = nil;
        if (bindingInformation.verified) {
            status = CoconutKitLocalizedString(@"The binding has been successfully resolved", nil);
        }
        else {
            status = bindingInformation.errorDescription ?: CoconutKitLocalizedString(@"The binding information cannot be verified (nil value)", nil);
        }
        
        self.values = @[[HLSBindingInformationViewController identityStringForObject:bindingInformation.object],
                        bindingInformation.keyPath ?: @"-",
                        HLSStringFromBool(bindingInformation.view.checkingDisplayedValueAutomatically),
                        HLSStringFromBool(bindingInformation.view.updatingModelAutomatically),
                        [HLSBindingInformationViewController identityStringForObject:[bindingInformation value]],
                        [HLSBindingInformationViewController identityStringForObject:[bindingInformation rawValue]],
                        bindingInformation.transformerName ?: @"-",
                        [HLSBindingInformationViewController identityStringForObject:bindingInformation.transformationTarget],
                        transformationSelector,
                        [HLSBindingInformationViewController identityStringForObject:bindingInformation.delegate],
                        status];
        
        NSAssert([self.names count] == [self.values count], @"Expect the same number of names and values");
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
    return [self.names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HLSInfoTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSInfoTableViewCell *infoCell = (HLSInfoTableViewCell *)cell;
    infoCell.nameLabel.text = [self.names objectAtIndex:indexPath.row];
    infoCell.valueLabel.text = [self.values objectAtIndex:indexPath.row];
    infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HLSInfoTableViewCell heightForValue:[self.values objectAtIndex:indexPath.row]];
}

@end
