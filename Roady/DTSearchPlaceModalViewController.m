//
//  DTSearchPlaceModalViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTSearchPlaceModalViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PBFoursquareAPI.h"
#import "RoadyCore.h"
#import <CoreLocation/CoreLocation.h>

@interface DTSearchPlaceModalViewController () <PBFoursquareAPIDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *venuesTable;
@property NSArray *venues;
@end

@implementation DTSearchPlaceModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager requestAlwaysAuthorization];
    
    [RoadyCore sharedInstance].foursquare.delegate = self;
    [self searchVenues];
    
    self.venuesTable.delegate = self;
    self.venuesTable.dataSource = self;
}

#pragma mark - TableViewDelegate and DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venueCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"venueCell"];
    }
    
    cell.textLabel.text = ((PBFoursquareVenue *)[self.venues objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ m", ((PBFoursquareVenue *)[self.venues objectAtIndex:indexPath.row]).distance];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate selectVenue:self.venues[indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.venues count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Foursquare search

- (void)searchVenues {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getCurrentLocation];
}

#pragma mark - Foursquare delegate

- (void)getVenuesDidSuccedWithArray:(NSArray *)venues {
    self.venues = [NSArray arrayWithArray:venues];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.venuesTable reloadData];
}

- (void)getVenueDidFailed {
    
}

#pragma mark - Get Location


- (void)getCurrentLocation {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //@TODO - handle error
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        [[RoadyCore sharedInstance].foursquare getVenuesWithLocation: [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]];
        [self.locationManager stopUpdatingLocation];
    }
}

@end
