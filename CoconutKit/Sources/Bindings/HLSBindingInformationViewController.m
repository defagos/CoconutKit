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
@property (nonatomic, strong) NSArray *objects;

@end

@implementation HLSBindingInformationViewController

#pragma mark Class methods

+ (NSString *)identityStringForObject:(id)object
{
    if (! object || object == [NSNull null]) {
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
        self.names = @[CoconutKitLocalizedString(@"Binding status", nil),
                       CoconutKitLocalizedString(@"Key path", nil),
                       CoconutKitLocalizedString(@"Transformer name", nil),
                       CoconutKitLocalizedString(@"Resolved bound object", nil),
                       CoconutKitLocalizedString(@"Resolved binding delegate", nil),
                       CoconutKitLocalizedString(@"Formatted value", nil),
                       CoconutKitLocalizedString(@"Raw value", nil),
                       CoconutKitLocalizedString(@"Resolved transformation target", nil),
                       CoconutKitLocalizedString(@"Resolved transformation selector", nil),
                       CoconutKitLocalizedString(@"Check automatically", nil),
                       CoconutKitLocalizedString(@"Update automatically", nil)];
        
        NSString *statusString = nil;
        if (bindingInformation.verified) {
            statusString = CoconutKitLocalizedString(@"The binding has been successfully resolved", nil);
        }
        else {
            statusString = bindingInformation.errorDescription ?: CoconutKitLocalizedString(@"The binding information cannot be verified (nil value)", nil);
        }
        
        NSString *transformationSelectorString = nil;
        if (bindingInformation.transformationSelector) {
            transformationSelectorString = [NSString stringWithFormat:@"%@%@", hls_isClass(bindingInformation.transformationTarget) ? @"+" : @"-",
                                            NSStringFromSelector(bindingInformation.transformationSelector)];
        }
        else {
            transformationSelectorString = @"-";
        }
        
        self.objects = @[statusString,
                         bindingInformation.keyPath ?: @"-",
                         bindingInformation.transformerName ?: @"-",
                         bindingInformation.object ?: [NSNull null],
                         bindingInformation.delegate ?: (id)[NSNull null],
                         [bindingInformation value] ?: [NSNull null],
                         [bindingInformation rawValue] ?: [NSNull null],
                         bindingInformation.transformationTarget ?: [NSNull null],
                         transformationSelectorString,
                         HLSStringFromBool(bindingInformation.view.checkingDisplayedValueAutomatically),
                         HLSStringFromBool(bindingInformation.view.updatingModelAutomatically)];
        
        NSAssert([self.names count] == [self.objects count], @"Expect the same number of names and objects");
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

#pragma mark Cell contents

- (NSString *)valueAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.objects objectAtIndex:indexPath.row];
    return [object isKindOfClass:[NSString class]] ? object : [HLSBindingInformationViewController identityStringForObject:object];
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
    infoCell.valueLabel.text = [self valueAtIndexPath:indexPath];
    infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *value = [self valueAtIndexPath:indexPath];
    return [HLSInfoTableViewCell heightForValue:value];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = nil;
    id object = [self.objects objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[UIView class]]) {
        view = object;
    }
    else if ([object isKindOfClass:[UIViewController class]]) {
        view = [object viewIfLoaded];
    }
    
    if (! view) {
        return;
    }
    
    // Highlight views
    CGFloat alpha = view.alpha;
    UIColor *backgroundColor = view.backgroundColor;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = alpha / 2.f;
        view.backgroundColor = [UIColor blueColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = alpha;
            view.backgroundColor = backgroundColor;
        }];
    }];
}

@end
