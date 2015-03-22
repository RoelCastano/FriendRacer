//
//  Session.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "Session.h"
#import "MHUser.h"
#import "HMApiClient.h"
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>

@implementation Session

Session *activeSession = nil;

+ (instancetype)newSessionForUser:(MHUser *)currentUser
{
    if (activeSession)
        return activeSession;
    
    activeSession = [[self alloc] initWithCurrentUser:currentUser];
    return activeSession;
}

- (instancetype)initWithCurrentUser:(MHUser *)currentUser
{
    self = [super init];
    if (self) {
        self.currentUser = currentUser;
        
        [HMApiClient setAuthorizationToken:currentUser.authToken];
    }
    return self;
}


- (void) clearSessionAndToken
{
    [HMApiClient clearAuthorizationToken];
    [[FBSession activeSession] closeAndClearTokenInformation];
    activeSession = nil;
}


@end
