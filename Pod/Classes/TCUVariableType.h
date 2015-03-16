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
//  TCUVariableType.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TCUTypeAttribute) {
    TCUTypeAttributePrimitive  = 1 << 0,
    TCUTypeAttributePointer    = 1 << 1,
    TCUTypeAttributeObject     = 1 << 2
};

typedef NS_ENUM(NSUInteger, TCUType) {
    TCUTypeChar,
    TCUTypeInt,
    TCUTypeShort,
    TCUTypeLong,
    TCUTypeLongLong,
    TCUTypeUnsignedChar,
    TCUTypeUnsignedInt,
    TCUTypeUnsignedShort,
    TCUTypeUnsignedLong,
    TCUTypeUnsignedLongLong,
    TCUTypeFloat,
    TCUTypeDouble,
    TCUTypeBool,
    TCUTypeVoid,
    TCUTypeCharPointer,
    TCUTypeUnknown,
    TCUTypeBitField,
    TCUTypePointer,
    TCUTypeObjCClass,
    TCUTypeSelector,
    TCUTypeObjcID,
    TCUTypeArray,
    TCUTypeStruct,
    TCUTypeUnion,
    TCUTypeClass
};

@interface TCUVariableType : NSObject

@property (nonatomic) TCUType type;
@property (nonatomic) TCUTypeAttribute typeAttribute;
@property (nonatomic) long long size;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) TCUVariableType *pointedVariableType;
@property (strong, nonatomic) NSMutableDictionary *complexTypes;

- (void)setTypeWithString:(NSString *)typeString;

@end
