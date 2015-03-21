//
//  MHUser.h
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHUser : NSObject

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *authToken;

@end
