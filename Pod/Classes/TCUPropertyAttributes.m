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
//  TCUPropertyAttributes.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUPropertyAttributes.h"
#import "objc/runtime.h"

@implementation NSObject (PropertyDictionary)

+ (NSDictionary *)propertyDictionary {
    return [TCUPropertyAttributes propertyDictionaryOfClassHierarchy:[self class] onDictionary:nil];
}

@end

@interface TCUPropertyAttributes()

- (BOOL)parseFromAttributesString:(NSString *)attributes;

@end

@implementation TCUPropertyAttributes

+ (NSDictionary *)propertyDictionaryOfClassHierarchy:(Class)subjectClass onDictionary:(NSMutableDictionary *)propertyMap {
    if (subjectClass == NULL) {
        return nil;
    }
    if (![propertyMap isKindOfClass:[NSMutableDictionary class]]) {
        propertyMap = [NSMutableDictionary dictionary];
    }
    if (subjectClass == [NSObject class]) {
        return [NSDictionary dictionaryWithDictionary:propertyMap];
    } else {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(subjectClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            NSString *propertyName = nil;
            if (propName) {
                propertyName = [NSString stringWithUTF8String:propName];
            }
            const char *attr = property_getAttributes(property);
            NSString *attributes = nil;
            if (attr) {
                attributes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
            }
            if (attributes && propertyName) {
                TCUPropertyAttributes *propertyAttributes = [[TCUPropertyAttributes alloc] init];
                if ([propertyAttributes parseFromAttributesString:attributes]) {
                    propertyAttributes.propertyName = propertyName;
                    [propertyMap setObject:propertyAttributes forKey:propertyName];
                }
            }
        }
        free(properties);
        return [self propertyDictionaryOfClassHierarchy:[subjectClass superclass] onDictionary:propertyMap];
    }
}

- (BOOL)parseFromAttributesString:(NSString *)attributes {
    if ([attributes isKindOfClass:[NSString class]]) {
        if (attributes.length > 0) {
            if (![[attributes substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"T"]) {
                return NO;
            }
            NSArray *components = [attributes componentsSeparatedByString:@","];
            if ([components isKindOfClass:[NSArray class]]) {
                if (components.count > 0) {
                    for (NSString *component in components) {
                        if ([component isKindOfClass:[NSString class]]) {
                            if (component.length > 0) {
                                NSString *attributeSpecifier = [component substringWithRange:NSMakeRange(0, 1)];
                                if ([attributeSpecifier isEqualToString:@"R"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeReadonly;
                                } else if ([attributeSpecifier isEqualToString:@"C"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeCopy;
                                } else if ([attributeSpecifier isEqualToString:@"&"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeRetained;
                                } else if ([attributeSpecifier isEqualToString:@"N"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeNonatomic;
                                } else if ([attributeSpecifier isEqualToString:@"D"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeDynamic;
                                } else if ([attributeSpecifier isEqualToString:@"W"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeWeak;
                                } else if ([attributeSpecifier isEqualToString:@"P"]) {
                                    self.propertyAttribute |= TCUPropertyAttributeGarbageCollectible;
                                } else if ([attributeSpecifier isEqualToString:@"t"]) {
                                    self.oldStyleEncodedType = [component substringFromIndex:1];
                                } else if ([attributeSpecifier isEqualToString:@"G"]) {
                                    self.getter = [component substringFromIndex:1];
                                } else if ([attributeSpecifier isEqualToString:@"S"]) {
                                    self.setter = [component substringFromIndex:1];
                                } else if ([attributeSpecifier isEqualToString:@"V"]) {
                                    self.instanceVariableName = [component substringFromIndex:1];
                                } else if ([attributeSpecifier isEqualToString:@"T"]) {
                                    [self setTypeWithString:[component substringFromIndex:1]];
                                }
                            }
                        }
                    }
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
