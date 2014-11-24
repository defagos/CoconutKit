//
//  NSManagedObject+HLSValidation.m
//  CoconutKit
//
//  Created by Samuel Défago on 19.11.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "NSManagedObject+HLSValidation.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSModelManager.h"
#import "HLSRuntime.h"
#import "NSDictionary+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"

#import <objc/runtime.h>

// Return YES iff injection has been enabled. External linkage, but not public
BOOL injectedManagedObjectValidation(void);

// Variables with internal linkage
static BOOL s_injectedManagedObjectValidation = NO;

// Original implementation of the methods we swizzle
static void (*s_NSManagedObject__initialize_Imp)(id, SEL) = NULL;

// Swizzled method implementations
static void swizzled_NSManagedObject__initialize_Imp(Class self, SEL _cmd);

// Static helper functions
static Method instanceMethodOnClass(Class class, SEL sel);
static SEL checkSelectorForValidationSelector(SEL sel);
static BOOL validateProperty(id self, SEL sel, id *pValue, NSError **pError);
static BOOL validateObjectConsistency(id self, SEL sel, NSError **pError);
static BOOL validateObjectConsistencyInClassHierarchy(id self, Class class, SEL sel, NSError **pError);

#pragma mark -
#pragma mark HLSValidationPrivate category interface

@interface NSManagedObject (HLSValidationPrivate)

+ (NSError *)combineError:(NSError *)newError withError:(NSError *__autoreleasing *)pExistingError;

+ (NSError *)flattenHiearchyForError:(NSError *)error;

@end

#pragma mark -
#pragma mark HLSValidation category implementation

@implementation NSManagedObject (HLSValidation)

#pragma mark Validation wrapper injection

+ (void)enableObjectValidation
{
    if (s_injectedManagedObjectValidation) {
        HLSLoggerInfo(@"Managed object validations already injected");
        return;
    }
    
    s_NSManagedObject__initialize_Imp = (void (*)(id, SEL))hls_class_swizzleClassSelector(self,
                                                                                          @selector(initialize),
                                                                                          (IMP)swizzled_NSManagedObject__initialize_Imp);
    
    s_injectedManagedObjectValidation = YES;
}

#pragma mark Checking the object

- (BOOL)checkValue:(id)value forKey:(NSString *)key error:(NSError *__autoreleasing *)pError
{
    NSAssert(injectedManagedObjectValidation(), @"Managed object validation not injected. Call HLSEnableNSManagedObjectValidation first");
    
    // Remark: Do not invoke validation methods directly. Use validateValue:forKey:error: with a key. This guarantees
    //         that any validation logic in the xcdatamodel is also triggered
    //         See http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdValidation.html
    // (remark: The code below also deals correctly with &nil)
    return [self validateValue:&value forKey:key error:pError];
}

- (BOOL)check:(NSError *__autoreleasing *)pError
{
    return [self validateForInsert:pError];
}

#pragma mark Global validation method stubs

- (BOOL)checkForConsistency:(NSError *__autoreleasing *)pError
{
    return YES;
}

- (BOOL)checkForDelete:(NSError *__autoreleasing *)pError
{
    return YES;
}

@end

#pragma mark -
#pragma mark HLSValidationPrivate category implementation

@implementation NSManagedObject (HLSValidationPrivate)

#pragma mark Combining Core Data errors correctly

/**
 * Combine a new error with an existing error. This function implements the approach recommended in the Core Data
 * programming guide, see
 *   http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdValidation.html
 * This method was originally intended to be made public (to make error combination easy when implementing
 * custom validation methods), but I discovered a strange Core Data issue. Consider a field for which you have
 * implemented a method returning an NSValidationMultipleErrorsError. If a validation defined for the same
 * field, but in the xcdatamodel file, returns an error, Core Data has issues combining the multiple error
 * with this error, and crashes (an immutable array is altered somewhere in the Core Data runtime, throwing an
 * exception).
 *
 * This brought me to the conclusion that NSValidationMultipleErrorsError should be reserved, that is why the
 * method below has been made private. If you need to return several errors from a validation method implementation,
 * you should define your own error code playing the same role as NSValidationMultipleErrorsError.
 *
 * The method returns the combined error both by reference as well as return value.
 */
+ (NSError *)combineError:(NSError *)newError withError:(NSError *__autoreleasing *)pExistingError
{    
    // If the caller is not interested in errors, nothing to do
    if (! pExistingError) {
        return nil;
    }
    
    // If no new error, nothing to do
    if (! newError) {
        return *pExistingError;
    }
    
    // An existing error is already available. Combine as multiple error
    if (*pExistingError) {
        // Already a multiple error. Add the new error to the list (this can only be done cleanly by creating a new error object)
        NSDictionary *userInfo = nil;
        if ([*pExistingError hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]) {
            userInfo = [*pExistingError userInfo];
            NSArray *errors = [userInfo objectForKey:NSDetailedErrorsKey];
            errors = [errors arrayByAddingObject:newError];
            userInfo = [userInfo dictionaryBySettingObject:errors forKey:NSDetailedErrorsKey];            
        }
        // Not a multiple error yet. Combine into a multiple error
        else {
            NSArray *errors = @[*pExistingError, newError];
            userInfo = @{ NSDetailedErrorsKey : errors };
        }
        
        // Fill with error object (code in the NSCocoaErrorDomain domain)
        *pExistingError = [NSError errorWithDomain:NSCocoaErrorDomain 
                                              code:NSValidationMultipleErrorsError 
                                          userInfo:userInfo];
    }
    // No error yet, just fill with the new error
    else {
        *pExistingError = newError;
    }
    
    return *pExistingError;
}

/**
 * When performing all individual validations in a row in -[NSManagedObject validateForInsert:] (and similar
 * methods), Core Data considers fields in alphabetical order. When errors are discovered for two or more
 * fields, Core Data combines them into an NSValidationMultipleErrorsError error. There is an issue, though:
 * In some very specific cases, the resulting error hierarchy may depend on the alphabetical order of the
 * involved fields, namely when a field is attached several validation criteria using the Core Data model
 * editor (xcdatamodel file).
 *
 * Consider for example a model object with the following fields and validations:
 *   - fieldStringA: mandatory string field according to the xcadatamodel
 *   - fieldStringB: string field with a maximum length and which must match some regex pattern
 * In this case, if fieldStringA is omitted, and if a string which is too long and does not match the regex
 * is provided for fieldStringB, Core Data returns the following error hierarchy (the errors embedded into
 * a NSValidationMultipleErrorsError error are stored using the NSDetailedErrorsKey key of the userInfo
 * dictionary):
 *
 * NSValidationMultipleErrorsError ----- NSValidationMissingMandatoryPropertyError                                      (validation of fieldStringA)
 *                                   |
 *                                   \-- NSValidationMultipleErrorsError ----- NSValidationStringTooLongError           (validation of fieldStringB)
 *                                                                         |                                                
 *                                                                         \-- NSValidationStringPatternMatchingError   (validation of fieldStringB)
 *
 * This error hierarchy was built as follows:
 *   - fieldStringA is validated, generating a NSValidationMissingMandatoryPropertyError
 *   - fieldStringB is validated. Two errors are generated, combined by Core Data into a NSValidationMultipleErrorsError.
 *     Since we already have an error after having validated fieldStringA, this NSValidationMultipleErrorsError is combined
 *     with the existing NSValidationMissingMandatoryPropertyError into another NSValidationMultipleErrorsError level
 *
 * If we now rename fieldStringA as fieldStringC, we have:
 *   - fieldStringB: string field with a maximum length and which must match some regex pattern
 *   - fieldStringC: mandatory string field according to the xcadatamodel
 * Though the situation is completely the same (after all, we just renamed a field), the error hierarchy returned by Core 
 * Data is completely different:
 * 
 * NSValidationMultipleErrorsError ----- NSValidationStringTooLongError              (validation of fieldStringB)
 *                                   |
 *                                   |-- NSValidationStringPatternMatchingError      (validation of fieldStringB)
 *                                   |
 *                                   \-- NSValidationMissingMandatoryPropertyError   (validation of fieldStringC)
 *
 * This error hierarchy was built as follows:
 *   - fieldStringB is validated, generating two errors combined as a NSValidationMultipleErrorsError
 *   - fieldStringC is validated, generating a NSValidationMissingMandatoryPropertyError error. Since we already have
 *     a NSValidationMultipleErrorsError error, this error is simply added as third error to the existing list
 *
 * Of course, this behavior is quite annoying and inconsistent. In general, we should expect Core Data to return
 * either:
 *   - a single error
 *   - or a NSValidationMultipleErrorsError error, with all embedded errors at the same level (as in the
 *     fieldStringB/C example)
 *
 * The purpose of the following method is therefore to flatten out the error hierarchy to remove those inconsistencies,
 * returning the flattened error as a result
 */
+ (NSError *)flattenHiearchyForError:(NSError *)error
{
    // Nothing to flatten
    if (! [error hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]) {
        return error;
    }
    
    // Extract the error list (should be one since this method is meant to flatten out errors returned by the
    // Core Data runtime)
    NSDictionary *userInfo = [error userInfo];
    NSArray *errors = [userInfo objectForKey:NSDetailedErrorsKey];
    if ([errors count] == 0) {
        HLSLoggerWarn(@"Error with code NSValidationMultipleErrorsError, but no error list found");
        return error;
    }
    
    // Flatten out errors if necessary
    BOOL flattened = NO;
    NSArray *flattenedErrors = @[];
    for (NSError *error in errors) {
        // Not a nested mulitple error. Nothing to do
        if (! [error hasCode:NSValidationMultipleErrorsError withinDomain:NSCocoaErrorDomain]) {
            flattenedErrors = [flattenedErrors arrayByAddingObject:error];
            continue;
        }
        
        // Flatten out nested errors
        NSArray *errorsInError = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if ([errorsInError count] != 0) {
            flattenedErrors = [flattenedErrors arrayByAddingObjectsFromArray:errorsInError];
        }
        
        flattened = YES;
    }
    
    // Nothing to flatten. Return the original error
    if (! flattened) {
        return error;
    }
    
    // Return the flattened error
    userInfo = [userInfo dictionaryBySettingObject:flattenedErrors forKey:NSDetailedErrorsKey];
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError 
                           userInfo:userInfo];
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
            free(methods);
            return method;
        }
    }
    free(methods);
    return NULL;
}

/**
 * Return the check selector associated with a validation selector
 */
static SEL checkSelectorForValidationSelector(SEL sel)
{
    // Special cases of global validation for insert / update: One common method since always identical
    NSString *selectorName = @(sel_getName(sel));
    if ([selectorName isEqualToString:@"validateForInsert:"] || [selectorName isEqualToString:@"validateForUpdate:"]) {
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
    BOOL (*checkImp)(id, SEL, id, NSError *__autoreleasing *) = (BOOL (*)(id, SEL, id, NSError *__autoreleasing *))method_getImplementation(method);
    
    // Check
    NSError *newError = nil;
    id value = pValue ? *pValue : nil;
    if (! (*checkImp)(self, checkSel, value, &newError)) {
        if (! newError) {
            HLSLoggerWarn(@"The %s method returns NO but no error. The method implementation is incorrect", sel_getName(checkSel));
        }
        [NSManagedObject combineError:newError withError:pError];
        return NO;
    }
    else if (newError) {
        HLSLoggerWarn(@"The %s method returns YES but also an error. The error has been discarded, but the method "
                      "implementation is obviously incorrect. Fix it", sel_getName(checkSel));
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
 * -[NSManagedObject validateForInsert:] methods are namely where individual validations get called!
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
        BOOL (*imp)(id, SEL, NSError *__autoreleasing *) = (BOOL (*)(id, SEL, NSError *__autoreleasing *))class_getMethodImplementation(class, sel);
        
        // Validate. This is where individual validations are triggered
        NSError *newError = nil;
        if (! (*imp)(self, sel, &newError)) {
            // Make the error hierarchy returned by Core Data flat in all cases
            newError = [NSManagedObject flattenHiearchyForError:newError];
            
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
        BOOL (*checkImp)(id, SEL, NSError *__autoreleasing *) = (BOOL (*)(id, SEL, NSError *__autoreleasing *))method_getImplementation(method);
        NSError *newCheckError = nil;
        if (! (*checkImp)(self, checkSel, &newCheckError)) {
            if (! newCheckError) {
                HLSLoggerWarn(@"The %s method returns NO but no error. The method implementation is incorrect", sel_getName(checkSel));
            }
            [NSManagedObject combineError:newCheckError withError:pError];
            valid = NO;
        }
        else if (newCheckError) {
            HLSLoggerWarn(@"The %s method returns YES but also an error. The error has been discarded, but the method "
                          "implementation is incorrect", sel_getName(checkSel));
        }
        
        return valid;
    }
}

#pragma mark Swizzled method implementations

/**
 * Inject validation wrappers into managed object classes automagically.
 *
 * Registering validation wrappers in +load does not work here, because the load method is executed once for the category. Since we 
 * need to inject code in each model object class, we must do it in +initialize since this method will be called for each subclass. 
 * We could have implemented +load to run over all classes, finding out which ones are managed object classes, then injecting validation
 * wrappers, but swizzling +initialize is conceptually better: It namely would behave well if classes were also added at runtime
 * (this would not be the case with +load which would already have been executed)
 *
 * Note that we cannot have an +initialize method in a category (it would prevent any +initialize method defined on the class from 
 * being called, and here there exists such a method on NSManagedObject; it is here also extremely important to call this existing
 * initialize method, otherwise the Core Data runtime will be incomplete and silly crashes will occur at runtime). We therefore must 
 * swizzle the existing +initialize method instead and call the existing implementation first.
 */
static void swizzled_NSManagedObject__initialize_Imp(Class self, SEL _cmd)
{
    // Call swizzled implementation
    (*s_NSManagedObject__initialize_Imp)(self, _cmd);
    
    // No class identity test here. This must be executed for all objects in the hierarchy rooted at NSManagedObject, so that we can
    // locate the @dynamic properties we are interested in (those which need validation)
    
    // Inject validation methods for each managed object property
    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList(self, &numberOfProperties);
    BOOL added = NO;
    for (unsigned int i = 0; i < numberOfProperties; ++i) {
        objc_property_t property = properties[i];
        
        // Only dynamic properties must be considered (i.e. properties generated by Core Data)
        NSArray *attributes = [@(property_getAttributes(property)) componentsSeparatedByString:@","];
        if (! [attributes containsObject:@"D"]) {
            continue;
        }
        
        // Get the property name
        NSString *propertyName = @(property_getName(property));
        if ([propertyName length] == 0) {
            HLSLoggerError(@"Missing property name");
            continue;
        }
        
        // Add the validation method Core Data expects for this field. Signature is
        //   - (BOOL)validate<fieldName>:(id *)pValue error:(NSError *__autoreleasing *)pError
        NSString *validationSelectorName = [NSString stringWithFormat:@"validate%@%@:error:", [[propertyName substringToIndex:1] uppercaseString], 
                                            [propertyName substringFromIndex:1]];
        if (! class_addMethod(self, 
                              NSSelectorFromString(validationSelectorName),         // Remark: (SEL)[validationSelectorName cStringUsingEncoding:NSUTF8StringEncoding] 
                              // does NOT work (returns YES, but IMP does not get called since the selector has not 
                              // been properly registered in this case)
                              (IMP)validateProperty, 
                              "c@:^@@")) {
            HLSLoggerError(@"Failed to add %@ method dynamically", validationSelectorName);
            continue;
        }
        
        HLSLoggerDebug(@"Automatically added validation wrapper %@ on class %@", validationSelectorName, self);
        
        added = YES;
    }
    free(properties);
    
    // If at least one validation method was injected (i.e. if there are fields to validate), we must also inject a global validation
    if (added) {
        if (! class_addMethod(self, 
                              @selector(validateForInsert:), 
                              (IMP)validateObjectConsistency,
                              "c@:@")) {
            HLSLoggerError(@"Failed to add validateForInsert: method dynamically");
        }
        if (! class_addMethod(self, 
                              @selector(validateForUpdate:), 
                              (IMP)validateObjectConsistency,
                              "c@:@")) {
            HLSLoggerError(@"Failed to add validateForUpdate: method dynamically");
        }        
        if (! class_addMethod(self, 
                              @selector(validateForDelete:), 
                              (IMP)validateObjectConsistency,
                              "c@:@")) {
            HLSLoggerError(@"Failed to add validateForDelete: method dynamically");
        }
    }    
}
