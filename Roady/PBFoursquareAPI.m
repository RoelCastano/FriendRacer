//
//  PBFoursquareAPI.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "PBFoursquareAPI.h"
#import "PBFoursquareVenue.h"
#import "RoadyCore.h"
#import <RestKit/RestKit.h>

static NSString * const PBFoursquareBaseAPI = @"https://api.foursquare.com/v2";
static NSString * const PBFoursquareClientId = @"0SSGVTREEPC55ZIHTPJSIP4YEHW52SR200TJJVVGGDCXTABB";
static NSString * const PBFoursquareClientSecret = @"X2GQKLMNHGGJ3Y54P0EDUGK1TKBMF04SM0UWCXR1WP2PBHOK";
static NSString * const PBFoursquareVenueFormat = @"venues/explore?client_id=%@&client_secret=%@&v=20130815&ll=%@";

@interface PBFoursquareAPI()
@end

@implementation PBFoursquareAPI

+ (void)setup {
    [RoadyCore sharedInstance].foursquare = [[PBFoursquareAPI alloc] init];
}

#pragma mark - Get Venues

- (void)getVenuesWithLocation:(NSString *)location {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:PBFoursquareBaseAPI]];
    [httpClient getPath:[NSString stringWithFormat:PBFoursquareVenueFormat, PBFoursquareClientId, PBFoursquareClientSecret, location]
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSError *error;
                     NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                     NSMutableArray *result = [[NSMutableArray alloc] init];
                     for (NSDictionary *venue in jsonObject[@"response"][@"groups"][0][@"items"]) {
                         PBFoursquareVenue *fsqvenue = [[PBFoursquareVenue alloc] initWithName:venue[@"venue"][@"name"]
                                                                                   latitude:venue[@"venue"][@"location"][@"lat"]
                                                                                  longitude:venue[@"venue"][@"location"][@"lng"]
                                                                                   distance:venue[@"venue"][@"location"][@"distance"]];
                         [result addObject:fsqvenue];
                     }
                     [self.delegate getVenuesDidSuccedWithArray:result];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                     [self.delegate getVenueDidFailed];
                 }];
}



@end
