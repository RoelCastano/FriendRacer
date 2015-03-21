//
//  RoadyCore.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "RoadyCore.h"

static RoadyCore *sharedInstance;

@implementation RoadyCore

- (instancetype)init {
    if (sharedInstance) {
        return sharedInstance;
    }
    self = [super init];
    if (self) {
        sharedInstance = self;
    }
    return self;
}

+ (instancetype)sharedInstance {
    @autoreleasepool {
        return (sharedInstance) ? sharedInstance : [[RoadyCore alloc] init];
    }
}

@end
