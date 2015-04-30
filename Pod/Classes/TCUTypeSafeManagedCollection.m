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
//  TCUTypeSafeManagedCollection.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 28/04/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//


#import "TCUTypeSafeManagedCollection.h"
#import "TCUPropertyAttributes.h"
@import ObjectiveC;

static const void *kTCUTypeSafeCollectionPropertiesKey = (void *)&kTCUTypeSafeCollectionPropertiesKey;
static const void *kTCUTypeSafeCollectionGettersKey = (void *)&kTCUTypeSafeCollectionGettersKey;
static const void *kTCUTypeSafeCollectionSettersKey = (void *)&kTCUTypeSafeCollectionSettersKey;
static const void *kTCUTypeSafeCollectionPropertyToKeyMappingTableKey = (void *)&kTCUTypeSafeCollectionPropertyToKeyMappingTableKey;
static const void *kTCUTypeSafeCollectionArrayToClassMappingTableKey = (void *)&kTCUTypeSafeCollectionArrayToClassMappingTableKey;

@interface TCUTypeSafeManagedCollection () {
    __weak NSDictionary *tcuTypeSafeCollectionProperties;
    __weak NSMapTable *tcuTypeSafeCollectionGetters;
    __weak NSMapTable *tcuTypeSafeCollectionSetters;
    NSMapTable *tcuTypeSafeCollectionPropertyToKeyMappingTable;
    NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable;
}

- (NSString *)keyForPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;

- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (void)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)castObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast;
- (id)castAndSetObject:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast;
- (id)castObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeCasted propertyAttributes:(TCUPropertyAttributes *)propertyAttributes;

@end

@implementation TCUTypeSafeManagedCollection

#pragma mark - Class

+ (void)initialize {
    [super initialize];
    if ([self class] != [TCUTypeSafeManagedCollection class]) {
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
        NSMapTable *tcuTypeSafeCollectionPropertyToKeyMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
        NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
        NSMapTable *tcuTypeSafeCollectionGetters = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        [tcuTypeSafeCollectionProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, TCUPropertyAttributes *propertyAttributes, BOOL *stop) {
            NSString *getter = propertyAttributes.getter;
            if (!getter) {
                getter = propertyName;
            }
            [tcuTypeSafeCollectionGetters setObject:propertyAttributes forKey:getter];
        }];
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
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionPropertiesKey, tcuTypeSafeCollectionProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionGettersKey, tcuTypeSafeCollectionGetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionSettersKey, tcuTypeSafeCollectionSetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionPropertyToKeyMappingTableKey, tcuTypeSafeCollectionPropertyToKeyMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kTCUTypeSafeCollectionArrayToClassMappingTableKey, tcuTypeSafeCollectionArrayToClassMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
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
                if ([classType isSubclassOfClass:[TCUTypeSafeManagedCollection class]]) {
                    [selfMappingTable setObject:classType forKey:propertyName];
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
    for (TCUPropertyAttributes *propertyAttributes in tcuTypeSafeCollectionGetters.objectEnumerator) {
        [self setter:dict[[self keyForPropertyAttributes:propertyAttributes]] propertyAttributes:propertyAttributes];
    }
}

- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve {
    tcuTypeSafeCollectionPropertyToKeyMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
        for (NSString *propertyName in classLevelMappingTable.keyEnumerator) {
            [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:[classLevelMappingTable objectForKey:propertyName] forKey:propertyName];
        }
    }
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
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
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
        for (NSString *propertyName in classLevelMappingTable.keyEnumerator) {
            [tcuTypeSafeCollectionArrayToClassMappingTable setObject:[classLevelMappingTable objectForKey:propertyName] forKey:propertyName];
        }
    }
    NSMapTable *superMappingTable = objc_getAssociatedObject([self superclass], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
    for (NSString *propertyName in superMappingTable.keyEnumerator) {
        [tcuTypeSafeCollectionArrayToClassMappingTable setObject:[superMappingTable objectForKey:propertyName] forKey:propertyName];
    };
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class classType, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && class_isMetaClass(object_getClass(classType))) {
                if ([classType isSubclassOfClass:[TCUTypeSafeManagedCollection class]]) {
                    [tcuTypeSafeCollectionArrayToClassMappingTable setObject:classType forKey:propertyName];
                }
            }
        }];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self isMemberOfClass:[TCUTypeSafeManagedCollection class]]) {
            self = nil;
        } else {
            tcuTypeSafeCollectionProperties = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertiesKey);
            tcuTypeSafeCollectionGetters = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionGettersKey);
            tcuTypeSafeCollectionSetters = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionSettersKey);
            tcuTypeSafeCollectionPropertyToKeyMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
            tcuTypeSafeCollectionArrayToClassMappingTable = objc_getAssociatedObject([self class], kTCUTypeSafeCollectionArrayToClassMappingTableKey);
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

- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    if ([self shouldSetObject:objectToBeSet forProperty:propertyAttributes.propertyName]) {
        Class expectedClass = NSClassFromString(propertyAttributes.name);
        if ([objectToBeSet isKindOfClass:expectedClass]) {
            if ([expectedClass isSubclassOfClass:[NSArray class]]) {
                Class classToBeCasted = [tcuTypeSafeCollectionArrayToClassMappingTable objectForKey:propertyAttributes.propertyName];
                if (classToBeCasted) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:((NSArray *)objectToBeSet).count];
                    [((NSArray *)objectToBeSet) enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        id castedObject = [self castObject:obj atIndex:idx toClass:classToBeCasted propertyAttributes:propertyAttributes];
                        if (castedObject) {
                            [tempArray addObject:castedObject];
                        }
                    }];
                    NSArray *castedObject = nil;
                    if ([expectedClass isSubclassOfClass:[NSMutableArray class]]) {
                        castedObject = tempArray;
                    } else {
                        castedObject = [NSArray arrayWithArray:tempArray];
                    }
                    [self setObject:castedObject onPropertyAttributes:propertyAttributes];
                } else {
                    [self setObject:objectToBeSet onPropertyAttributes:propertyAttributes];
                }
            } else {
                [self setObject:objectToBeSet onPropertyAttributes:propertyAttributes];
            }
        } else if ([NSClassFromString(propertyAttributes.name) isSubclassOfClass:[TCUTypeSafeManagedCollection class]] &&
                   [objectToBeSet isKindOfClass:[NSDictionary class]]) {
            [self castAndSetObject:objectToBeSet propertyAttributes:propertyAttributes autoCast:[self shouldAutoCastObject:objectToBeSet forProperty:propertyAttributes.propertyName]];
        } else {
            [self setObject:nil onPropertyAttributes:propertyAttributes];
        }
    }
}

- (id)castObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeCasted propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    id castedObject = nil;
    if ([self shouldCastObject:object atIndex:index forProperty:propertyAttributes.propertyName]) {
        [self willCastObject:object atIndex:index forProperty:propertyAttributes.propertyName];
        castedObject = ([object isKindOfClass:[NSDictionary class]] ? [[classToBeCasted alloc] initWithDictionary:object] : [[classToBeCasted alloc] init]);
        [self didCastObject:object atIndex:index forProperty:propertyAttributes.propertyName toObject:castedObject];
    }
    return castedObject;
}

- (id)castObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast {
    [self willAutoCastObject:object forProperty:propertyAttributes.propertyName];
    id castedObject = nil;
    if (autoCast) {
        castedObject = [[NSClassFromString(propertyAttributes.name) alloc] initWithDictionary:object];
    } else {
        Class expectedClass = NSClassFromString(propertyAttributes.name);
        castedObject = [self castObject:object toClass:expectedClass forProperty:propertyAttributes.propertyName];
        if (![castedObject isKindOfClass:expectedClass]) {
            castedObject = nil;
        }
    }
    [self didAutoCastObject:object forProperty:propertyAttributes.propertyName toObject:castedObject];
    return castedObject;
}

- (void)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    [self willSetObject:object forProperty:propertyAttributes.propertyName];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString([tcuTypeSafeCollectionSetters objectForKey:propertyAttributes]) withObject:object];
#pragma clang diagnostic pop
    [self didSetObject:object forProperty:propertyAttributes.propertyName];
}

- (id)castAndSetObject:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast {
    id castedObject = [self castObject:objectToBeSet onPropertyAttributes:propertyAttributes autoCast:autoCast];
    [self setObject:castedObject onPropertyAttributes:propertyAttributes];
    return castedObject;
}

- (BOOL)shouldSetObject:(id)object forProperty:(NSString *)propertyName {
    return YES;
}

- (void)willSetObject:(id)object forProperty:(NSString *)propertyName {
    return;
}

- (void)didSetObject:(id)object forProperty:(NSString *)propertyName {
    return;
}

- (BOOL)shouldAutoCastObject:(id)object forProperty:(NSString *)propertyName {
    return YES;
}

- (void)willAutoCastObject:(id)object forProperty:(NSString *)propertyName {
    return;
}

- (void)didAutoCastObject:(id)inboundObject forProperty:(NSString *)propertyName toObject:(id)castedObject {
    return;
}

- (id)castObject:(id)inboundObject toClass:(Class)classType forProperty:(NSString *)propertyName {
    return nil;
}

- (BOOL)shouldCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName {
    return YES;
}

- (void)willCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName {
    return;
}

- (void)didCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName toObject:(id)castedObject {
    return;
}

@end
