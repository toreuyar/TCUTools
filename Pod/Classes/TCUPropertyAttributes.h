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
//  TCUPropertyAttributes.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUVariableType.h"

@interface NSObject (PropertyDictionary)

+ (NSDictionary *)propertyDictionary __attribute__((deprecated)); // TODO: Should be removed at next major version.
+ (NSDictionary *)propertyDictionaryOfClass;
+ (NSDictionary *)propertyDictionaryOfClassHierarchy;

@end

typedef NS_OPTIONS(NSUInteger, TCUPropertyAttribute) {
    TCUPropertyAttributeReadonly            = 1 << 0,
    TCUPropertyAttributeCopy                = 1 << 1,
    TCUPropertyAttributeRetained            = 1 << 2,
    TCUPropertyAttributeNonatomic           = 1 << 3,
    TCUPropertyAttributeDynamic             = 1 << 4,
    TCUPropertyAttributeWeak                = 1 << 5,
    TCUPropertyAttributeGarbageCollectible  = 1 << 6
};

@interface TCUPropertyAttributes : TCUVariableType

@property (nonatomic) TCUPropertyAttribute propertyAttribute;
@property (strong, nonatomic) NSString *oldStyleEncodedType;
@property (strong, nonatomic) NSString *setter;
@property (strong, nonatomic) NSString *getter;
@property (strong, nonatomic) NSString *instanceVariableName;
@property (strong, nonatomic) NSString *propertyName;

+ (NSDictionary *)propertyDictionaryOfClassHierarchy:(Class)subjectClass onDictionary:(NSMutableDictionary *)propertyMap;
+ (NSDictionary *)propertyDictionaryOfClass:(Class)subjectClass includeSuperClasses:(BOOL)allHierarchy onDictionary:(NSMutableDictionary *)propertyMap;

@end
