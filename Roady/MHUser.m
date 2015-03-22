//
//  MHUser.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "MHUser.h"

@implementation MHUser

- (id)initWithName:(NSString*)name authToken:(NSString*)auth andId:(NSString*)uid
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        self.name = name;
        self.authToken = auth;
        self.userId= uid;
    }
    return self;
}

@end
