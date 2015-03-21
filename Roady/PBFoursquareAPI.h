//
//  PBFoursquareAPI.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBFoursquareAPIDelegate <NSObject>
- (void)getVenueDidFailed;
- (void)getLocationDidFailedWithError:(NSError *)error;
- (void)getVenuesDidSuccedWithArray:(NSArray *)venues;
@end

@interface PBFoursquareAPI : NSObject
@property id<PBFoursquareAPIDelegate> delegate;
+ (void)setup;
@end
