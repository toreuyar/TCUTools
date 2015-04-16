//
//  TCUTypeSafeCollection.h
//  Pods
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//
//

@import Foundation;

@protocol TCUTypeSafeCollectionDelegate <NSObject>

@optional

- (BOOL)shouldSetObject:(id)object forProperty:(NSString *)propertyName;
- (void)willSetObject:(id)object forProperty:(NSString *)propertyName;
- (void)didSetObject:(id)object forProperty:(NSString *)propertyName;
- (BOOL)shouldAutoCastObject:(id)object forProperty:(NSString *)propertyName;
- (void)willAutoCastObject:(id)object forProperty:(NSString *)propertyName;
- (void)didAutoCastObject:(id)inboundObject forProperty:(NSString *)propertyName toObject:(id)castedObject;
- (id)castObject:(id)inboundObject toClass:(Class)classType forProperty:(NSString *)propertyName;
- (BOOL)shouldCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName;
- (void)willCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName;
- (void)didCastObject:(id)object atIndex:(NSUInteger)index forProperty:(NSString *)propertyName toObject:(id)castedObject;

@end

@interface TCUTypeSafeCollection : NSObject <TCUTypeSafeCollectionDelegate>

+ (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable;
+ (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable;
- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;
- (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)setDataWith:(NSDictionary *)dict __attribute__((deprecated)); // TODO: Should be removed at next major version.
- (void)setDataWithDictionary:(NSDictionary *)dict;

@end
