//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "ProgrammaticTableViewCell.h"

@implementation ProgrammaticTableViewCell

#pragma mark Object creation and destruction

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Make cell taller than default size (if not altered, 44.f)
        self.frame = CGRectMake(self.contentView.frame.origin.x,
                                self.contentView.frame.origin.y,
                                self.contentView.frame.size.width,
                                60.f);
        
        // Just add some customized label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 20.f, 400.f, 20.f)];
        label.font = [UIFont systemFontOfSize:13.f];
        [self.contentView addSubview:self.label];
        self.label = label;
    }
    return self;
}



@end
