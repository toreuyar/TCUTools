//
//  Requests.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  Copyright (c) 2015 To&#776;re C&#807;ag&#774;r&#305; Uyar. All rights reserved.
//

#import "TCUTypeSafeCollection.h"

@interface Requests : TCUTypeSafeCollection

@property (nonatomic) NSNumber *requestID;
@property (nonatomic) NSString *requestText;
@property (nonatomic) NSURL *imageURL;

@end
