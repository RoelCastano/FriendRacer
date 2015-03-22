//
//  DTRace.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTRace.h"

@implementation DTRace

- (instancetype)initWithName:(NSString *)name mapId:(NSString *)mapId lat:(NSString *)lat lng:(NSString *)lng {
    self = [super init];
    if (self) {
        _name = name;
        _mapId = mapId;
        _lat = lat;
        _lng = lng;
    }
    return self;
}

@end
