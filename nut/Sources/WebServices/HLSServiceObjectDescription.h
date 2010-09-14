//
//  HLSServiceObjectDescription.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Describes an HLSServiceObject, i.e:
 *   - name of the corresponding Objective-C class (implementing the HLSServiceObject protocol)
 *   - unique string identifier
 *   - dictionary of fields for setting up object properties through KVC (must be compatible to setValuesForKeysWithDictionary:).
 *     This means that:
 *       - keys are field names of the Objective-C class, and value objects must have the proper type (for primitive types, you
 *         will need to use an NSNumber as wrapper)
 *       - the Objective-C class must be KVC-compliant
 *
 * Designated initializer: initWithClassName:id:body:
 */
@interface HLSServiceObjectDescription : NSObject {
@private
    NSString *m_className;
    NSString *m_id;
    NSDictionary *m_fields;
}

- (id)initWithClassName:(NSString *)className id:(NSString *)id fields:(NSDictionary *)fields;

@property (nonatomic, readonly, copy) NSString *className;
@property (nonatomic, readonly, copy) NSString *id;
@property (nonatomic, readonly, retain) NSDictionary *fields;

@end
