//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Töre Çağrı Uyar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  TCUTypeSafeCollection.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

@import Foundation;

#import "TCUObjectTransformer.h"
#import "TCUPropertyAttributes.h"

/**
 @brief @b TCUTypeSafeCollection is a collection ensuring dynamic properties of subclasses will contain either right typed value or nil. Custom initialization method @b -[TCUTypeSafeCollection initWithDictionary] will auto map values on passed @b NSDictionary to dynamic properties of subclass.
 
 A simple subclass example:
 
 @code
 
 @interface SubClass : TCUTypeSafeCollection
 
 @property (nonatomic) NSString *name;
 @property (nonatomic) NSArray *arrayOfSubclassedObjecs;
 
 @end
 
 @implementation SubClass
 
 @dynamic name, arrayOfSubclassedObjecs; // TCUTypeSafeCollection only works with dynamic properties.
 
 + (void)initialize {
     [super initialize];
     [self setPropertyToKeyMappingTable:@{NSStringFromSelector(@selector(name)) : @"Name", // Mapping value of key 'Name' on dictionary to 'name' property. SubClass.name = NSDictionary[@"Name"];
                                          NSStringFromSelector(@selector(arrayOfSubclassedObjecs)) : @"SubObjects"}]; // Mapping value of key 'SubObjects' on dictionary to 'arrayOfSubclassedObjecs' property.
     [self setArrayToClassMappingTable:@{NSStringFromSelector(@selector(arrayOfSubclassedObjecs)) : [SubClass class]}]; // Stating 'arrayOfSubclassedObjecs' property is an NSArray and objects contained in array should be transformed to type [SubClass class]. Transformation will be done automatically as long as tpye is also a subclass of TCUTypeSafeCollection.
 }
 
 @end
 
 + (void)initializeAndTestSubClass { // This class method intended for demonstration purposes only. This method is not required on subclasses.
     SubClass *testObject = [[SubClass alloc] initWithDictionary:@{@"Name" : @"Example",
                                                                   @"SubObjects" : @[@{@"Name" : @"SubObject 1"},
                                                                                     @{@"Name" : @"SubObject 2"},
                                                                                     @{@"Name" : @"SubObject 3"}]}];
     NSLog(@"Name of test object: %@", testObject.name);
     forin (NSString *name in testObject.arrayOfSubclassedObjecs) {
         NSLog(@"Name of test object: %@", name);
     }
 }
 
 @endcode
 */
@interface TCUTypeSafeCollection : NSObject <NSCopying>

+ (NSMutableDictionary *)propertyToJSONKeyMappingTable;
+ (NSMutableDictionary *)arrayToClassMappingTable;
+ (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable;
+ (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable;
- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;
- (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;

+ (NSMutableArray *)objectTransformers;
+ (NSMutableDictionary *)objectTransformersPerProperty;
+ (void)setObjectTransformers:(NSArray *)objectTransformers append:(BOOL)append;
+ (void)setObjectTransformersPerProperty:(NSDictionary *)objectTransformersPerProperty append:(BOOL)append;
- (void)setObjectTransformers:(NSArray *)objectTransformers preserveClassLevelTransformers:(BOOL)preserve;
- (void)setObjectTransformersPerProperty:(NSDictionary *)objectTransformersPerProperty preserveClassLevelTransformers:(BOOL)preserve;
+ (BOOL)canTransfromObject:(NSObject *)object toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName;
- (BOOL)canTransfromObject:(NSObject *)object toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName;
+ (TCUObjectTransformer *)transfromerForObject:(NSObject *)object toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName;
- (TCUObjectTransformer *)transfromerForObject:(NSObject *)object toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName;

- (id)getProperty:(NSString *)propertyName;
- (void)setProperty:(NSString *)propertyName object:(id)object;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)setDataWithDictionary:(NSDictionary *)dict;

- (instancetype)eagerTransform;

- (NSDictionary *)dictionaryWithNullForNils:(BOOL)nullForNils;
- (NSDictionary *)dictionary;

- (BOOL)shouldSetObject:(id)object forProperty:(NSString *)propertyName;
- (id)willSetObject:(id)object forProperty:(NSString *)propertyName;
- (void)didSetObject:(id)object forProperty:(NSString *)propertyName;

- (id)willTransformObject:(id)object forProperty:(NSString *)propertyName;
- (id)didTransformObject:(id)inboundObject forProperty:(NSString *)propertyName toObject:(id)transformedObject;
- (id)transformObject:(id)inboundObject toClass:(Class)classType forProperty:(NSString *)propertyName;
- (BOOL)shouldTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName;
- (id)willTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName;
- (id)didTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName toObject:(id)transformedObject;

- (id)storeObject:(id)object forPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)retrieveObjectForPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (void)cleanStore;

@end
