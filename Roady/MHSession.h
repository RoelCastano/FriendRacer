//
//  MHSession.h
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHSessionDelegate <NSObject>

-(void)sessionDidLogin:(NSString *)authToken error:(NSError *)error;

@end

@interface MHSession : NSObject

@property NSString *idUserFacebook;
@property (weak) id <MHSessionDelegate> delegate;

-(instancetype)initWithDelegate:(id<MHSessionDelegate>)delegate;
+(instancetype)activeSession;
-(BOOL)isOpen;
-(void)openNewSessionWithOAuthToken:(NSString *)OAuthToken;
+(instancetype)sessionWithDelegate:(id<MHSessionDelegate>)delegate;
- (void)closeSession;
- (void)loadIdUserFromFacebook;
-(void)checkPrintPeriodAvailabilityWithResponseBlock:(void(^)(NSNumber *daysToPrint, NSError *error))responseBlock;
+(void)setupParse;
+(void)setupParseWithDeviceToken:(NSData *)deviceToken;

@end
