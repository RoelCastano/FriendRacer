//
//  DTRace.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTRace : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *mapId;
@property (nonatomic, copy) NSString *lat;
@property (nonatomic, copy) NSString *lng;

- (instancetype)initWithName:(NSString *)name mapId:(NSString *)mapId lat:(NSString *)lat lng:(NSString *)lng;
@end
