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

#import <Foundation/Foundation.h>

@interface TCUObjectTransformer : NSObject

@property (nonatomic, readonly) NSMutableDictionary *dataStore;
@property (nonatomic, readonly) Class originalObjectClass;
@property (nonatomic, readonly) Class transformedObjectClass;
@property (nonatomic, copy) id (^transformer)(TCUObjectTransformer *transformer, id object);
@property (nonatomic, copy) id (^remrofsnart)(TCUObjectTransformer *transformer, id object);
@property (nonatomic, copy) id (^transformerWithClassForwarding)(TCUObjectTransformer *transformer, Class class, id object);
@property (nonatomic, copy) id (^remrofsnartWithClassForwarding)(TCUObjectTransformer *transformer, Class class, id object);

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)(TCUObjectTransformer *transformer))initBlock
           transformerWithClassForwarding:(id (^)(TCUObjectTransformer *transformer, Class class, id object))transformer
    reverseTransformerWithClassForwarding:(id (^)(TCUObjectTransformer *transformer, Class class, id object))remrofsnart;

+ (TCUObjectTransformer *)transformerFrom:(Class)originalObjectClass
                                       to:(Class)transformedObjectClass
                                   onInit:(void (^)(TCUObjectTransformer *transformer))initBlock
                              transformer:(id (^)(TCUObjectTransformer *transformer, id object))transformer
                       reverseTransformer:(id (^)(TCUObjectTransformer *transformer, id object))remrofsnart;

- (instancetype)initWithOriginalObjectClass:(Class)originalObjectClass transformedObjectClass:(Class)transformedObjectClass;

- (BOOL)allowsReverseTransformation;
- (id)transformedObject:(id)object toClass:(Class)class;
- (id)reverseTransformedObject:(id)object toClass:(Class)class;

@end
