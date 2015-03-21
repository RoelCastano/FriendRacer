//
//  Session.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "Session.h"
#import "HMApiClient.h"

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

- (void)reloadUserData
{
    [MHUser loadUserWithId:self.currentUser.userId
                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       self.currentUser =mappingResult.array[0];
                   }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       [AppDelegate showServeDownAlert];
                   }];
}

- (void)reloadUserDataWithSuccess:(void (^)())sucess failure:(void (^)())failure
{
    [MHUser loadUserWithId:self.currentUser.userId
                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                       self.currentUser =mappingResult.array[0];
                       if (sucess) {
                           sucess();
                       }
                   }
                   failure:^(RKObjectRequestOperation *operation, NSError *error) {
                       [AppDelegate showServeDownAlert];
                       if (failure) {
                           failure();
                       }
                   }];
}

- (void) clearSessionAndToken
{
    [ILApiClient clearAuthorizationToken];
    [[FBSession activeSession] closeAndClearTokenInformation];
    activeSession = nil;
}


@end
