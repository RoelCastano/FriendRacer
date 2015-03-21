//
//  PBFoursquareAPI.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "PBFoursquareAPI.h"
#import "PBFoursquareVenue.h"
#import <CoreLocation/CoreLocation.h>
#import "RoadyCore.h"
#import <RestKit/RestKit.h>

static NSString * const PBFoursquareBaseAPI = @"https://api.foursquare.com/v2";
static NSString * const PBFoursquareClientId = @"0SSGVTREEPC55ZIHTPJSIP4YEHW52SR200TJJVVGGDCXTABB";
static NSString * const PBFoursquareClientSecret = @"X2GQKLMNHGGJ3Y54P0EDUGK1TKBMF04SM0UWCXR1WP2PBHOK";
static NSString * const PBFoursquareVenueFormat = @"venues/explore?client_id=%@&client_secret=%@&v=20130815&ll=%@";

@interface PBFoursquareAPI() <CLLocationManagerDelegate>
@property CLLocationManager *manager;
@property NSString *currentLocation;
@end

@implementation PBFoursquareAPI

- (instancetype)init {
    self = [super init];
    
    if(self) {
        _manager = [[CLLocationManager alloc] init];
    }
    
    return self;
}

+ (void)setup {
    [RoadyCore sharedInstance].foursquare = [[PBFoursquareAPI alloc] init];
}

#pragma mark - Get Venues

- (void)getCurrentLocation {
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.manager startUpdatingLocation];
}

- (void)startGetVenuesRequest {
    [self getCurrentLocation];
}

- (void)getVenues {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:PBFoursquareBaseAPI]];
    [httpClient getPath:[NSString stringWithFormat:PBFoursquareVenueFormat, PBFoursquareClientId, PBFoursquareClientSecret, self.currentLocation]
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSError *error;
                     NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
//                    [self.delegate sessionDidLogin:jsonObject[JSON_AUTH_TOKEN] error:error];
                     NSLog(@"JSON: %@", (NSString *)jsonObject.description);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
//                     [self.delegate ];
                 }];

    [self.delegate getVenuesDidSuccedWithArray:@[]];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.delegate getLocationDidFailedWithError:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        self.currentLocation = [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        [self getVenues];
    }
}

@end
