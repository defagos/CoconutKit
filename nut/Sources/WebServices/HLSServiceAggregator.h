//
//  HLSServiceAggregator.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceAnswer.h"
#import "HLSServiceRequest.h"

/**
 * "Pure virtual" methods
 */
@protocol HLSServiceAggregatorAbstract <NSObject>

@optional
- (HLSServiceRequest *)aggregateRequests:(NSArray *)requests;                                                  // array of HLSServiceRequest objects

/**
 * The method must return an NSError object if an error has been encountered. If no answer has been found as a result
 * of the disaggregation, the function is free to return either nil or an empty array.
 */
- (NSArray *)disaggregateAnswer:(HLSServiceAnswer *)aggregatedAnswer didFailWithError:(NSError **)pError;      // must return an array of HLSServiceAnswer objects

/**
 * This method must return an array containing all NSString ids which have been aggregated into the request id
 * specified as parameter
 */
- (NSArray *)requestIdsForAggregatedRequestId:(NSString *)aggregatedRequestId;

@end

/**
 * An aggregator defines the logic for aggregating several request bodies into one single request
 * which will be submitted to the web service in a single batch. This step can also be used 
 * to add any additional information if needed (e.g. header, enclosing XML tags, etc.).
 *
 * Moreover, the aggregator is called for the inverse operation on answers returned by the web 
 * service.
 *
 * You must always customize the aggregator behavior in such a way that to each sub-request id 
 * which was aggregated corresponds an answer with the same id after disaggregation.
 *
 * Usually each request sent to a web service is tagged with some unique id which the server
 * uses to tag the corresponding answer as well, so this process is quite straightforward. In other
 * cases you might need to store information about requests when aggregating in order to be able
 * to disaggregate the corresponding answers.
 *
 * You do not instantiate an aggregator yourself. This step is performed by the service broker
 * which uses it. The broker calls the init method, that is why you must not define another
 * initializer in subclasses (it would never be called).
 *
 * Designated initializer: init
 */
@interface HLSServiceAggregator : NSObject <HLSServiceAggregatorAbstract> {
@private
    
}

@end
