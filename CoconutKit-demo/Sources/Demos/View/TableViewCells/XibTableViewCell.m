//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "XibTableViewCell.h"

@implementation XibTableViewCell

#pragma mark Cell customisation

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundWithImageNamed:@"cell_bkgr_brown_large.png" selectedBackgroundWithImageName:@"cell_bkgr_brown_large_selected.png"];
}

@end
