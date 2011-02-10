//
//  HLSStandardTableViewCell.h
//  nut
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Convenience macro for creating a cell of a given class using a xib having the same name as the class
#define CUSTOM_TABLE_VIEW_CELL_FROM_XIB(className, tableView)                               (className *)[className tableViewCellFromXibFileWithName:className forTableView:tableView]

// Convenience macro for creating a cell of a given class using a xib with arbitrary name
#define CUSTOM_TABLE_VIEW_CELL_FROM_XIB_WITH_NAME(className, tableView, xibFileName)        (className *)[className tableViewCellFromXibFileWithName:xibFileName forTableView:tableView]

// Convenience macro for creating a cell programmatically without a xib
#define CUSTOM_TABLE_VIEW_CELL_PROGRAMMATICALLY(className, style, tableView)                (className *)[className tableViewCellWithStyle:style forTableView:tableView]

// Convenience macro for creating a simple built-in cell. No need for subclassing HLSStandardTableViewCell, but with limited customization abilities
#define STANDARD_TABLE_VIEW_CELL(style, tableView)                                          [HLSStandardTableViewCell tableViewCellWithStyle:style forTableView:tableView]

// Convenience macro for retrieving the height of a custom cell
#define CUSTOM_TABLE_VIEW_CELL_HEIGHT(className)                                            [className height]

// Convenience macro for retrieving the height of a standard cell
#define STANDARD_TABLE_VIEW_CELL_HEIGHT()                                                   [HLSStandardTableViewCell height]

/**
 * Class for easier table view cell creation. Using this class, you avoid having to code the cell reuse mechanism
 * every time you instantiate cells. 
 *
 * To make working with custom cells easier, just inherit from this class. This forces you to define cell properties in a
 * standard and centralized way (namely in the cell implementation file), instead of putting redundant code in all
 * table view controllers which use those cells.
 *
 * Use the factory methods for creating a cell in a standard way as well (i.e. with an identifier for caching). The
 * cell can be instantiated via code or from a xib file.
 *
 * Designated initializer: initWithStyle:reuseIdentifier:
 * (You usually do not need to create a cell manually. Use the factory methods instead)
 */
@interface HLSStandardTableViewCell : UITableViewCell {
@private

}

/**
 * Factory method for creating a standard table view cell using a xib. For this factory method to work, the xib file
 * must have a UITableViewCell as first resource, and this object must be assigned the identifer of the class (using 
 * Interface Builder). This identifier is by default the class name, but you can override it in subclasses to define
 * your own if you want (identifier method)
 */
+ (UITableViewCell *)tableViewCellFromXibFileWithName:(NSString *)xibFileName forTableView:(UITableView *)tableView;

/**
 * Factory method for creating a standard table view programmatically without a xib
 */
+ (UITableViewCell *)tableViewCellWithStyle:(UITableViewCellStyle)style forTableView:(UITableView *)tableView;

/**
 * Convenience method for cell skinning
 */
- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName;

/**
 * The cell identifier to use for cell reuse. You can override this method if you do really want to define your
 * own identifier in a subclass, otherwise just stick with the default implementation (which uses the class name
 * as cell identifier)
 */
+ (NSString *)identifier;

/**
 * Override this method to set the height of your custom cell class if not the default one (44.f). This has to
 * be done whether the cell is created programmatically or using a xib file
 */
+ (CGFloat)height;

@end
