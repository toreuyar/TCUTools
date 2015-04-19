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
