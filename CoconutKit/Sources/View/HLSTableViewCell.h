//
//  HLSTableViewCell.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Class for easy table view cell creation. Using this class, you avoid having to code the cell reuse mechanism
 * every time you instantiate cells. This class also forces centralization of common cell class properties, like
 * cell identifier, dimensions, style and xib file (if any).
 *
 * If you do not need other customization properties than the ones offered by a UITableViewCell with default style
 * (UITableViewCellStyleDefault), you can simply instantiate HLSTableViewCell by calling the cellForTableView:
 * class method on it. Other simple table view cells also exist for the other built-in cell styles (HLSValue1TableViewCell,
 * HLSValue1TableViewCell and HLSSubtitleTableViewCell). Those are similarly instantiated using the factory class method.
 *
 * If you need further customization abilities, like cells whose layout is defined using a xib or programmatically, 
 * you must sublcass HLSTableViewCell and:
 *   - if your cell layout is created using a xib file not bearing the same name as the cell class, override the
 *     nibName accessor to return the name of the xib file. If the xib file bears the same name as its
 *     corresponding class or if your cell layout is created programmatically, do not override this accessor
 *   - override the identifier method to return the cell identifier used by the reuse mechanism if the default value
 *     (the class name) does not suit your needs, which should be rarely the case
 * Custom classes can then be instantiated by calling the cellForTableView: class method on your cell classes.
 *
 * Be careful when using a xib. Resource lookup is case-insensitive when running in the simulator, and case-sensitive
 * on the device.
 *
 * To customize your cells via code after they have been loaded from a xib, implement the awakeFromNib method.
 *
 * When your class uses a xib to define its layout:
 *   - the first object in the xib must be the cell object. Do not forget to set its type to match your cell class name
 *     (if you need to bind outlets). Use this class as origin when drawing bindings (do not use the file's owner)
 *   - do not forget to set the cell identifier to the one returned by the identifier class method. By default this
 *     identifier is the class name, except if your class overrides it. If you fail to do so, the reuse mechanism
 *     will not work
 *
 * Designated initializer: initWithStyle:reuseIdentifier:
 * (You usually do not need to create a cell manually. Use the factory macros instead)
 */
@interface HLSTableViewCell : UITableViewCell {
@private

}

/**
 * Factory method for creating a table view cell. Return an instance of the class it is called on
 * Not meant to be overridden
 */
+ (id)cellForTableView:(UITableView *)tableView;

/**
 * Obtaining a cell with custom background and selected background images is surprisingly not so easy, especially if
 * you want to use Interface Builder as much as possible when designing your cells. Instead, I recommend setting 
 * cell backgrounds as follows:
 *   - if you use Interface Builder: Define the cell layout, and set its selection style to "Blue". Then call the
 *     method setBackgroundWithImageNamed:selectedBackgroundWithImageName: in the awakeFromNib method of your cell
 *     implementation, passing it the images you want to use
 *   - if you are creating the cell completely in code: Set the selection style to UITableViewCellSelectionStyleBlue
 *     and call the method setBackgroundWithImageNamed:selectedBackgroundWithImageName: in the initWithStyle:reuseIdentifier:, 
 *     method of your cell implementation, passing it the images you want to use
 * Setting a selection style is important since otherwise the selected background image would not be displayed
 * when the cell is highlighted / selected. Also note that, unlike buttons, the image of the highlighted and
 * selected states is always the same.
 *
 * If you are curious, here is a way to define both the normal and selected state images completely in Interface
 * Builder (warning: ugliness inside):
 *   - create a cell, set its selection style to "Blue"
 *   - add a UIImageView as cell subview. Set the normal background image as image property, and the selected 
 *     background image as highlighted image property of the UIImageView. When the cell gets selected or highlighted, 
 *     the image view will be highlighted as well, yielding the desired effect (well, almost. See below)
 *   - you also need to make the cell selected background image transparent as well, otherwise the cell will still be 
 *     colored in blue when selecting or highlighting it. To achieve this, simply add a UIView to your xib (next to 
 *     your cell), set its color to clear color, and bind it to the selectedBackgroundView property. This will disable
 *     the blue view which automatically gets added when setting the selection style to "Blue". 
 * IMHO, this is too tricky for such a trivial need, and I strongly suggest customizing cell images in awakeFromNib
 * using setBackgroundWithImageNamed:selectedBackgroundWithImageName:
 *
 * Not meant to be overridden
 */
- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName;

/**
 * Returns the cell dimensions
 * Not meant to be overridden
 */
+ (CGFloat)height;
+ (CGFloat)width;
+ (CGSize)size;

/**
 * If the cell layout is created using Interface Builder, override this accessor to return the name of the associated xib
 * file. This is not needed if the xib file name is identical to the class name
 */
+ (NSString *)nibName;

/**
 * The cell identifier to apply for cell reuse. You can override this method if you do really want to define your
 * own identifier in a subclass, otherwise just stick with the default implementation (which uses the class name
 * as cell identifier)
 */
+ (NSString *)identifier;

@end
