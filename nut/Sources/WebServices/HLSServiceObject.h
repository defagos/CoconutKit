//
//  HLSServiceObject.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSServiceObject;

/**
 * Model objects filled using a web service must be characterized through a unique
 * string identifier. If your model object class does not need to inherit from
 * another class, simply derive from HLSServiceObject for getting the behavior you
 * need. If you do not have this freedom, implement the HLSServiceObject protocol
 * below.
 *
 * Designated initializer: initWithId:
 */
@interface HLSServiceObject : NSObject {
@private
    NSString *m_id;
}

- (id)initWithId:(NSString *)id;

@property (nonatomic, readonly, copy) NSString *id;

@end

/**
 * Protocol used for creation and retrieval of model objects filled using
 * a web service, which must be characterized through a unique string
 * identifier.
 */
@protocol HLSServiceObject <NSObject>

- (id)initWithId:(NSString *)id;

@property (nonatomic, readonly, copy) NSString *id;

@end

