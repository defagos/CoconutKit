//
//  NSManagedObject+HLSValidation.m
//  CoconutKit
//
//  Created by Samuel Défago on 19.11.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "NSManagedObject+HLSValidation.h"

#import "HLSAssert.h"
#import "HLSCategoryLinker.h"
#import "HLSLogger.h"
#import "HLSManagedObjectValidationError.h"
#import "HLSModelManager.h"
#import "HLSRuntime.h"
#import "NSDictionary+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "UITextField+HLSValidation.h"

#import <objc/runtime.h>

HLSLinkCategory(NSManagedObject_HLSValidation)

// Return YES iff injection has been enabled. External linkage, but not public
BOOL injectedManagedObjectValidation(void);

// Variables with internal linkage
static BOOL s_injectedManagedObjectValidation = NO;

// Original implementation of the methods we swizzle
static void (*s_NSManagedObject_HLSExtensions__initialize_Imp)(id, SEL) = NULL;

// Static helper functions
static Method instanceMethodOnClass(Class class, SEL sel);
static SEL checkSelectorForValidationSelector(SEL sel);
static BOOL validateProperty(id self, SEL sel, id *pValue, NSError **pError);
static BOOL validateObjectConsistency(id self, SEL sel, NSError **pError);
static BOOL validateObjectConsistencyInClassHierarchy(id self, Class class, SEL sel, NSError **pError);

#pragma mark -
#pragma mark HLSValidationPrivate category interface

@interface NSManagedObject (HLSValidationPrivate)

+ (void)swizzledInitialize;

@end

#pragma mark -
#pragma mark HLSValidation category implementation

@implementation NSManagedObject (HLSValidation)

#pragma mark Validation wrapper injection

+ (void)injectValidation
{
    if (s_injectedManagedObjectValidation) {
        HLSLoggerInfo(@"Managed object validations already injected");
        return;
    }
    
    s_NSManagedObject_HLSExtensions__initialize_Imp = (void (*)(id, SEL))HLSSwizzleClassSelector([NSManagedObject class], @selector(initialize), @selector(swizzledInitialize));
    
    s_injectedManagedObjectValidation = YES;
}

#pragma mark Combining Core Data errors correctly

+ (void)combineError:(NSError *)newError withError:(NSError **)pExistingError
{
    // If no new error, nothing to do
    if (! newError) {
        return;
    }
    
    // If the caller is not interested in errors, nothing to do
    if (! pExistingError) {
        return;
    }
    
    // An existing error is already available. Combine as multiple error
    if (*pExistingError) {
        // Already a multiple error. Add the new error to the list (this can only be done cleanly by creating a new error object)
        NSDictionary *userInfo = nil;
        if ([*pExistingError code] == NSValidationMultipleErrorsError && [[*pExistingError domain] isEqualToString:NSSQLiteErrorDomain]) {
            userInfo = [*pExistingError userInfo];
            NSArray *errors = [userInfo objectForKey:NSDetailedErrorsKey];
            errors = [errors arrayByAddingObject:newError];
            userInfo = [userInfo dictionaryBySettingObject:errors forKey:NSDetailedErrorsKey];            
        }
        // Not a multiple error yet. Combine into a multiple error
        else {
            NSArray *errors = [NSArray arrayWithObjects:*pExistingError, newError, nil];
            userInfo = [NSDictionary dictionaryWithObject:errors forKey:NSDetailedErrorsKey];
        }
        
        // Fill with error object (code in the NSSQLiteErrorDomain domain; cannot use HLSError here)
        *pExistingError = [NSError errorWithDomain:NSSQLiteErrorDomain 
                                              code:NSValidationMultipleErrorsError 
                                          userInfo:userInfo];
    }
    // No error yet, just fill with the new error
    else {
        *pExistingError = newError;
    }
}

#pragma mark Checking the object

- (BOOL)checkValue:(id)value forKey:(NSString *)key error:(NSError **)pError
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    // Remark: Do not invoke validation methods directly. Use validateValue:forKey:error: with a key. This guarantees
    //         that any validation logic in the xcdatamodel is also triggered
    //         See http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdValidation.html
    // (remark: The code below also deals correctly with &nil)
    BOOL valid = [self validateValue:&value forKey:key error:pError];
    
    if ([*pError code] == NSValidationMultipleErrorsError && [[*pError domain] isEqualToString:NSSQLiteErrorDomain]) {
        NSArray *errors = [[*pError userInfo] objectForKey:NSDetailedErrorsKey];
        *pError = [HLSManagedObjectValidationError errorWithManagedObject:self 
                                                                fieldName:key 
                                                                   errors:errors];
    }
    else {
        *pError = [HLSManagedObjectValidationError errorWithManagedObject:self
                                                                fieldName:key
                                                                    error:*pError];
    }
    
    return valid;
}

- (BOOL)check:(NSError **)pError
{
    return [self validateForInsert:pError];
}

#pragma mark Global validation method stubs

- (BOOL)checkForConsistency:(NSError **)pError
{
    return YES;
}

- (BOOL)checkForDelete:(NSError **)pError
{
    return YES;
}

@end

#pragma mark -
#pragma mark HLSValidationPrivate category implementation

@implementation NSManagedObject (HLSValidationPrivate)

/**
 * Inject validation wrappers into managed object classes automagically.
 *
 * Registering validation wrappers in +load does not work here, because the load method is executed once for the category. Since we 
 * need to inject code in each model object class, we must do it in +initialize since this method will be called for each subclass. 
 * We could have implemented +load to run over all classes, finding out which ones are managed object classes, then injecting validation
 * wrappers, but swizzling +initialize is conceptually better: It namely would behave well if classes were also added at runtime
 * (this would not be the case with +load which would already have been executed in such cases)
 *
 * Note that we cannot have an +initialize method in a category (it would prevent any +initialize method defined on the class from 
 * being called, and here there exists such a method on NSManagedObject; it is also extremely important to call it, otherwise the Core
 * Data runtime will be incomplete and silly crashes will occur at runtime. Yeah, I tried). We therefore must swizzle the existing 
 * +initialize method instead and call the existing implementation first.
 */
+ (void)swizzledInitialize
{
    // Call swizzled implementation
    (*s_NSManagedObject_HLSExtensions__initialize_Imp)([NSManagedObject class], @selector(initialize));
    
    // No class identity test here. This must be executed for all objects in the hierarchy rooted at NSManagedObject, so that we can
    // locate the @dynamic properties we are interested in (those which need validation)
    
    // Inject validation methods for each managed object property
    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList(self, &numberOfProperties);
    BOOL added = NO;
    for (unsigned int i = 0; i < numberOfProperties; ++i) {
        objc_property_t property = properties[i];
        
        // Only dynamic properties must be considered (i.e. properties generated by Core Data)
        NSArray *attributes = [[NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
        if (! [attributes containsObject:@"D"]) {
            continue;
        }
        
        // Get the property name
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName length] == 0) {
            HLSLoggerError(@"Missing property name");
            continue;
        }
        
        // Add the validation method Core Data expects for this field. Signature is
        //   - (BOOL)validate<fieldName>:(id *)pValue error:(NSError **)pError
        NSString *validationSelectorName = [NSString stringWithFormat:@"validate%@%@:error:", [[propertyName substringToIndex:1] uppercaseString], 
                                            [propertyName substringFromIndex:1]];
        NSString *types = [NSString stringWithFormat:@"%s%s%s%s%s", @encode(BOOL), @encode(id), @encode(SEL), @encode(id *), @encode(NSError *)];
        if (! class_addMethod(self, 
                              NSSelectorFromString(validationSelectorName),         // Remark: (SEL)[validationSelectorName cStringUsingEncoding:NSUTF8StringEncoding] 
                                                                                    //does NOT work (returns YES, but IMP does not get called since the selector has not 
                                                                                    //been properly registered in this case)
                              (IMP)validateProperty, 
                              [types cStringUsingEncoding:NSUTF8StringEncoding])) {
            HLSLoggerError(@"Failed to add %@ method dynamically", validationSelectorName);
            continue;
        }
        
        HLSLoggerDebug(@"Automatically added validation wrapper %@ on class %@", validationSelectorName, self);
        
        added = YES;
    }
    free(properties);
    
    // If at least one validation method was injected (i.e. if there are fields to validate), we must also inject a global validation
    if (added) {
        NSString *types = [NSString stringWithFormat:@"%s%s%s%s", @encode(BOOL), @encode(id), @encode(SEL), @encode(NSError *)];
        if (! class_addMethod(self, 
                              @selector(validateForInsert:), 
                              (IMP)validateObjectConsistency,
                              [types cStringUsingEncoding:NSUTF8StringEncoding])) {
            HLSLoggerError(@"Failed to add validateForInsert: method dynamically");
        }
        if (! class_addMethod(self, 
                              @selector(validateForUpdate:), 
                              (IMP)validateObjectConsistency,
                              [types cStringUsingEncoding:NSUTF8StringEncoding])) {
            HLSLoggerError(@"Failed to add validateForUpdate: method dynamically");
        }        
        if (! class_addMethod(self, 
                              @selector(validateForDelete:), 
                              (IMP)validateObjectConsistency,
                              [types cStringUsingEncoding:NSUTF8StringEncoding])) {
            HLSLoggerError(@"Failed to add validateForDelete: method dynamically");
        }
    }    
}

@end

#pragma mark Injection status

BOOL injectedManagedObjectValidation(void)
{
    return s_injectedManagedObjectValidation;
}

#pragma mark Utility functions

/**
 * Given a class and a selector, returns the underlying method iff it is implemented by this class (not by parent
 * classes). Unlike class_getInstanceMethod, this method returns NULL if a parent class implements the method
 */
static Method instanceMethodOnClass(Class class, SEL sel)
{
    unsigned int numberOfMethods = 0;
    Method *methods = class_copyMethodList(class, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; ++i) {
        Method method = methods[i];
        if (method_getName(method) == sel) {
            return method;
        }
    }
    return NULL;
}

/**
 * Return the check selector associated with a validation selector
 */
static SEL checkSelectorForValidationSelector(SEL sel)
{
    // Special cases of global validation for insert / update: One common method since always identical
    NSString *selectorName = [NSString stringWithCString:(char *)sel encoding:NSUTF8StringEncoding];
    if ([selectorName isEqual:@"validateForInsert:"] || [selectorName isEqual:@"validateForUpdate:"]) {
        return NSSelectorFromString(@"checkForConsistency:");
    }
    // In all other cases, the check method bears the same name as the validation method, but beginning with "check"
    else {
        NSString *checkSelectorName = [selectorName stringByReplacingOccurrencesOfString:@"validate" withString:@"check"];
        return  NSSelectorFromString(checkSelectorName);
    }    
}

#pragma mark Validation

/**
 * Implementation common to all injected single validation methods (-validate<FieldName>:error:)
 *
 * This implementation calls the underlying check method and performs Core Data error chaining. The validation method
 * is injected in all cases, even if no corresponding check method has been defined
 */
static BOOL validateProperty(id self, SEL sel, id *pValue, NSError **pError)
{
    // If the check method does not exist, the field is valid
    SEL checkSel = checkSelectorForValidationSelector(sel);
    Method method = class_getInstanceMethod([self class], checkSel);
    if (! method) {
        return YES;
    }
    
    // Get the check method implementation
    BOOL (*checkImp)(id, SEL, id, NSError **) = (BOOL (*)(id, SEL, id, NSError **))method_getImplementation(method);
    
    // Check
    NSError *newError = nil;
    id value = pValue ? *pValue : nil;
    if (! (*checkImp)(self, checkSel, value, &newError)) {
        if (! newError) {
            HLSLoggerWarn(@"The %s method returns NO but no error. The method implementation is incorrect", (char *)checkSel);
        }
        [NSManagedObject combineError:newError withError:pError];
        return NO;
    }
    else if (newError) {
        HLSLoggerWarn(@"The %s method returns YES but also an error. The error has been discarded, but the method "
                      "implementation is obviously incorrect. Fix it", (char *)checkSel);
    }
    
    return YES;
}

/**
 * Implementation common to all injected global validation methods:
 *   -[NSManagedObject validateForInsert:]
 *   -[NSManagedObject validateForUpdate:]
 *   -[NSManagedObject validateForDelete:]
 *
 * This implementation calls the underlying check methods, performs Core Data error chaining, and ensures that these methods 
 * get consistently called along the inheritance hierarchy. This is strongly recommended by the Core Data documentation, and
 * in fact failing to do so leads to undefined behavior: The -[NSManagedObject validateForUpdate:] and 
 * -[NSManagedObject validateForInsert:] methods are namely where individual validations are called!
 */
static BOOL validateObjectConsistency(id self, SEL sel, NSError **pError)
{
    return validateObjectConsistencyInClassHierarchy(self, [self class], sel, pError);
}

/**
 * Validate the consistency of self (according to one of the three global validation methods listed above), applying to 
 * it the selector given as parameter (using the implementation defined for it by the class given as parameter). This 
 * method can therefore be used to check global object consistency at all levels of the managed object inheritance hierarchy
 */
static BOOL validateObjectConsistencyInClassHierarchy(id self, Class class, SEL sel, NSError **pError)
{
    // Top of the managed object hierarchy
    if (class == [NSManagedObject class]) {
        // Get the implementation. This method exists on NSManagedObject, no need to test if responding to selector
        BOOL (*imp)(id, SEL, NSError **) = (BOOL (*)(id, SEL, NSError **))class_getMethodImplementation(class, sel);
        
        // Validate. This is where individual validations are triggered
        NSError *newError = nil;
        if (! (*imp)(self, sel, &newError)) {
            [NSManagedObject combineError:newError withError:pError];
            return NO;
        }
        
        return YES;
    }
    // NSManagedObject subclass
    else {
        BOOL valid = YES;
        
        // Climb up the inheritance hierarchy
        NSError *newError = nil;
        if (! validateObjectConsistencyInClassHierarchy(self, class_getSuperclass(class), sel, &newError)) {
            [NSManagedObject combineError:newError withError:pError];
            valid = NO;
        }
        
        // Find whether a check method has been defined at this class hierarchy level. If none is found, valid 
        // (i.e. we do not alter the above validation status)
        SEL checkSel = checkSelectorForValidationSelector(sel);
        Method method = instanceMethodOnClass(class, checkSel);
        if (! method) {
            return valid;
        }
        
        // A check method has been found. Call the underlying check method implementation
        BOOL (*checkImp)(id, SEL, NSError **) = (BOOL (*)(id, SEL, NSError **))method_getImplementation(method);
        NSError *newCheckError = nil;
        if (! (*checkImp)(self, checkSel, &newCheckError)) {
            if (! newCheckError) {
                HLSLoggerWarn(@"The %s method returns NO but no error. The method implementation is incorrect", (char *)checkSel);
            }
            [NSManagedObject combineError:newCheckError withError:pError];
            valid = NO;
        }
        else if (newCheckError) {
            HLSLoggerWarn(@"The %s method returns YES but also an error. The error has been discarded, but the method "
                          "implementation is incorrect", (char *)checkSel);
        }
        
        return valid;
    }
}
