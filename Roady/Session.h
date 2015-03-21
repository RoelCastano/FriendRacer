//
//  Session.h
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHUser.h"

@interface Session : NSObject

/**
 Specifies the user that is currently loged in.
 */
@property (nonatomic, strong) MHUser *currentUser;

/**
 Returns the active session or creates a new one if there is none.
 @param currentUser ILUser that represent the user that is logged in.
 */
+ (instancetype)newSessionForUser:(MHUser *)currentUser;

/**
 Clears the current session
 */
- (void)clearSessionAndToken;


/**
 Makes a request to reload the current user data and then yields the block
 depending if it succeed or failed
 @param success Block yield if the request succeed
 @param failure Block yield if the request failed
 */
- (void)reloadUserDataWithSuccess:(void (^)())sucess failure:(void (^)())failure;

extern Session *activeSession;


@end
