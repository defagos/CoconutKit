//
//  HLSViewBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformationViewController.h"

#import "HLSInfoTableViewCell.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "HLSTransformer.h"
#import "HLSViewBindingInformationEntry.h"
#import "NSBundle+HLSExtensions.h"
#import "NSString+HLSExtensions.h"
#import "UIView+HLSViewBinding.h"
#import "UIView+HLSViewBindingImplementation.h"

@interface HLSViewBindingInformationViewController ()

@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;
@property (nonatomic, strong) NSArray *entries;

@end

@implementation HLSViewBindingInformationViewController

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.bindingInformation = bindingInformation;
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(320.f, 640.f);
    
    [self reloadData];
}

#pragma mark Data

- (void)reloadData
{
    NSMutableArray *entries = [NSMutableArray array];
    
    NSString *defaultStatusString = self.bindingInformation.verified ? CoconutKitLocalizedString(@"The binding information is valid", nil) : CoconutKitLocalizedString(@"The binding information has not been fully verified yet", nil);
    NSString *statusString = self.bindingInformation.error ? [self.bindingInformation.error localizedDescription] : defaultStatusString;
    HLSViewBindingInformationEntry *statusEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Status", nil)
                                                                                                  text:statusString];
    [entries addObject:statusEntry];
    
    HLSViewBindingInformationEntry *updatedAutomaticallyEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Updated automatically", nil)
                                                                                                                text:HLSStringFromBool(self.bindingInformation.updatedAutomatically)];
    [entries addObject:updatedAutomaticallyEntry];
    
    HLSViewBindingInformationEntry *keyPathEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Key path", nil)
                                                                                                   text:self.bindingInformation.keyPath];
    [entries addObject:keyPathEntry];
    
    HLSViewBindingInformationEntry *transformerNameEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Transformer name", nil)
                                                                                                           text:self.bindingInformation.transformerName];
    [entries addObject:transformerNameEntry];
    
    HLSViewBindingInformationEntry *objectTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved bound object", nil)
                                                                                                      object:self.bindingInformation.objectTarget];
    [entries addObject:objectTargetEntry];
    
    HLSViewBindingInformationEntry *delegateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved binding delegate", nil)
                                                                                                  object:self.bindingInformation.delegate];
    [entries addObject:delegateEntry];
    
    HLSViewBindingInformationEntry *displayedValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Displayed value", nil)
                                                                                                        object:[self.bindingInformation displayedValue]];
    [entries addObject:displayedValueEntry];
    
    HLSViewBindingInformationEntry *rawValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Raw value", nil)
                                                                                                  object:[self.bindingInformation rawValue]];
    [entries addObject:rawValueEntry];
    
    HLSViewBindingInformationEntry *valueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Formatter raw value", nil)
                                                                                               object:[self.bindingInformation value]];
    [entries addObject:valueEntry];
    
    HLSViewBindingInformationEntry *transformationTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation target", nil)
                                                                                                              object:self.bindingInformation.transformationTarget];
    [entries addObject:transformationTargetEntry];
    
    NSString *transformationSelectorString = nil;
    if (self.bindingInformation.transformationSelector) {
        transformationSelectorString = [NSString stringWithFormat:@"%@%@", hls_isClass(self.bindingInformation.transformationTarget) ? @"+" : @"-",
                                        NSStringFromSelector(self.bindingInformation.transformationSelector)];
    }
    else {
        transformationSelectorString = @"-";
    }
    
    HLSViewBindingInformationEntry *transformationSelectorEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation selector", nil)
                                                                                                                  text:transformationSelectorString];
    [entries addObject:transformationSelectorEntry];
    
    HLSViewBindingInformationEntry *canUpdateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Can update bound object", nil)
                                                                                                     text:HLSStringFromBool([self.bindingInformation.view respondsToSelector:@selector(displayedValue)])];
    [entries addObject:canUpdateEntry];
    
    self.entries = [NSArray arrayWithArray:entries];
    
    [self.tableView reloadData];
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
    HLSViewBindingInformationEntry *entry = [self.entries objectAtIndex:indexPath.row];
    
    HLSInfoTableViewCell *infoCell = (HLSInfoTableViewCell *)cell;
    infoCell.nameLabel.text = entry.name;
    infoCell.valueLabel.text = entry.text;
    infoCell.selectionStyle = [entry canHighlight] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLSViewBindingInformationEntry *entry = [self.entries objectAtIndex:indexPath.row];
    return [HLSInfoTableViewCell heightForValue:entry.text];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HLSViewBindingInformationEntry *entry = [self.entries objectAtIndex:indexPath.row];
    [entry highlight];
}

@end
