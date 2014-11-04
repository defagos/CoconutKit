//
//  HLSBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSBindingInformationViewController.h"

#import "HLSBindingInformationEntry.h"
#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "NSBundle+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingImplementation.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSBindingInformationViewController ()

@property (nonatomic, strong) NSArray *entries;

@end

@implementation HLSBindingInformationViewController

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        NSMutableArray *entries= [NSMutableArray array];
        
        NSString *statusString = nil;
        if (bindingInformation.verified) {
            statusString = CoconutKitLocalizedString(@"The binding has been successfully resolved", nil);
        }
        else {
            statusString = bindingInformation.errorDescription ?: CoconutKitLocalizedString(@"The binding information cannot be verified (nil value)", nil);
        }
        
        HLSBindingInformationEntry *entry1 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Binding status", nil)
                                                                                         text:statusString];
        [entries addObject:entry1];
        
        HLSBindingInformationEntry *entry2 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Key path", nil)
                                                                                         text:bindingInformation.keyPath];
        [entries addObject:entry2];
        
        HLSBindingInformationEntry *entry3 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Transformer name", nil)
                                                                                         text:bindingInformation.transformerName];
        [entries addObject:entry3];
        
        HLSBindingInformationEntry *entry4 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved bound object", nil)
                                                                                       object:bindingInformation.object];
        [entries addObject:entry4];
        
        HLSBindingInformationEntry *entry5 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved binding delegate", nil)
                                                                                       object:bindingInformation.delegate];
        [entries addObject:entry5];
        
        HLSBindingInformationEntry *entry6 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Formatted value", nil)
                                                                                       object:[bindingInformation value]];
        [entries addObject:entry6];
        
        HLSBindingInformationEntry *entry7 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Raw value", nil)
                                                                                       object:[bindingInformation rawValue]];
        [entries addObject:entry7];
        
        HLSBindingInformationEntry *entry8 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation target", nil)
                                                                                       object:bindingInformation.transformationTarget];
        [entries addObject:entry8];
        
        NSString *transformationSelectorString = nil;
        if (bindingInformation.transformationSelector) {
            transformationSelectorString = [NSString stringWithFormat:@"%@%@", hls_isClass(bindingInformation.transformationTarget) ? @"+" : @"-",
                                            NSStringFromSelector(bindingInformation.transformationSelector)];
        }
        else {
            transformationSelectorString = @"-";
        }
        
        HLSBindingInformationEntry *entry9 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation selector", nil)
                                                                                         text:transformationSelectorString];
        [entries addObject:entry9];
        
        HLSBindingInformationEntry *entry10 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Can update bound object", nil)
                                                                                          text:HLSStringFromBool([bindingInformation.view respondsToSelector:@selector(displayedValue)])];
        [entries addObject:entry10];
        
        HLSBindingInformationEntry *entry11 = [[HLSBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Synchronized", nil)
                                                                                          text:HLSStringFromBool(bindingInformation.synchronized)];
        [entries addObject:entry11];
        
        self.entries = [NSArray arrayWithArray:entries];
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(320.f, 640.f);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [HLSInfoTableViewCell cellForTableView:tableView];
}

#pragma mark UITableViewDelegate protocol implementation

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSBindingInformationEntry *entry = [self.entries objectAtIndex:indexPath.row];
    
    HLSInfoTableViewCell *infoCell = (HLSInfoTableViewCell *)cell;
    infoCell.nameLabel.text = entry.name;
    infoCell.valueLabel.text = entry.text;
    infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSBindingInformationEntry *entry = [self.entries objectAtIndex:indexPath.row];
    return [HLSInfoTableViewCell heightForValue:entry.text];
}

// FIXME: Implement highlighting again
#if 0
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
#endif

@end
