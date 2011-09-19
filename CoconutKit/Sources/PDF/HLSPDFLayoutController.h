//
//  HLSPDFLayoutController.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSPDFLayout.h"

/**
 * Manage the layout of a PDF output in a way similar as a UIViewController. A nib file can be used to create
 * the layout. Subclass HLSPDFLayoutController to define you custom layout. The layout can either be defined 
 * using a nib file (see the nibName method documentation). The layout can also be defined programmatically by 
 * implementing the loadLayout method, as for a view controller.
 *
 * Designated initializer: init
 */
@interface HLSPDFLayoutController : NSObject {
@private
    HLSPDFLayout *m_layout;
    BOOL m_layoutLoaded;
}

/**
 * Return the main layout element, start of the layout hierarchy. Setting this property manually must only be 
 * done if you are creating your layout programmatically in loadLayout 
 */
@property (nonatomic, retain) IBOutlet HLSPDFLayout *layout;

/**
 * By default, return the name of the layout class. This method is called when locating the nib file to
 * use for the layout. You usually do not need to override it, unless you want to use a nib with a name
 * different from the class name
 */
- (NSString *)nibName;

/**
 * This method is called when the layout property is first accessed, and loads the layout lazily. If you
 * are creating your layout programmatically, this is where you add layout elements. You are also responsible
 * of setting the layout property in it so that it points to the layout you built
 */
- (void)loadLayout;

/**
 * Return YES iff the layout has already been lazily loaded
 */
- (BOOL)isLayoutLoaded;

/**
 * This method is called after the layout has been loaded. You can use it for further customization, e.g.
 * localization purposes. Always call the super method first
 */
- (void)layoutDidLoad;

/**
 * Generate the PDF data and return it (or nil on failure)
 */
- (NSData *)generatePDFData;

/**
 * Generate the PDF file and saves it to the specified location. Return YES iff successful
 */
- (BOOL)generateAndSavePDFFileToPath:(NSString *)path;

@end
