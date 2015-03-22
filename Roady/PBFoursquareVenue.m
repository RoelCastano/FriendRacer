//
//  PBFoursquareVenue.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "PBFoursquareVenue.h"

@implementation PBFoursquareVenue

- (instancetype)initWithName:(NSString *)name latitude:(NSDecimalNumber *)lat longitude:(NSDecimalNumber *)lng distance:(NSString *)distance {
    self = [super init];
    
    if (self) {
        _name = name;
        _lat = lat;
        _lng = lng;
        _distance = distance;
    }
    
    return self;
}
@end
