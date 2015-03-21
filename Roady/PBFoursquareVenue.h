//
//  PBFoursquareVenue.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBFoursquareVenue : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDecimalNumber *lat;
@property (nonatomic, copy) NSDecimalNumber *lng;
@property (nonatomic, copy) NSString *distance;
@end
