//
//  TCUObjectTransformer.h
//  Pods
//
//  Created by Töre Çağrı Uyar on 03/06/15.
//
//

#import <Foundation/Foundation.h>

@interface TCUObjectTransformer : NSObject

@property (nonatomic, readonly) NSMutableDictionary *dataStore;
@property (nonatomic, readonly) Class originalObjectClass;
@property (nonatomic, readonly) Class transformedObjectClass;
@property (nonatomic, copy) id (^transformer)(id object);
@property (nonatomic, copy) id (^remrofsnart)(id object);

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)())initBlock
                              transformer:(id (^)(id object))transformer
                       reverseTransformer:(id (^)(id object))remrofsnart;

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass;

- (BOOL)allowsReverseTransformation;
- (id)transformedObject:(id)object;
- (id)reverseTransformedObject:(id)object;

@end
