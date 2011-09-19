//
//  HLSPDFLayout.h
//  CoconutKit
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * An HLSPDFLayout is always the bottom of the layout hierarchy (and cannot be added elsewhere in the hierarchy).
 * It comprises three elements:
 *   - a header
 *   - a body
 *   - a footer
 * The layout does not correspond to a single page. Depending on which layout elements are found within it (most
 * notably tables), a layout can namely expand into several pages, on which the header and footer will always
 * be added.
 */
@interface HLSPDFLayout : UIView {
@private
    
}

@end
