//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "EmployeeTableViewCell.h"

@implementation EmployeeTableViewCell

#pragma mark Transformers

+ (HLSBlockTransformer *)numberToAgeStringTransformer
{
    static dispatch_once_t s_onceToken;
    static HLSBlockTransformer *s_transformer;
    dispatch_once(&s_onceToken, ^{
        s_transformer = [HLSBlockTransformer blockTransformerWithBlock:^(NSNumber *number) {
            return [NSString stringWithFormat:NSLocalizedString(@"Age: %@", nil), number];
        } reverseBlock:nil];
    });
    return s_transformer;
}

@end
