//
//  Coconut.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface Coconut : NSObject {
@private
    NSString *m_name_en;
    NSString *m_name_fr;
    NSString *m_thumbnailImageName;
}

// Parse a properly formatted dictionary and extracts Coconut objects defined within it. For the sake
// of simplicity, this method does not perform any data validation
+ (NSArray *)coconutsFromDictionary:(NSDictionary *)dictionary;

// Return the localized name
@property (nonatomic, readonly, retain) NSString *name;

@property (nonatomic, readonly, retain) NSString *thumbnailImageName;

@end
