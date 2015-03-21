//
//  HMApiClient.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "HMApiClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>

static NSString * const ILApiVersion = @"1";

@implementation HMApiClient

+ (instancetype)sharedClient {
    static HMApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HMApiClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/", ILBaseURLString]]];
    });
    
    return _sharedClient;
    
}

+ (void)setAuthorizationToken:(NSString *)accessToken
{
    [self.sharedClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=%@", accessToken]];
}

+ (void)clearAuthorizationToken
{
    [self.sharedClient setDefaultHeader:@"Authorization" value:nil];
}


- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [self setDefaultHeader:@"Accept" value:[NSString stringWithFormat:@"application/vnd.moneypool.mx+json; version=%@", ILApiVersion]];
    }
    
    return self;
}

@end
