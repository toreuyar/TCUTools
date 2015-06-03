//
//  TCUObjectTransformer.m
//  Pods
//
//  Created by Töre Çağrı Uyar on 03/06/15.
//
//

#import "TCUObjectTransformer.h"

@interface TCUObjectTransformer ()

@property (nonatomic, readwrite) NSMutableDictionary *dataStore;
@property (nonatomic, readwrite) Class originalObjectClass;
@property (nonatomic, readwrite) Class transformedObjectClass;

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass onInit:(void (^)())initBlock;

@end

@implementation TCUObjectTransformer

@synthesize dataStore = _dataStore;

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)())initBlock
                              transformer:(id (^)(id object))transformer
                       reverseTransformer:(id (^)(id object))remrofsnart {
    TCUObjectTransformer *objectTransformer = [[TCUObjectTransformer alloc] initWithOriginalObjectClass:originalObjectClass transformedObjectClass:transformedObjectClass onInit:initBlock];
    objectTransformer.transformer = transformer;
    objectTransformer.remrofsnart = remrofsnart;
    return objectTransformer;
}

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass {
    return [self initWithOriginalObjectClass:originalObjectClass transformedObjectClass:transformedObjectClass onInit:nil];
}

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass onInit:(void (^)())initBlock {
    self = [super init];
    if (self) {
        if (initBlock) {
            initBlock();
        }
        self.originalObjectClass = originalObjectClass;
        self.transformedObjectClass = transformedObjectClass;
    }
    return self;
}

- (BOOL)allowsReverseTransformation {
    return (self.remrofsnart ? YES : NO);
}

- (NSMutableDictionary *)dataStore {
    if (!_dataStore) {
        @synchronized(self) {
            if (!_dataStore) {
                _dataStore = [NSMutableDictionary dictionary];
            }
        }
    }
    return _dataStore;
}

- (id)transformedObject:(id)object {
    return ((self.transformer) ? self.transformer(object) : nil);
}

- (id)reverseTransformedObject:(id)object {
    return ((self.remrofsnart) ? self.remrofsnart(object) : nil);
}

@end
