//
//  User.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 15/04/15.
//  Copyright (c) 2015 To&#776;re C&#807;ag&#774;r&#305; Uyar. All rights reserved.
//

#import "TCUTypeSafeCollection.h"
#import "Requests.h"

@interface User : TCUTypeSafeCollection

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *username;
@property (nonatomic) NSArray *requests;

@end
