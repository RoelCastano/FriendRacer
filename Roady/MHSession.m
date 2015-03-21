//
//  MHSession.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "MHSession.h"

static MHSession *session;

@implementation MHSession

-(instancetype)init{
    if (session) {
        return session;
    }
    self = [super init];
    if (self) {
        session = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityDidChange:) name:AWSCognitoIdentityIdChangedNotification object:nil];
        [self recoverFacebookSession];
        if (self.isOpen) {
            [self loadIdUserFromFacebook];
            [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"Authorization" value:[self authToken]];
            [self setAmazonAWSLoginsToken];
            //[self setupParse];
        }
    }
    return self;
}


// This is an example implementation of the selector
-(void)identityDidChange:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"identity changed from %@ to %@",
          [userInfo objectForKey:AWSCognitoNotificationPreviousId],
          [userInfo objectForKey:AWSCognitoNotificationNewId]);
    
    // your application logic here to handle the identity change.
}


-(instancetype)initWithDelegate:(id<MHSessionDelegate>)delegate{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

+(instancetype)activeSession{
    @autoreleasepool {
        return (session)?session:[[PR2Session alloc] init];
    }
}

+(instancetype)sessionWithDelegate:(id<MHSessionDelegate>)delegate{
    @autoreleasepool {
        if (session) {
            session.delegate = delegate;
            return session;
        }
        return [[PR2Session alloc] initWithDelegate:delegate];
    }
}

-(NSString *)authToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_SESSION_KEY];
}

-(void)setAuthToken:(NSString *)authToken{
    [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:USER_DEFAULTS_SESSION_KEY];
}

-(BOOL)isOpen{
    if ([[FBSession activeSession] isOpen]) {
        if ([self authToken]) {
            return YES;
        } else {
            [self closeFacebookSession];
        }
    }
    return NO;
}

-(void)openNewSessionWithOAuthToken:(NSString *)OAuthToken{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_BASE_URL,SERVER_BASE_PATH]]];
    [httpClient postPath:[NSString stringWithFormat:@"%@%@",SERVER_BASE_PATH,SERVER_PATH_SESSIONS] parameters:@{@"oauth_token":[[[FBSession activeSession] accessTokenData] description]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        [self setAuthToken:jsonObject[JSON_AUTH_TOKEN]];
        //[[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithToken:[self authToken]];
        [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"Authorization" value:[self authToken]];
        [self setIdUserPR2Server:jsonObject[JSON_USER_ID]];
        [self setAmazonAWSLoginsToken];
        //[self setupParse];
        [self.delegate sessionDidLogin:jsonObject[JSON_AUTH_TOKEN] error:error];
        NSLog(@"JSON: %@", (NSString *)jsonObject.description);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.delegate sessionDidLogin:nil error:error];
    }];
}

- (void)closeSession{
    [PR2Photo eraseAllPhotosAndDBEntries];
    [PR2Address eraseAllDBEntries];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_USER_ID_FACEBOOK_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULTS_USER_ID_KEY];
    self.idUserFacebook = nil;
    [[RKObjectManager sharedManager].HTTPClient clearAuthorizationHeader];
    [self closeFacebookSession];
    [self closeInstagramSession];
    [self closeTwitter];
    [self ereaseAmazonAWSLoginsToken];
    [PrintooCore setAddressArray:[NSMutableArray array]];
    [PrintooCore setPictureArray:[NSMutableArray array]];
}

- (void)closeFacebookSession{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}

- (void)recoverFacebookSession{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        //[self.facebook openActiveSessionFacebookWithPermissions:@[@"basic_info",@"email"]];
        [[ILFacebookApi facebookApi] openActiveSessionFacebookWithPermissions:FACEBOOK_PERMISSIONS];
    }
}


-(NSString *)idUserPR2Server{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_USER_ID_KEY];
}

-(void)setIdUserPR2Server:(NSString *)idUserPR2Server{
    [[NSUserDefaults standardUserDefaults] setObject:idUserPR2Server forKey:USER_DEFAULTS_USER_ID_KEY];
}


@end
