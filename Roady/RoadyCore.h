//
//  RoadyCore.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBFoursquareAPI.h"

@interface RoadyCore : NSObject

+(instancetype)sharedInstance;
@property (nonatomic, strong) PBFoursquareAPI *foursquare;
@end
