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
//  TCUVariableType.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUVariableType.h"

@implementation TCUVariableType

- (NSMutableDictionary *)complexTypes {
    if (!_complexTypes) {
        [self willChangeValueForKey:@"complexTypes"];
        _complexTypes = [NSMutableDictionary dictionary];
        [self didChangeValueForKey:@"complexTypes"];
    }
    return _complexTypes;
}

- (void)setTypeWithString:(NSString *)typeString {
    NSString *typeSpecifier = [typeString substringWithRange:NSMakeRange(0, 1)];
    if ([typeSpecifier isEqualToString:@"c"]) {
        self.type = TCUTypeChar;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"i"]) {
        self.type = TCUTypeInt;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"s"]) {
        self.type = TCUTypeShort;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"l"]) {
        self.type = TCUTypeLong;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"q"]) {
        self.type = TCUTypeLongLong;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"C"]) {
        self.type = TCUTypeUnsignedChar;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"I"]) {
        self.type = TCUTypeUnsignedInt;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"S"]) {
        self.type = TCUTypeUnsignedShort;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"L"]) {
        self.type = TCUTypeUnsignedLong;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"Q"]) {
        self.type = TCUTypeUnsignedLongLong;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"f"]) {
        self.type = TCUTypeFloat;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"d"]) {
        self.type = TCUTypeDouble;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"B"]) {
        self.type = TCUTypeBool;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"v"]) {
        self.type = TCUTypeVoid;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"*"]) {
        self.type = TCUTypeCharPointer;
        self.typeAttribute |= TCUTypeAttributePrimitive;
    } else if ([typeSpecifier isEqualToString:@"?"]) {
        self.type = TCUTypeUnknown;
    } else if ([typeSpecifier isEqualToString:@"b"]) {
        NSString *bitFieldSize = [typeString substringFromIndex:1];
        self.size = bitFieldSize.longLongValue;
        self.type = TCUTypeBitField;
    } else if ([typeSpecifier isEqualToString:@"^"]) {
        self.pointedVariableType = [[TCUVariableType alloc] init];
        [self.pointedVariableType setTypeWithString:[typeString substringFromIndex:1]];
        self.type = TCUTypePointer;
        self.typeAttribute |= TCUTypeAttributePointer;
    } else if ([typeSpecifier isEqualToString:@"#"]) {
        self.type = TCUTypeObjCClass;
    } else if ([typeSpecifier isEqualToString:@":"]) {
        self.type = TCUTypeSelector;
    } else if ([typeSpecifier isEqualToString:@"@"]) {
        self.typeAttribute |= TCUTypeAttributeObject;
        if (typeString.length > 2) {
            NSRange lastCharacterRange = NSMakeRange((typeString.length - 1), 1);
            NSRange secondCharacterRange = NSMakeRange(1, 1);
            if ([[typeString substringWithRange:lastCharacterRange] isEqualToString:@"\""] &&
                [[typeString substringWithRange:secondCharacterRange] isEqualToString:@"\""]) {
                NSMutableString *mutableTypeString = [typeString mutableCopy];
                [mutableTypeString deleteCharactersInRange:lastCharacterRange];
                [mutableTypeString deleteCharactersInRange:secondCharacterRange];
                [mutableTypeString deleteCharactersInRange:NSMakeRange(0, 1)];
                self.name = mutableTypeString;
            }
            self.type = TCUTypeClass;
        } else {
            self.type = TCUTypeObjcID;
        }
    } else if ([typeSpecifier isEqualToString:@"["]) {
        NSRange lastCharacterRange = NSMakeRange((typeString.length - 1), 1);
        if ([[typeString substringWithRange:lastCharacterRange] isEqualToString:@"]"]) {
            self.type = TCUTypeArray;
            NSMutableString *mutableTypeString = [typeString mutableCopy];
            [mutableTypeString deleteCharactersInRange:lastCharacterRange];
            [mutableTypeString deleteCharactersInRange:NSMakeRange(0, 1)];
            if (mutableTypeString.length > 0) {
                NSRange sizeRange = [mutableTypeString rangeOfString:@"^\\d+" options:NSRegularExpressionSearch];
                if (sizeRange.location != NSNotFound) {
                    self.size = [mutableTypeString substringWithRange:sizeRange].longLongValue;
                    [mutableTypeString deleteCharactersInRange:sizeRange];
                    self.pointedVariableType = [[TCUVariableType alloc] init];
                    [self.pointedVariableType setTypeWithString:mutableTypeString];
                }
            }
        }
    } else if ([typeSpecifier isEqualToString:@"{"]) {
        NSRange lastCharacterRange = NSMakeRange((typeString.length - 1), 1);
        if ([[typeString substringWithRange:lastCharacterRange] isEqualToString:@"}"]) {
            self.type = TCUTypeStruct;
            NSMutableString *mutableTypeString = [typeString mutableCopy];
            [mutableTypeString deleteCharactersInRange:lastCharacterRange];
            [mutableTypeString deleteCharactersInRange:NSMakeRange(0, 1)];
            if (mutableTypeString.length > 0) {
                if ([mutableTypeString rangeOfString:@"=" options:NSLiteralSearch].location == NSNotFound) {
                    self.name = [NSString stringWithString:mutableTypeString];
                } else {
                    NSArray *structSubTypeComponents = [mutableTypeString componentsSeparatedByString:@"="];
                    if ([structSubTypeComponents isKindOfClass:[NSArray class]]) {
                        self.name = structSubTypeComponents[0];
                        if (structSubTypeComponents.count > 1) {
                            NSString *structSubTypes = structSubTypeComponents[1];
                            if (structSubTypes.length > 0) {
                                if ([structSubTypes rangeOfString:@"\"" options:NSLiteralSearch].location == NSNotFound) {
                                    for (unsigned long i = 0; i < structSubTypes.length; i++) {
                                        NSString *typeDefiner = [structSubTypes substringWithRange:NSMakeRange(i, 1)];
                                        TCUVariableType *subVariableType = [[TCUVariableType alloc] init];
                                        [subVariableType setTypeWithString:typeDefiner];
                                        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                                        NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
                                        CFRelease(uuid);
                                        [self.complexTypes setObject:subVariableType forKey:UUIDString];
                                    }
                                } else {
                                    NSArray *subTypes = [structSubTypes componentsSeparatedByString:@"\""];
                                    if ([subTypes isKindOfClass:[NSArray class]]) {
                                        if (subTypes.count > 0) {
                                            if ((subTypes.count % 2) == 0) {
                                                for (unsigned long i = 0; i < (subTypes.count / 2); i++) {
                                                    TCUVariableType *subVariableType = [[TCUVariableType alloc] init];
                                                    [subVariableType setTypeWithString:subTypes[i + 1]];
                                                    [self.complexTypes setObject:subVariableType forKey:subTypes[i]];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } else if ([typeSpecifier isEqualToString:@"("]) {
        NSRange lastCharacterRange = NSMakeRange((typeString.length - 1), 1);
        if ([[typeString substringWithRange:lastCharacterRange] isEqualToString:@")"]) {
            self.type = TCUTypeUnion;
            NSMutableString *mutableTypeString = [typeString mutableCopy];
            [mutableTypeString deleteCharactersInRange:lastCharacterRange];
            [mutableTypeString deleteCharactersInRange:NSMakeRange(0, 1)];
            if (mutableTypeString.length > 0) {
                if ([mutableTypeString rangeOfString:@"=" options:NSLiteralSearch].location == NSNotFound) {
                    self.name = [NSString stringWithString:mutableTypeString];
                } else {
                    NSArray *unionSubTypeComponents = [mutableTypeString componentsSeparatedByString:@"="];
                    if ([unionSubTypeComponents isKindOfClass:[NSArray class]]) {
                        self.name = unionSubTypeComponents[0];
                        if (unionSubTypeComponents.count > 1) {
                            NSString *unionSubTypes = unionSubTypeComponents[1];
                            if (unionSubTypes.length > 0) {
                                if ([unionSubTypes rangeOfString:@"\"" options:NSLiteralSearch].location == NSNotFound) {
                                    for (unsigned long i = 0; i < unionSubTypes.length; i++) {
                                        NSString *typeDefiner = [unionSubTypes substringWithRange:NSMakeRange(i, 1)];
                                        TCUVariableType *subVariableType = [[TCUVariableType alloc] init];
                                        [subVariableType setTypeWithString:typeDefiner];
                                        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                                        NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
                                        CFRelease(uuid);
                                        [self.complexTypes setObject:subVariableType forKey:UUIDString];
                                    }
                                } else {
                                    NSArray *subTypes = [unionSubTypes componentsSeparatedByString:@"\""];
                                    if ([subTypes isKindOfClass:[NSArray class]]) {
                                        if (subTypes.count > 0) {
                                            if ((subTypes.count % 2) == 0) {
                                                for (unsigned long i = 0; i < (subTypes.count / 2); i++) {
                                                    TCUVariableType *subVariableType = [[TCUVariableType alloc] init];
                                                    [subVariableType setTypeWithString:subTypes[i + 1]];
                                                    [self.complexTypes setObject:subVariableType forKey:subTypes[i]];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@end

