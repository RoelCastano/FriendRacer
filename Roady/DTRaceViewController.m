//
//  DTRaceViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTRaceViewController.h"
#import "HKCustomPointAnnotation.h"
#import "MHUser.h"
#import "Session.h"
#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>
#import <RestKit/Restkit.h>
#import "HMApiClient.h"
#import "DTRootViewController.h"
#import "DTCurrentRaceFriendCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kRoadyFirebase @"https://roady.firebaseio.com/races"


@interface DTRaceViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKAnnotation>
@property (weak, nonatomic) IBOutlet MKMapView *raceMap;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) NSMutableDictionary *mapAnnotations;
@property (strong, nonatomic) Firebase *roadyFirebase;
@property (strong, nonatomic) NSString *firebaseUsersURL;
@property (strong, nonatomic) Firebase *userFirebase;
@property (strong, nonatomic) NSString *userFirebaseURL;
@property (assign) BOOL firstTime;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation DTRaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZATIONS
    self.mapAnnotations = [[NSMutableDictionary alloc] init];
    
    [self setupMap];
    
    [self setupFirebase];
    
    self.nameLabel.text = self.game.name;
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
}

-(void)setupFirebase{
    self.firebaseUsersURL = [NSString stringWithFormat:@"%@/%@/users", kRoadyFirebase, self.game.mapId];
    NSLog(@"%@",self.firebaseUsersURL);
    self.roadyFirebase = [[Firebase alloc] initWithUrl:self.firebaseUsersURL];
    
    
    self.userFirebaseURL = [NSString stringWithFormat:@"%@/%@/users/%@", kRoadyFirebase, self.game.mapId, activeSession.currentUser.userId];
    NSLog(@"%@",self.userFirebaseURL);
    self.userFirebase = [[Firebase alloc] initWithUrl:self.userFirebaseURL];
    
    [self.userFirebase updateChildValues:@{
                                           @"lat": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude],
                                           @"lng": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude]
                                           }];
    
    [self.roadyFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"------------------CHILD ADDED------------------");
        HKCustomPointAnnotation *point = [[HKCustomPointAnnotation alloc] init];
        NSString *lat = snapshot.value[@"lat"];
        NSString *lng = snapshot.value[@"lng"];
        point.userID = snapshot.key;
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        [point setCoordinate:coordinates];
        [self.raceMap addAnnotation:point];
        [self.mapAnnotations setObject:point forKey:snapshot.key];
        NSLog(@"The updated location key is %@", snapshot.key);
        
    }];
    
    [self.roadyFirebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        HKCustomPointAnnotation *point = [self.mapAnnotations objectForKey:snapshot.key];
        point.userID = snapshot.key;
        [self.raceMap removeAnnotation:point];
        NSString *lat = snapshot.value[@"lat"];
        NSString *lng = snapshot.value[@"lng"];
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        [point setCoordinate:coordinates];
        [self.raceMap addAnnotation:point];
        NSLog(@"The updated location key is %@", snapshot.key);
    }];
    
}

-(void)setupMap{
    
    [self.raceMap setDelegate:self];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    [self.locationManager requestAlwaysAuthorization];
    
    self.firstTime = YES;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude), MKCoordinateSpanMake(.05f, .05f));
    [self.raceMap setRegion:region animated:NO];
    
    [self.locationManager startUpdatingLocation];
    self.raceMap.showsUserLocation = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (self.firstTime) {
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude), MKCoordinateSpanMake(.009f, .009f));
        [self.raceMap setRegion:region animated:NO];
        self.firstTime = NO;
    }
    
    [self.userFirebase updateChildValues:@{
                                           @"lat": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude],
                                           @"lng": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude]
                                           }];
}

- (IBAction)currentLocationButtonPressed:(id)sender {
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude), MKCoordinateSpanMake(.009f, .009f));
    [self.raceMap setRegion:region animated:NO];
    
}

#pragma mark - MAPS


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id ) annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[HKCustomPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = NO;
            pinView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", ((HKCustomPointAnnotation*)annotation).userID]]]];
            [pinView.layer setCornerRadius:pinView.frame.size.width/2];
            [pinView setClipsToBounds:YES];
            //HKCustomButton* rightButton = [HKCustomButton buttonWithType:UIButtonTypeDetailDisclosure];
            //rightButton.event = ((HKCustomPointAnnotation*)annotation).event;
            //[rightButton addTarget:self action:@selector(eventButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            //pinView.rightCalloutAccessoryView = rightButton;
            // Add an image to the left callout.
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

/*
 
 - (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
 MKAnnotationView *aV;
 for (aV in views) {
 CGRect endFrame = aV.frame;
 
 aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
 
 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:0.45];
 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
 [aV setFrame:endFrame];
 [UIView commitAnimations];
 
 }
 }*/

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    view.canShowCallout = NO;
}

- (void)setUsers:(NSArray *)users{
    _users = users;
}

-(void)setGame:(DTRace *)game {
    _game = game;
}
- (IBAction)iWontGoClicked:(id)sender {
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:@"api/races/exit_race"
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self dismissViewControllerAnimated:YES completion:^{
                         DTRootViewController *raceViewController;
                         raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
                         [self presentViewController:raceViewController
                                            animated:YES
                                          completion:^{
                                          }];
                     }];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error on the request." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                     [alert show];
                 }];
}

#pragma mark - TableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTCurrentRaceFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendOnRaceCell"];
    
    if (!cell) {
        cell = [[DTCurrentRaceFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendOnRaceCell"];
    }
    
    cell.nameLabel.text = @"Roel Cataño";
    cell.distanceLabel.text = @"12 KM";
    
    [cell.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", @"10206435959880648"]]];
    
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
