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
//  TCUObjectTransformer.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 03/06/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUObjectTransformer.h"

@interface TCUObjectTransformer ()

@property (nonatomic, readwrite) NSMutableDictionary *dataStore;
@property (nonatomic, readwrite) Class originalObjectClass;
@property (nonatomic, readwrite) Class transformedObjectClass;

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass onInit:(void (^)(TCUObjectTransformer *transformer))initBlock;

@end

@implementation TCUObjectTransformer

@synthesize dataStore = _dataStore;

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)(TCUObjectTransformer *transformer))initBlock
                              transformer:(id (^)(TCUObjectTransformer *transformer, id object))transformer
                       reverseTransformer:(id (^)(TCUObjectTransformer *transformer, id object))remrofsnart {
    TCUObjectTransformer *objectTransformer = [[TCUObjectTransformer alloc] initWithOriginalObjectClass:originalObjectClass transformedObjectClass:transformedObjectClass onInit:initBlock];
    objectTransformer.transformer = transformer;
    objectTransformer.remrofsnart = remrofsnart;
    return objectTransformer;
}

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)(TCUObjectTransformer *transformer))initBlock
           transformerWithClassForwarding:(id (^)(TCUObjectTransformer *transformer, Class class, id object))transformer
    reverseTransformerWithClassForwarding:(id (^)(TCUObjectTransformer *transformer, Class class, id object))remrofsnart {
    TCUObjectTransformer *objectTransformer = [[TCUObjectTransformer alloc] initWithOriginalObjectClass:originalObjectClass transformedObjectClass:transformedObjectClass onInit:initBlock];
    objectTransformer.transformerWithClassForwarding = transformer;
    objectTransformer.remrofsnartWithClassForwarding = remrofsnart;
    return objectTransformer;
}

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass {
    return [self initWithOriginalObjectClass:originalObjectClass transformedObjectClass:transformedObjectClass onInit:nil];
}

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass onInit:(void (^)(TCUObjectTransformer *transformer))initBlock {
    self = [super init];
    if (self) {
        if (initBlock) {
            initBlock(self);
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

- (id)transformedObject:(id)object to:(Class)class {
    id transformedObject = nil;
    if (self.transformerWithClassForwarding) {
        transformedObject = self.transformerWithClassForwarding(self, class, object);
    } else if (self.transformer) {
        transformedObject = self.transformer(self, object);
    }
    return transformedObject;
}

- (id)reverseTransformedObject:(id)object to:(Class)class {
    id reverseTransformedObject = nil;
    if (self.remrofsnartWithClassForwarding) {
        reverseTransformedObject = self.remrofsnartWithClassForwarding(self, class, object);
    } else if (self.remrofsnart) {
        reverseTransformedObject = self.remrofsnart(self, object);
    }
    return reverseTransformedObject;
}

@end
