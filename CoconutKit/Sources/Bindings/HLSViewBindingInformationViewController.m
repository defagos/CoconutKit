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

@property (nonatomic, strong) NSArray *entries;

@end

@implementation HLSViewBindingInformationViewController

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        NSMutableArray *entries = [NSMutableArray array];
        
        NSString *defaultStatusString = bindingInformation.verified ? CoconutKitLocalizedString(@"The binding information is valid", nil) : CoconutKitLocalizedString(@"The binding information has not been fully verified yet", nil);
        NSString *statusString = bindingInformation.error ? [bindingInformation.error localizedDescription] : defaultStatusString;
        HLSViewBindingInformationEntry *statusEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Status", nil)
                                                                                                      text:statusString];
        [entries addObject:statusEntry];
        
        HLSViewBindingInformationEntry *updatedAutomaticallyEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Updated automatically", nil)
                                                                                                                    text:HLSStringFromBool(bindingInformation.updatedAutomatically)];
        [entries addObject:updatedAutomaticallyEntry];
        
        HLSViewBindingInformationEntry *keyPathEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Key path", nil)
                                                                                                       text:bindingInformation.keyPath];
        [entries addObject:keyPathEntry];
        
        HLSViewBindingInformationEntry *transformerNameEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Transformer name", nil)
                                                                                                               text:bindingInformation.transformerName];
        [entries addObject:transformerNameEntry];
        
        HLSViewBindingInformationEntry *objectTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved bound object", nil)
                                                                                                          object:bindingInformation.objectTarget];
        [entries addObject:objectTargetEntry];
        
        HLSViewBindingInformationEntry *delegateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved binding delegate", nil)
                                                                                                      object:bindingInformation.delegate];
        [entries addObject:delegateEntry];
        
        HLSViewBindingInformationEntry *displayedValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Displayed value", nil)
                                                                                                            object:[bindingInformation displayedValue]];
        [entries addObject:displayedValueEntry];
        
        HLSViewBindingInformationEntry *rawValueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Raw value", nil)
                                                                                                      object:[bindingInformation rawValue]];
        [entries addObject:rawValueEntry];
        
        HLSViewBindingInformationEntry *valueEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Formatter raw value", nil)
                                                                                                   object:[bindingInformation value]];
        [entries addObject:valueEntry];
        
        HLSViewBindingInformationEntry *transformationTargetEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation target", nil)
                                                                                                                  object:bindingInformation.transformationTarget];
        [entries addObject:transformationTargetEntry];
        
        NSString *transformationSelectorString = nil;
        if (bindingInformation.transformationSelector) {
            transformationSelectorString = [NSString stringWithFormat:@"%@%@", hls_isClass(bindingInformation.transformationTarget) ? @"+" : @"-",
                                            NSStringFromSelector(bindingInformation.transformationSelector)];
        }
        else {
            transformationSelectorString = @"-";
        }
        
        HLSViewBindingInformationEntry *transformationSelectorEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Resolved transformation selector", nil)
                                                                                                                      text:transformationSelectorString];
        [entries addObject:transformationSelectorEntry];
        
        HLSViewBindingInformationEntry *canUpdateEntry = [[HLSViewBindingInformationEntry alloc] initWithName:CoconutKitLocalizedString(@"Can update bound object", nil)
                                                                                                         text:HLSStringFromBool([bindingInformation.view respondsToSelector:@selector(displayedValue)])];
        [entries addObject:canUpdateEntry];
        
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
