//
//  TCUTypeSafeCollection.m
//  Pods
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//
//

#import "TCUTypeSafeCollection.h"
#import "TCUPropertyAttributes.h"
@import ObjectiveC;

static char kTCUTypeSafeCollectionPropertiesKey;
static char kTCUTypeSafeCollectionGettersKey;
static char kTCUTypeSafeCollectionSettersKey;
static char kTCUTypeSafeCollectionPropertyToKeyMappingTableKey;
static char kTCUTypeSafeCollectionArrayToClassMappingTableKey;

@interface TCUTypeSafeCollection () {
    __weak NSDictionary *tcuTypeSafeCollectionProperties;
    __weak NSMapTable *tcuTypeSafeCollectionGetters;
    __weak NSMapTable *tcuTypeSafeCollectionSetters;
    NSMapTable *tcuTypeSafeCollectionPropertyToKeyMappingTable;
    NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable;
    NSMutableDictionary *tcuTypeSafeCollectionData;
}

- (NSString *)keyForPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (void)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes;
- (id)castObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast;
- (id)castAndSetObject:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast;
- (id)castObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeCasted propertyAttributes:(TCUPropertyAttributes *)propertyAttributes;

@end

@implementation TCUTypeSafeCollection

+ (void)initialize {
    [super initialize];
    if ([self class] != [TCUTypeSafeCollection class]) {
        NSDictionary *tcuTypeSafeCollectionProperties = [[self class] propertyDictionary];
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
        objc_setAssociatedObject(self, &kTCUTypeSafeCollectionPropertiesKey, tcuTypeSafeCollectionProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kTCUTypeSafeCollectionGettersKey, tcuTypeSafeCollectionGetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kTCUTypeSafeCollectionSettersKey, tcuTypeSafeCollectionSetters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kTCUTypeSafeCollectionPropertyToKeyMappingTableKey, tcuTypeSafeCollectionPropertyToKeyMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kTCUTypeSafeCollectionArrayToClassMappingTableKey, tcuTypeSafeCollectionArrayToClassMappingTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable {
    NSMapTable *tcuTypeSafeCollectionPropertyToObjectMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
    [tcuTypeSafeCollectionPropertyToObjectMappingTable removeAllObjects];
    if ([mappingTable isKindOfClass:[NSDictionary class]]) {
        [mappingTable enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *fieldName, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]] && [fieldName isKindOfClass:[NSString class]]) {
                [tcuTypeSafeCollectionPropertyToObjectMappingTable setObject:fieldName forKey:propertyName];
            }
        }];
    }
}

+ (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable {
    NSMapTable *tcuTypeSafeCollectionArrayToClassMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionArrayToClassMappingTableKey);
    [tcuTypeSafeCollectionArrayToClassMappingTable removeAllObjects];
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

- (void)setDataWith:(NSDictionary *)dict __attribute__((deprecated)) { // TODO: Should be removed at next major version.
    [self setDataWithDictionary:dict];
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
    [tcuTypeSafeCollectionData setValuesForKeysWithDictionary:dict];
    for (TCUPropertyAttributes *propertyAttributes in tcuTypeSafeCollectionGetters.objectEnumerator) {
        [self setter:dict[[self keyForPropertyAttributes:propertyAttributes]] propertyAttributes:propertyAttributes];
    }
}

- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve {
    tcuTypeSafeCollectionPropertyToKeyMappingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
        [classLevelMappingTable.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *fieldName, BOOL *stop) {
            [tcuTypeSafeCollectionPropertyToKeyMappingTable setObject:fieldName forKey:propertyName];
        }];
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
    if (preserve) {
        NSMapTable *classLevelMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionArrayToClassMappingTableKey);
        [classLevelMappingTable.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class classType, BOOL *stop) {
            [tcuTypeSafeCollectionArrayToClassMappingTable setObject:classType forKey:propertyName];
        }];
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

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self isMemberOfClass:[TCUTypeSafeCollection class]]) {
            self = nil;
        } else {
            tcuTypeSafeCollectionData = [NSMutableDictionary dictionary];
            tcuTypeSafeCollectionProperties = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionPropertiesKey);
            tcuTypeSafeCollectionGetters = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionGettersKey);
            tcuTypeSafeCollectionSetters = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionSettersKey);
            tcuTypeSafeCollectionPropertyToKeyMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionPropertyToKeyMappingTableKey);
            tcuTypeSafeCollectionArrayToClassMappingTable = objc_getAssociatedObject([self class], &kTCUTypeSafeCollectionArrayToClassMappingTableKey);
        }
    }
    return self;
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
        TCUPropertyAttributes *setter = [tcuTypeSafeCollectionSetters objectForKey:selectorName];
        if (setter) {
            return self;
        } else {
            return nil;
        }
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
    if ([returnObject isKindOfClass:NSClassFromString(propertyAttributes.name)]) {
        return returnObject;
    } else if ([NSClassFromString(propertyAttributes.name) isSubclassOfClass:[TCUTypeSafeCollection class]] &&
               [returnObject isKindOfClass:[NSDictionary class]]) {
        returnObject = nil;
        if ([self respondsToSelector:@selector(shouldAutoCastObject:forProperty:)]) {
            if ([self shouldAutoCastObject:returnObject forProperty:propertyAttributes.propertyName]) {
                returnObject = [self castAndSetObject:returnObject propertyAttributes:propertyAttributes autoCast:[self shouldAutoCastObject:returnObject forProperty:propertyAttributes.propertyName]];
            }
        } else {
            returnObject = [self castAndSetObject:returnObject propertyAttributes:propertyAttributes autoCast:YES];
        }
        return returnObject;
    } else {
        return nil;
    }
}

- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    if ([self respondsToSelector:@selector(shouldSetObject:forProperty:)]) {
        if ([self shouldSetObject:objectToBeSet forProperty:propertyAttributes.propertyName]) {
            [self setObject:objectToBeSet onPropertyAttributes:propertyAttributes];
        }
    } else {
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
        } else if ([NSClassFromString(propertyAttributes.name) isSubclassOfClass:[TCUTypeSafeCollection class]] &&
                   [objectToBeSet isKindOfClass:[NSDictionary class]]) {
            if ([self respondsToSelector:@selector(shouldAutoCastObject:forProperty:)]) {
                [self castAndSetObject:objectToBeSet propertyAttributes:propertyAttributes autoCast:[self shouldAutoCastObject:objectToBeSet forProperty:propertyAttributes.propertyName]];
            } else {
                [self castAndSetObject:objectToBeSet propertyAttributes:propertyAttributes autoCast:YES];
            }
        } else {
            [self setObject:nil onPropertyAttributes:propertyAttributes];
        }
    }
}

- (id)castObject:(id)object atIndex:(NSUInteger)index toClass:(Class)classToBeCasted propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    id castedObject = nil;
    if ([self respondsToSelector:@selector(shouldCastObject:atIndex:forProperty:)] ? [self shouldCastObject:object atIndex:index forProperty:propertyAttributes.propertyName] : YES) {
        if ([self respondsToSelector:@selector(willCastObject:atIndex:forProperty:)]) {
            [self willCastObject:object atIndex:index forProperty:propertyAttributes.propertyName];
        }
        castedObject = ([object isKindOfClass:[NSDictionary class]] ? [[classToBeCasted alloc] initWithDictionary:object] : [[classToBeCasted alloc] init]);
        if ([self respondsToSelector:@selector(didCastObject:atIndex:forProperty:toObject:)]) {
            [self didCastObject:object atIndex:index forProperty:propertyAttributes.propertyName toObject:castedObject];
        }
    }
    return castedObject;
}

- (id)castObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast {
    if ([self respondsToSelector:@selector(willAutoCastObject:forProperty:)]) {
        [self willAutoCastObject:object forProperty:propertyAttributes.propertyName];
    }
    id castedObject = nil;
    if (autoCast) {
        castedObject = [[NSClassFromString(propertyAttributes.name) alloc] initWithDictionary:object];
    } else if ([self respondsToSelector:@selector(castObject:toClass:forProperty:)]) {
        Class expectedClass = NSClassFromString(propertyAttributes.name);
        castedObject = [self castObject:object toClass:expectedClass forProperty:propertyAttributes.propertyName];
        if (![castedObject isKindOfClass:expectedClass]) {
            castedObject = nil;
        }
    }
    if ([self respondsToSelector:@selector(didAutoCastObject:forProperty:toObject:)]) {
        [self didAutoCastObject:object forProperty:propertyAttributes.propertyName toObject:castedObject];
    }
    return castedObject;
}

- (void)setObject:(id)object onPropertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    if ([self respondsToSelector:@selector(willSetObject:forProperty:)]) {
        [self willSetObject:object forProperty:propertyAttributes.propertyName];
    }
    [self willChangeValueForKey:propertyAttributes.propertyName];
    if (object) {
        tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]] = object;
    } else {
        [tcuTypeSafeCollectionData removeObjectForKey:[self keyForPropertyAttributes:propertyAttributes]];
    }
    if ([self respondsToSelector:@selector(didSetObject:forProperty:)]) {
        [self didSetObject:object forProperty:propertyAttributes.propertyName];
    }
    [self didChangeValueForKey:propertyAttributes.propertyName];
}

- (id)castAndSetObject:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes autoCast:(BOOL)autoCast {
    id castedObject = [self castObject:objectToBeSet onPropertyAttributes:propertyAttributes autoCast:autoCast];
    [self setObject:castedObject onPropertyAttributes:propertyAttributes];
    return castedObject;
}

@end
