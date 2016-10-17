//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "BindingsFailuresDemoViewController.h"

@interface BindingsFailuresDemoViewController ()

@property (nonatomic) NSNumber *number;

@end

@implementation BindingsFailuresDemoViewController {
@private
    NSNumber *_otherNumber;
}

#pragma mark Accessors and mutators

- (NSString *)readonlyString
{
    return @"Readonly keyPath";
}

- (NSDate *)date
{
    return [NSDate date];
}

- (NSNumber *)otherNumber
{
    return _otherNumber;
}

- (void)setOtherNumber:(NSNumber *)otherNumber
{
    _otherNumber = otherNumber;
}

#pragma mark Transformers

- (HLSBlockTransformer *)truthTransformer
{
    return [HLSBlockTransformer blockTransformerWithBlock:^(id  _Nullable object) {
        return @42;
    } reverseBlock:nil];
}

- (NSString *)invalidTransformer
{
    return @"invalid";
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Failures", nil);
}

#pragma mark HLSViewBindingDelegate protocol

- (void)boundView:(UIView *)boundView updateDidFailWithContext:(nonnull HLSBindingContext *)context error:(nonnull NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                             message:[error localizedDescription]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
