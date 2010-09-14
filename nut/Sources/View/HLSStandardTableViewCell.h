//
//  HLSStandardTableViewCell.h
//  FIVB
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Convenience macro for creating cells of a given class, and cached for a table view
#define STANDARD_TABLE_VIEW_CELL(className, tableView)      (className *)[className tableViewCellForTableView:tableView]

// Convenience macro for retrieving the height of a cell
#define STANDARD_TABLE_VIEW_CELL_HEIGHT(className)          [className height]

/**
 * "Pure virtual" methods
 */
@protocol HLSStandardTableViewCellAbstract

@optional
/**
 * Implement this method to set the height of your custom cell class (must match the one of the nib file)
 */
+ (CGFloat)height;

@end

/**
 * To make working with cells easier, just inherit from this class. This forces you to define cell properties in a
 * standard and centralized way (namely in the cell implementation file), instead of putting redundant code in all
 * table view controllers which use those cells.
 *
 * Use the factory method for creating a cell in a standard way as well (i.e. with an identifier for caching). The
 * following convention is applied (beware that your nib follows it):
 *   name of the cell implementation file = name of nib file == cell identifier
 * The cell object must be the first in your nib file.
 *
 * Designated initializer: initWithStyle:reuseIdentifier:
 * (You usually do not need to create a cell manually. Use the factory method instead)
 */
@interface HLSStandardTableViewCell : UITableViewCell <HLSStandardTableViewCellAbstract> {
@private
    
}

/**
 * Factory method for creating a standard table view cell
 */
+ (UITableViewCell *)tableViewCellForTableView:(UITableView *)tableView;

/**
 * Convenience method for defining styles
 */
- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName;

@end
