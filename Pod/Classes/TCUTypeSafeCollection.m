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

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        [self setDataWith:dict];
    }
    return self;
}

- (void)setDataWith:(NSDictionary *)dict {
    [tcuTypeSafeCollectionData removeAllObjects];
    [tcuTypeSafeCollectionData setValuesForKeysWithDictionary:dict];
    if (tcuTypeSafeCollectionArrayToClassMappingTable.count > 0) {
        [tcuTypeSafeCollectionArrayToClassMappingTable.dictionaryRepresentation enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class classType, BOOL *stop) {
            TCUPropertyAttributes *propertyAttributes = [tcuTypeSafeCollectionProperties objectForKey:propertyName];
            if ([NSClassFromString(propertyAttributes.name) isSubclassOfClass:[NSArray class]]) {
                NSString *key = [self keyForPropertyAttributes:propertyAttributes];
                NSArray *array = tcuTypeSafeCollectionData[key];
                if ([array isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
                    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            id concreteObject = [[classType alloc] initWithDictionary:obj];
                            [tempArray addObject:concreteObject];
                        }
                    }];
                    tcuTypeSafeCollectionData[key] = [NSArray arrayWithArray:tempArray];
                }
            }
        }];
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
        returnObject = [[NSClassFromString(propertyAttributes.name) alloc] initWithDictionary:returnObject];
        tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]] = returnObject;
        return returnObject;
    } else {
        return nil;
    }
}

- (void)setter:(id)objectToBeSet propertyAttributes:(TCUPropertyAttributes *)propertyAttributes {
    if ([objectToBeSet isKindOfClass:NSClassFromString(propertyAttributes.name)]) {
        tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]] = objectToBeSet;
    } else if ([NSClassFromString(propertyAttributes.name) isSubclassOfClass:[TCUTypeSafeCollection class]] &&
               [objectToBeSet isKindOfClass:[NSDictionary class]]) {
        objectToBeSet = [[NSClassFromString(propertyAttributes.name) alloc] initWithDictionary:objectToBeSet];
        tcuTypeSafeCollectionData[[self keyForPropertyAttributes:propertyAttributes]] = objectToBeSet;
    } else {
        [tcuTypeSafeCollectionData removeObjectForKey:[self keyForPropertyAttributes:propertyAttributes]];
    }
}

@end
