//
//  HLSStandardTableViewCell+Protected.h
//  nut
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Just to be used by subclasses of HLSStandardTableViewCell within the nut framework (the ones needing
 * access to styles). Not to be published in the library public headers
 */
@interface HLSStandardTableViewCell (Protected)

+ (UITableViewCellStyle)style;

@end
