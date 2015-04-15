//
//  TCUTypeSafeCollection.h
//  Pods
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//
//

#import <Foundation/Foundation.h>

@interface TCUTypeSafeCollection : NSObject

+ (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable;
+ (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable;
- (void)setPropertyToKeyMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;
- (void)setArrayToClassMappingTable:(NSDictionary *)mappingTable preserveClassLevelMappings:(BOOL)preserve;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)setDataWith:(NSDictionary *)dict;

@end
