//
//  HLSStandardTableViewCell.h
//  nut
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Convenience factory macro for creating a custom cell of a given class using a xib having the same name as the class
// Example: SomeCellClass *cell = CUSTOM_TABLE_VIEW_CELL_FROM_XIB(SomeCellClass, tableView)
#define CUSTOM_TABLE_VIEW_CELL_FROM_XIB(className, tableView) \
    (className *)[className tableViewCellFromXibFileWithName:@#className forTableView:tableView]

// Convenience factory macro for creating a custom cell of a given class using a xib with arbitrary name
// Example: SomeCellClass *cell = CUSTOM_TABLE_VIEW_CELL_FROM_XIB_WITH_NAME(SomeCellClass, tableView, @"CellLayout")
#define CUSTOM_TABLE_VIEW_CELL_FROM_XIB_WITH_NAME(className, tableView, xibFileName) \
    (className *)[className tableViewCellFromXibFileWithName:xibFileName forTableView:tableView]

// Convenience factory macro for creating a custom cell programmatically without a xib (cell created with default style)
// Example: SomeCellClass *cell = CUSTOM_TABLE_VIEW_CELL_PROGRAMMATICALLY(SomeCellClass, tableView)
#define CUSTOM_TABLE_VIEW_CELL_PROGRAMMATICALLY(className, tableView) \
    (className *)[className tableViewCellWithStyle:UITableViewCellStyleDefault forTableView:tableView]

// Convenience factory macro for retrieving the height of a custom cell
#define CUSTOM_TABLE_VIEW_CELL_HEIGHT(className)                                            [className height]

// Convenience factory macro for creating a simple cell (= not from a subclass). No need for subclassing HLSStandardTableViewCell, but with limited customization abilities
// Example: SomeCellClass *cell = SIMPLE_TABLE_VIEW_CELL_PROGRAMMATICALLY(UITableViewCellStyleSubtitle, tableView)
#define SIMPLE_TABLE_VIEW_CELL_PROGRAMMATICALLY(style, tableView) \
    (HLSStandardTableViewCell *)[HLSStandardTableViewCell tableViewCellWithStyle:style forTableView:tableView]

// Convenience factory macro for retrieving the height of a simple cell
#define SIMPLE_TABLE_VIEW_CELL_HEIGHT()                                                     [HLSStandardTableViewCell height]

/**
 * Class for easier table view cell creation. Using this class, you avoid having to code the cell reuse mechanism
 * every time you instantiate cells. This class also forces centralization of common class cell properties.
 *
 * To create custom cells, just inherit from this class. The subclass can override the height and identifier methods
 * if it needs to. Subclasses may layout their content either through code or using a xib file. Two kinds of factory
 * macros are provided to support these cases.
 *
 * Note that subclassing HLSStandardTableViewCell is not necessary if you do not need cell customization ("simple cell"). 
 * In such cases, you can simply instantiate HLSStandardTableViewCell objects using the simple cell factory macros.
 *
 * Designated initializer: initWithStyle:reuseIdentifier:
 * (You usually do not need to create a cell manually. Use the factory macros instead)
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
