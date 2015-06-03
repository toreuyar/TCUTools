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
//  TCUTypeSafeCollection.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#define SuppressDeprecatedWarning(DeprecatedCode) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
DeprecatedCode \
_Pragma("clang diagnostic pop") \

#import "TCUTypeSafeCollection.h"
#import "TCUPropertyAttributes.h"

@interface TCUObjectTransformer (TCUTypeSafeCollection)

+ (TCUObjectTransformer *)dictionaryToTypeSafeCollectionTransformer;
- (id)transformedObject:(id)object toClass:(Class)transformedClass;

@end

@import ObjectiveC;

static const void *kTCUTypeSafeCollectionPropertiesKey = (void *)&kTCUTypeSafeCollectionPropertiesKey;
static const void *kTCUTypeSafeCollectionGettersKey = (void *)&kTCUTypeSafeCollectionGettersKey;
static const void *kTCUTypeSafeCollectionSettersKey = (void *)&kTCUTypeSafeCollectionSettersKey;
static const void *kTCUTypeSafeCollectionPropertyToKeyMappingTableKey = (void *)&kTCUTypeSafeCollectionPropertyToKeyMappingTableKey;
static const void *kTCUTypeSafeCollectionArrayToClassMappingTableKey = (void *)&kTCUTypeSafeCollectionArrayToClassMappingTableKey;
static const void *kTCUTypeSafeCollectionObjectTransformersKey = (void *)&kTCUTypeSafeCollectionObjectTransformersKey;

#define kClassTranformersKey @"*"

@interface TCUTypeSafeCollection () {
    __weak NSDictionary *tcuTypeSafeCollectionProperties;
    __weak NSMapTable *tcuTypeSafeCollectionGetters;
    __weak NSMapTable *tcuTypeSafeCollectionSetters;
    __weak NSMutableDictionary *tcuTypeSafeCollectionObjectTransformers;
    NSMapTable *tcuTypeSafeCollectionPropertyToKeyMappingTable;
    NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable;
    NSMutableDictionary *tcuTypeSafeCollectionData;
}

- (NSString *)keyForPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)getter:(TCUPropertyAttributes *)propertyAttributes;
- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)transformObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)transformObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeTransformed propertyAttributes:(TCUPropertyAttributes *)propertyAttributes;

- (id)serializeObject:(id)object withNullForNil:(BOOL)nullForNil;
- (NSDictionary *)dictionaryWithNullForNils:(BOOL)nullForNils propertyNamesAsKeys:(BOOL)propertyNamesAsKeys;

@end

@implementation TCUObjectTransformer (TCUTypeSafeCollection)

+ (TCUObjectTransformer *)dictionaryToTypeSafeCollectionTransformer {
    __strong static TCUObjectTransformer *_dictionaryToTypeSafeCollectionTransformer = nil;
    static dispatch_once_t dictionaryToTypeSafeCollectionTransformer;
    dispatch_once(&dictionaryToTypeSafeCollectionTransformer, ^{
        _dictionaryToTypeSafeCollectionTransformer = [[self alloc] initWithOriginalObjectClass:[NSDictionary class] transformedObjectClass:[TCUTypeSafeCollection class]];
        _dictionaryToTypeSafeCollectionTransformer.transformer = (id)^(id object) {
            return nil;
        };
        _dictionaryToTypeSafeCollectionTransformer.remrofsnart = (id)^(id object) {
            return [((TCUTypeSafeCollection *)object) dictionary];
        };
    });
    return _dictionaryToTypeSafeCollectionTransformer;
}

- (id)transformedObject:(id)object toClass:(Class)transformedClass {
    if ([object isKindOfClass:[NSDictionary class]] &&
        [[transformedClass class] isSubclassOfClass:[TCUTypeSafeCollection class]]) {
        return [[transformedClass alloc] initWithDictionary:object];
    } else {
        return [self transformedObject:object];
    }
}

@end

@implementation TCUTypeSafeCollection

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TCUTypeSafeCollection *typeSafeCollection = [[[self class] alloc] init];
    if (tcuTypeSafeCollectionPropertyToKeyMappingTable != objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey)) {
        typeSafeCollection->tcuTypeSafeCollectionPropertyToKeyMappingTable = tcuTypeSafeCollectionPropertyToKeyMappingTable;
    }
    if (tcuTypeSafeCollectionArrayToClassMappingTable != objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey)) {
        typeSafeCollection->tcuTypeSafeCollectionArrayToClassMappingTable = tcuTypeSafeCollectionArrayToClassMappingTable;
    }
    if (tcuTypeSafeCollectionObjectTransformers != objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey)) {
        typeSafeCollection->tcuTypeSafeCollectionObjectTransformers = tcuTypeSafeCollectionObjectTransformers;
    }
    for (TCUPropertyAttributes *propertyAttributes in tcuTypeSafeCollectionGetters.objectEnumerator) {
        id object = [self getter:propertyAttributes];
        if ([object conformsToProtocol:@protocol(NSCopying)]) {
            object = [object copyWithZone:zone];
        }
        [typeSafeCollection setter:object propertyAttributes:propertyAttributes];
    }
    return typeSafeCollection;
}

#pragma mark - NSKeyValueCoding

- (id)valueForKey:(NSString *)key {
    TCUPropertyAttributes *propertyAttributes = [tcuTypeSafeCollectionGetters objectForKey:key];
    if (propertyAttributes) {
        return [self getter:propertyAttributes];
    } else {
        return [super valueForKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    TCUPropertyAttributes *propertyAttributes = [tcuTypeSafeCollectionSetters objectForKey:key];
    if (propertyAttributes) {
        return [self setter:value propertyAttributes:propertyAttributes];
    } else {
        return [super setValue:value forKey:key];
    }
}

- (void)setNilValueForKey:(NSString *)key {
    TCUPropertyAttributes *propertyAttributes = [tcuTypeSafeCollectionSetters objectForKey:key];
    if (propertyAttributes) {
        return [self setter:nil propertyAttributes:propertyAttributes];
    } else {
        return [super setNilValueForKey:key];
    }
}

- (BOOL)validateValue:(inout id *)ioValue forKey:(NSString *)key error:(out NSError **)outError {
    TCUPropertyAttributes *propertyAttributes = [tcuTypeSafeCollectionGetters objectForKey:key];
    Class expectedClass = NSClassFromString(propertyAttributes.name);
    if (propertyAttributes) {
        if ([(*ioValue) isKindOfClass:expectedClass]) {
            return YES;
        } else if ([self canTransfromClass:[(*ioValue) class] toClass:expectedClass forPropertyName:propertyAttributes.name]) {
            (*ioValue) = [self transformObject:(*ioValue) toClass:expectedClass forProperty:propertyAttributes.name];
            return NO;
        } else {
            return NO;
        }
    } else {
        return [super validateValue:ioValue forKey:key error:outError];
    }
}

#pragma mark - Class

+ (void)initialize {
    [super initialize];
    if ([self class] != [TCUTypeSafeCollection class]) {
        NSDictionary *tcuTypeSafeCollectionProperties = [[self class] propertyDictionaryOfClassHierarchy];
        NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionaryWithCapacity:tcuTypeSafeCollectionProperties.count];
        [tcuTypeSafeCollectionProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, TCUPropertyAttributes *propertyAttributes, BOOL *stop) {
            if ((propertyAttributes.typeAttribute & TCUTypeAttributeObject) &&
                (propertyAttributes.propertyAttribute & TCUPropertyAttributeDynamic) &&
                (!(propertyAttributes.propertyAttribute & TCUPropertyAttributeWeak))) {
                [propertyDictionary setObject:propertyAttributes forKey:propertyName];
            }
        }];
        tcuTypeSafeCollectionProperties = [NSDictionary dictionaryWithDictionary:propertyDictionary];
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionPropertiesKey, tcuTypeSafeCollectionProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        NSMapTable *tcuTypeSafeCollectionGetters = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        [tcuTypeSafeCollectionProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, TCUPropertyAttributes *propertyAttributes, BOOL *stop) {
            NSString *getter = propertyAttributes.getter;
            if (!getter) {
                getter = propertyName;
            }
            [tcuTypeSafeCollectionGetters setObject:propertyAttributes forKey:getter];
        }];
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionGettersKey, tcuTypeSafeCollectionGetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSMapTable *tcuTypeSafeCollectionSetters = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        [tcuTypeSafeCollectionProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, TCUPropertyAttributes *propertyAttributes, BOOL *stop) {
            if (!(propertyAttributes.propertyAttribute & TCUPropertyAttributeReadonly)) {
                NSString *setter = propertyAttributes.setter;
                if (!setter) {
                    setter = [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]];
                }
                [tcuTypeSafeCollectionSetters setObject:propertyAttributes forKey:setter];
            }
        }];
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionSettersKey, tcuTypeSafeCollectionSetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSMapTable *tcuTypeSafeCollectionPropertyToKeyMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionPropertyToKeyMappingTableKey, tcuTypeSafeCollectionPropertyToKeyMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionArrayToClassMappingTableKey, tcuTypeSafeCollectionArrayToClassMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionObjectTransformersKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self setPropertyToKeyMappingTable:[self propertyToJSONKeyMappingTable]];
        [self setArrayToClassMappingTable:[self arrayToClassMappingTable]];
    }
}

+ (NSMutableDictionary *)propertyToJSONKeyMappingTable {
    return [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)arrayToClassMappingTable {
    return [NSMutableDictionary dictionary];
}

+ (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable {
    NSMapTable *selfMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
    [selfMappingTable removeAllObjects];
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [selfMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *fieldName, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && [fieldName isKindOfClass:[NSString class]]) {
                [selfMappingTable setObject:fieldName forKey:propertyName];
            }
        }];
    }
}

+ (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable {
    NSMapTable *selfMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
    [selfMappingTable removeAllObjects];
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [selfMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class classType, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && class_isMetaClass(object_getClass(classType))) {
                if ([classType isSubclassOfClass:[TCUTypeSafeCollection class]]) {
                    [selfMappingTable setObject:classType forKey:propertyName];
                }
            }
        }];
    }
}

+ (NSMutableArray *)objectTransformers {
    return [NSMutableArray array];
}

+ (NSMutableDictionary *)objectTransformersPerProperty {
    return [NSMutableDictionary dictionary];
}

+ (void)setObjectTransformers:(NSArray *)objectTransformers {
    if ([objectTransformers isKindOfClass:[NSArray class]]) {
        [self setObjectTransformersPerProperty:@{kClassTranformersKey : objectTransformers}];
    }
}

+ (void)setObjectTransformersPerProperty:(NSDictionary *)objectTransformersPerProperty {
    NSMutableDictionary *selfTransformers = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey);
    [selfTransformers removeAllObjects];
    NSMutableDictionary *superTransformers = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionObjectTransformersKey);
    [selfTransformers setValuesForKeysWithDictionary:superTransformers];
    if ([objectTransformersPerProperty isKindOfClass:[NSDictionary class]]) {
        [objectTransformersPerProperty enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSArray *transformers, BOOL *stop) {
            if ([transformers isKindOfClass:[NSArray class]]) {
                NSMutableDictionary *objectTransformersOfProperty = selfTransformers[propertyName];
                if (!objectTransformersOfProperty) {
                    objectTransformersOfProperty = [NSMutableDictionary dictionary];
                    selfTransformers[propertyName] = objectTransformersOfProperty;
                }
                for (TCUObjectTransformer *transformer in transformers) {
                    if ([transformer isKindOfClass:[TCUObjectTransformer class]]) {
                        if (transformer.originalObjectClass && transformer.transformedObjectClass) {
                            NSMutableDictionary *originalObjectKeyDict = selfTransformers[NSStringFromClass(transformer.originalObjectClass)];
                            if (!originalObjectKeyDict) {
                                originalObjectKeyDict = [NSMutableDictionary dictionary];
                                selfTransformers[NSStringFromClass(transformer.originalObjectClass)] = originalObjectKeyDict;
                            }
                            originalObjectKeyDict[NSStringFromClass(transformer.transformedObjectClass)] = transformer;
                        }
                    }
                }
            }
        }];
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        [self setDataWithDictionary:dict];
    }
    return self;
}

- (void)setDataWithDictionary:(NSDictionary *)dict {
    [tcuTypeSafeCollectionData removeAllObjects];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        for (TCUPropertyAttributes *propertyAttributes in tcuTypeSafeCollectionGetters.objectEnumerator) {
            [self setter:dict[[self keyForPropertyAttributes:propertyAttributes]] propertyAttributes:propertyAttributes];
        }
    }
}

- (id)serializeObject:(id)object withNullForNil:(BOOL)nullForNil {
    id serializedData = nil;
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *newMutableArray = [NSMutableArray arrayWithCapacity:((NSArray *)object).count];
        for (id innerObject in ((NSArray *)object)) {
            [newMutableArray addObject:[self serializeObject:innerObject withNullForNil:nullForNil]];
        }
        serializedData = [NSArray arrayWithArray:newMutableArray];
    } else if ([object isKindOfClass:[TCUTypeSafeCollection class]]) {
        serializedData = [((TCUTypeSafeCollection *)object) dictionary];
    } else {
        serializedData = object;
    }
    if ((!serializedData) && nullForNil) {
        serializedData = [NSNull null];;
    }
    return serializedData;
}

- (NSDictionary *)dictionary {
    return [self dictionaryWithNullForNils:NO];
}

- (NSDictionary *)dictionaryWithNullForNils:(BOOL)nullForNils {
    return [self dictionaryWithNullForNils:nullForNils propertyNamesAsKeys:NO];
}

- (NSDictionary *)dictionaryWithNullForNils:(BOOL)nullForNils propertyNamesAsKeys:(BOOL)propertyNamesAsKeys {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (TCUPropertyAttributes *propertyAttributes in tcuTypeSafeCollectionGetters.objectEnumerator) {
        id serializedData = [self serializeObject:[self getter:propertyAttributes] withNullForNil:nullForNils];
        if (serializedData || nullForNils) {
            NSString *key = nil;
            if (propertyNamesAsKeys) {
                key = propertyAttributes.instanceVariableName;
                if (!key) {
                    key = propertyAttributes.propertyName;
                }
            } else {
                key = [self keyForPropertyAttributes:propertyAttributes];
            }
            dictionary[key] = serializedData;
        }
    }
    return dictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n%@",
     [super description], [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self dictionaryWithNullForNils:YES
                                                                                                             propertyNamesAsKeys:YES]
                                                                                         options:NSJSONWritingPrettyPrinted
                                                                                           error:nil]
                                                encoding:NSUTF8StringEncoding]];
}

- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve {
    tcuTypeSafeCollectionPropertyToKeyMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
        for (NSString *propertyName in classLevelMappingTable.keyEnumerator) {
            [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:[classLevelMappingTable objectForKey:propertyName] forKey:propertyName];
        }
    }
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *fieldName, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && [fieldName isKindOfClass:[NSString class]]) {
                [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:fieldName forKey:propertyName];
            }
        }];
    }
}

- (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve {
    tcuTypeSafeCollectionArrayToClassMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [tcuTypeSafeCollectionArrayToClassMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
        for (NSString *propertyName in classLevelMappingTable.keyEnumerator) {
            [tcuTypeSafeCollectionArrayToClassMappingTable setObject:[classLevelMappingTable objectForKey:propertyName] forKey:propertyName];
        }
    }
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class classType, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && class_isMetaClass(object_getClass(classType))) {
                if ([classType isSubclassOfClass:[TCUTypeSafeCollection class]]) {
                    [tcuTypeSafeCollectionArrayToClassMappingTable setObject:classType forKey:propertyName];
                }
            }
        }];
    }
}

- (void)setObjectTransformers:(NSArray *)objectTransformers preserveClassLevelTransformers:(BOOL)preserve {
    if ([objectTransformers isKindOfClass:[NSArray class]]) {
        [self setObjectTransformersPerProperty:@{kClassTranformersKey : objectTransformers} preserveClassLevelTransformers:preserve];
    }
}

- (void)setObjectTransformersPerProperty:(NSDictionary *)objectTransformersPerProperty preserveClassLevelTransformers:(BOOL)preserve {
    tcuTypeSafeCollectionObjectTransformers = [NSMutableDictionary dictionary];
    NSMutableDictionary *superTransformers = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionObjectTransformersKey);
    [tcuTypeSafeCollectionObjectTransformers setValuesForKeysWithDictionary:superTransformers];
    if (preserve) {
        [tcuTypeSafeCollectionObjectTransformers setValuesForKeysWithDictionary:objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey)];
    }
    if ([objectTransformersPerProperty isKindOfClass:[NSDictionary class]]) {
        [objectTransformersPerProperty enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSArray *transformers, BOOL *stop) {
            if ([transformers isKindOfClass:[NSArray class]]) {
                NSMutableDictionary *objectTransformersOfProperty = tcuTypeSafeCollectionObjectTransformers[propertyName];
                if (!objectTransformersOfProperty) {
                    objectTransformersOfProperty = [NSMutableDictionary dictionary];
                    tcuTypeSafeCollectionObjectTransformers[propertyName] = objectTransformersOfProperty;
                }
                for (TCUObjectTransformer *transformer in transformers) {
                    if ([transformer isKindOfClass:[TCUObjectTransformer class]]) {
                        if (transformer.originalObjectClass && transformer.transformedObjectClass) {
                            NSMutableDictionary *originalObjectKeyDict = tcuTypeSafeCollectionObjectTransformers[NSStringFromClass(transformer.originalObjectClass)];
                            if (!originalObjectKeyDict) {
                                originalObjectKeyDict = [NSMutableDictionary dictionary];
                                tcuTypeSafeCollectionObjectTransformers[NSStringFromClass(transformer.originalObjectClass)] = originalObjectKeyDict;
                            }
                            originalObjectKeyDict[NSStringFromClass(transformer.transformedObjectClass)] = transformer;
                        }
                    }
                }
            }
        }];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self isMemberOfClass:[TCUTypeSafeCollection class]]) {
            self = nil;
        } else {
            tcuTypeSafeCollectionData = [NSMutableDictionary dictionary];
            tcuTypeSafeCollectionProperties = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertiesKey);
            tcuTypeSafeCollectionGetters = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionGettersKey);
            tcuTypeSafeCollectionSetters = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionSettersKey);
            tcuTypeSafeCollectionPropertyToKeyMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
            tcuTypeSafeCollectionArrayToClassMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
            tcuTypeSafeCollectionObjectTransformers = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey);
        }
    }
    return self;
}

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(aSelector)];
    TCUPropertyAttributes *getter = [objc_getAssociatedObject([self class], kTCUTypeSafeCollectionGettersKey) objectForKey:selectorName];
    if (getter) {
        return YES;
    } else {
        TCUPropertyAttributes *setter = [objc_getAssociatedObject([self class], kTCUTypeSafeCollectionSettersKey) objectForKey:selectorName];
        if (setter) {
            return YES;
        } else {
            return [super respondsToSelector:aSelector];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(aSelector)];
    TCUPropertyAttributes *getter = [tcuTypeSafeCollectionGetters objectForKey:selectorName];
    if (getter) {
        return YES;
    } else {
        TCUPropertyAttributes *setter = [tcuTypeSafeCollectionSetters objectForKey:selectorName];
        if (setter) {
            return YES;
        } else {
            return [super respondsToSelector:aSelector];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(aSelector)];
    TCUPropertyAttributes *getter = [tcuTypeSafeCollectionGetters objectForKey:selectorName];
    if (getter) {
        return [NSMethodSignature signatureWithObjCTypes:"@@:@"];
    } else {
        TCUPropertyAttributes *setter = [tcuTypeSafeCollectionSetters objectForKey:selectorName];
        if (setter) {
            return [NSMethodSignature signatureWithObjCTypes:"v@:@@"];
        } else {
            return nil;
        }
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(aSelector)];
    TCUPropertyAttributes *getter = [tcuTypeSafeCollectionGetters objectForKey:selectorName];
    if (getter) {
        return self;
    } else {
        return [super forwardingTargetForSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    NSString *selectorName = [NSString stringWithUTF8String:sel_getName(aSelector)];
    TCUPropertyAttributes *getter = [tcuTypeSafeCollectionGetters objectForKey:selectorName];
    if (getter) {
        anInvocation.selector = @selector(getter:);
        [anInvocation setArgument:&getter atIndex:2];
        [anInvocation invokeWithTarget:self];
    } else {
        TCUPropertyAttributes *setter = [tcuTypeSafeCollectionSetters objectForKey:selectorName];
        if (setter) {
            anInvocation.selector = @selector(setter:propertyAttributes:);
            [anInvocation setArgument:&setter atIndex:3];
            [anInvocation invokeWithTarget:self];
        } else {
            [super forwardInvocation:anInvocation];
        }
    }
}

- (NSString *)keyForPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    NSString *key = [tcuTypeSafeCollectionPropertyToKeyMappingTable objectForKey:propertyAttributes.propertyName];
    if (!key) {
        key = propertyAttributes.instanceVariableName;
        if (!key) {
            key = propertyAttributes.propertyName;
        }
    }
    return key;
}

- (id)getter:(TCUPropertyAttributes *)propertyAttributes {
    id returnObject = tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]];
    Class expectedClass = NSClassFromString(propertyAttributes.name);
    if ([returnObject isKindOfClass:expectedClass]) {
        return returnObject;
    } else if ([self canTransfromClass:[returnObject class] toClass:expectedClass forPropertyName:propertyAttributes.propertyName]) {
        return [self setObject:[self transformObject:returnObject onPropertyAttributes:propertyAttributes] onPropertyAttributes:propertyAttributes];
    } else {
        return nil;
    }
}

- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    if ([self shouldSetObject:objectToBeSet forProperty:propertyAttributes.propertyName]) {
        Class expectedClass = NSClassFromString(propertyAttributes.name);
        if ([objectToBeSet isKindOfClass:expectedClass]) {
            if ([expectedClass isSubclassOfClass:[NSArray class]]) {
                Class classToBeTransformed = [tcuTypeSafeCollectionArrayToClassMappingTable objectForKey:propertyAttributes.propertyName];
                if (classToBeTransformed) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:((NSArray *)objectToBeSet).count];
                    [((NSArray *)objectToBeSet) enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        id transformedObject = nil;
                        if ([obj isKindOfClass:classToBeTransformed]) {
                            transformedObject = obj;
                        } else {
                            transformedObject = [self transformObject:obj atIndex:idx toClass:classToBeTransformed propertyAttributes:propertyAttributes];
                        }
                        if (transformedObject) {
                            [tempArray addObject:transformedObject];
                        }
                    }];
                    NSArray *transformedObject = nil;
                    if ([expectedClass isSubclassOfClass:[NSMutableArray class]]) {
                        transformedObject = tempArray;
                    } else {
                        transformedObject = [NSArray arrayWithArray:tempArray];
                    }
                    [self setObject:transformedObject onPropertyAttributes:propertyAttributes];
                } else {
                    [self setObject:objectToBeSet onPropertyAttributes:propertyAttributes];
                }
            } else {
                [self setObject:objectToBeSet onPropertyAttributes:propertyAttributes];
            }
        } else if ([self canTransfromClass:[objectToBeSet class] toClass:expectedClass forPropertyName:propertyAttributes.propertyName]) {
            [self setObject:[self transformObject:objectToBeSet onPropertyAttributes:propertyAttributes] onPropertyAttributes:propertyAttributes];
        } else {
            [self setObject:nil onPropertyAttributes:propertyAttributes];
        }
    }
}

+ (BOOL)canTransfromClass:(Class)originalClass toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName {
    if (originalClass && transformedClass) {
        NSDictionary *tcuTypeSafeCollectionObjectTransformers = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey);
        if ((tcuTypeSafeCollectionObjectTransformers[propertyName][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)]) ||
            (tcuTypeSafeCollectionObjectTransformers[kClassTranformersKey][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)]) ||
            ([originalClass isKindOfClass:[NSDictionary class]] &&
             [transformedClass isSubclassOfClass:[TCUTypeSafeCollection class]])) {
                return YES;
            }
    }
    return NO;
}

- (BOOL)canTransfromClass:(Class)originalClass toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName {
    if (originalClass && transformedClass) {
        if ((tcuTypeSafeCollectionObjectTransformers[propertyName][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)]) ||
            (tcuTypeSafeCollectionObjectTransformers[kClassTranformersKey][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)]) ||
            ([originalClass isKindOfClass:[NSDictionary class]] &&
             [transformedClass isSubclassOfClass:[TCUTypeSafeCollection class]])) {
            return YES;
        }
    }
    return NO;
}

+ (TCUObjectTransformer *)transfromerFromClass:(Class)originalClass toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName {
    TCUObjectTransformer *transformer = nil;
    if (originalClass && transformedClass) {
        NSDictionary *tcuTypeSafeCollectionObjectTransformers = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionObjectTransformersKey);
        if ([originalClass isKindOfClass:[NSDictionary class]] &&
            [transformedClass isSubclassOfClass:[TCUTypeSafeCollection class]]) {
            transformer = [TCUObjectTransformer dictionaryToTypeSafeCollectionTransformer];
        } else {
            transformer = tcuTypeSafeCollectionObjectTransformers[propertyName][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)];
            if (!transformer) {
                transformer = tcuTypeSafeCollectionObjectTransformers[kClassTranformersKey][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)];
            }
        }
    }
    return transformer;
}

- (TCUObjectTransformer *)transfromerFromClass:(Class)originalClass toClass:(Class)transformedClass forPropertyName:(NSString *)propertyName {
    TCUObjectTransformer *transformer = nil;
    if (originalClass && transformedClass) {
        if ([originalClass isKindOfClass:[NSDictionary class]] &&
            [transformedClass isSubclassOfClass:[TCUTypeSafeCollection class]]) {
            transformer = [TCUObjectTransformer dictionaryToTypeSafeCollectionTransformer];
        } else {
            transformer = tcuTypeSafeCollectionObjectTransformers[propertyName][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)];
            if (!transformer) {
                transformer = tcuTypeSafeCollectionObjectTransformers[kClassTranformersKey][NSStringFromClass(originalClass)][NSStringFromClass(transformedClass)];
            }
        }
    }
    return transformer;
}

- (id)transformObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeTransformed propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    id transformedObject = nil;
    if ([self shouldTransformObject:object atIndex:index forProperty:propertyAttributes.propertyName]) {
        object = [self willTransformObject:object atIndex:index forProperty:propertyAttributes.propertyName];
        transformedObject = [self transformObject:object toClass:classToBeTransformed forProperty:propertyAttributes.propertyName];
        transformedObject = [self didTransformObject:object atIndex:index forProperty:propertyAttributes.propertyName toObject:transformedObject];
    }
    return transformedObject;
}

- (id)transformObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    object = [self willTransformObject:object forProperty:propertyAttributes.propertyName];
    id transformedObject = [self transformObject:object
                                         toClass:NSClassFromString(propertyAttributes.name)
                                     forProperty:propertyAttributes.propertyName];
    return [self didTransformObject:object forProperty:propertyAttributes.propertyName toObject:transformedObject];
}

- (id)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    object = [self willSetObject:object forProperty:propertyAttributes.propertyName];
    [self willChangeValueForKey:propertyAttributes.propertyName];
    if (object) {
        tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]] = object;
    } else {
        [tcuTypeSafeCollectionData removeObjectForKey:[self keyForPropertyAttributes:propertyAttributes]];
    }
    [self didChangeValueForKey:propertyAttributes.propertyName];
    [self didSetObject:object forProperty:propertyAttributes.propertyName];
    return object;
}

#pragma mark - Overridable Subclass Delegation Methods

- (BOOL)shouldSetObject:(id)object forProperty:(NSString *)propertyName {
    return YES;
}

- (id)willSetObject:(id)object forProperty:(NSString *)propertyName {
    return object;
}

- (void)didSetObject:(id)object forProperty:(NSString *)propertyName {
    return;
}

- (id)willTransformObject:(id)object forProperty:(NSString *)propertyName {
    return object;
}

- (id)didTransformObject:(id)inboundObject forProperty:(NSString *)propertyName toObject:(id)transformedObject {
    return transformedObject;
}

- (id)transformObject:(id)inboundObject toClass:(Class)classType forProperty:(NSString *)propertyName {
    if ([inboundObject isKindOfClass:[NSObject class]] && classType) {
        return [[self transfromerFromClass:[inboundObject class]
                                   toClass:classType
                           forPropertyName:propertyName] transformedObject:inboundObject toClass:classType];
    } else {
        return nil;
    }
}

- (BOOL)shouldTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName {
    return YES;
}

- (id)willTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName {
    return object;
}

- (id)didTransformObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName toObject:(id)transformedObject {
    return transformedObject;
}

@end
