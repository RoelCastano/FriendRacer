//
//  ViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "ViewController.h"
#import "RoadyCore.h"
#import "PBFoursquareAPI.h"

@interface ViewController () <PBFoursquareAPIDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [RoadyCore sharedInstance].foursquare.delegate = self;
    [self searchVenues];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Foursquare search

- (void)searchVenues {
    //@TODO - start activity indicator
    [[RoadyCore sharedInstance].foursquare startGetVenuesRequest];
}

#pragma mark - Foursquare delegate

- (void)getVenuesDidSuccedWithArray:(NSArray *)venues {
    
}

- (void)getVenueDidFailed {
    
}

- (void)getLocationDidFailedWithError:(NSError *)error {
    
}

@end
