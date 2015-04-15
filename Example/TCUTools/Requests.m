//
//  Requests.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  Copyright (c) 2015 To&#776;re C&#807;ag&#774;r&#305; Uyar. All rights reserved.
//

#import "Requests.h"

@implementation Requests

@dynamic requestID, requestText;

+ (void)initialize {
    [super initialize];
    [self setPropertyToKeyMappingTable:@{@"requestID":@"id"}];
}

@end
