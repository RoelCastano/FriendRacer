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
@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *lng;
@property (nonatomic, copy) NSString *distance;

- (instancetype)initWithName:(NSString *)name latitude:(NSString *)lat longitude:(NSString *)lng distance:(NSString *)distance;
@end
