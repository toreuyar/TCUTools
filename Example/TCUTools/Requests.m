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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(requestText)) options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(requestText))];
}

+ (NSMutableDictionary *)propertyToJSONKeyMappingTable {
    NSMutableDictionary *dict = [super propertyToJSONKeyMappingTable];
    [dict setValuesForKeysWithDictionary:@{@"requestID":@"id"}];
    return dict;
}

+ (NSMutableArray *)objectTransformers {
    NSMutableArray *transformers = [super objectTransformers];
    [transformers addObject:[TCUObjectTransformer transformerFrom:[NSString class] to:[NSURL class] onInit:^(TCUObjectTransformer *transformer) {
        NSLog(@"Transformer init");
    } transformer:^id(TCUObjectTransformer *transformer, NSString *object) {
        return [NSURL URLWithString:object];
    } reverseTransformer:^id(TCUObjectTransformer *transformer, NSURL *object) {
        return object.absoluteString;
    }]];
    return transformers;
}

+ (NSMutableDictionary *)objectTransformersPerProperty {
    return [super objectTransformersPerProperty];
}

- (void)setRequestText:(NSString *)requestText {
    [super setProperty:NSStringFromSelector(@selector(requestText)) object:requestText];
    NSLog(@"Custom setter");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(requestText))]) {
            NSLog(@"Value changed!");
            return;
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
