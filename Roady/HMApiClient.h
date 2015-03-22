//
//  HMApiClient.h
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "AFHTTPClient.h"
#import <AFNetworking/AFHTTPClient.h>

static NSString * const ILBaseURLString = @"http://roady.herokuapp.com/";

@interface HMApiClient : AFHTTPClient

typedef void(^ AFSuccessBlock)(AFHTTPRequestOperation *operation, NSDictionary *responseObject);
typedef void(^ AFFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

+ (instancetype)sharedClient;
+ (void)setAuthorizationToken:(NSString *)accessToken;
+ (void)clearAuthorizationToken;

@end
