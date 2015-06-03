//
//  Requests.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  Copyright (c) 2015 To&#776;re C&#807;ag&#774;r&#305; Uyar. All rights reserved.
//

#import "Requests.h"

@implementation Requests

@dynamic requestID, requestText, imageURL;

+ (NSMutableDictionary *)propertyToJSONKeyMappingTable {
    NSMutableDictionary *dict = [super propertyToJSONKeyMappingTable];
    [dict setValuesForKeysWithDictionary:@{@"requestID":@"id"}];
    return dict;
}

+ (NSMutableArray *)objectTransformers {
    NSMutableArray *transformers = [super objectTransformers];
    [transformers addObject:[TCUObjectTransformer transformerFrom:[NSString class] to:[NSURL class] onInit:^{
        NSLog(@"Transformer init");
    } transformer:^id(id object) {
        return [NSURL URLWithString:object];
    } reverseTransformer:^id(NSURL *object) {
        return object.absoluteString;
    }]];
    return transformers;
}

+ (NSMutableDictionary *)objectTransformersPerProperty {
    return [super objectTransformersPerProperty];
}

@end
