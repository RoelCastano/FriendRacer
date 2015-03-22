//
//  DTRaceViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTRaceViewController.h"
#import "HKCustomPointAnnotation.h"
#import "HKFinalPointAnnotation.h"
#import "MHUser.h"
#import "Session.h"
#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>
#import <RestKit/Restkit.h>
#import "HMApiClient.h"
#import "DTRootViewController.h"
#import "DTCurrentRaceFriendCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

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
@property (strong, nonatomic) NSMutableArray* friends;
@property (strong, nonatomic) NSMutableArray* sortedFriends;
@property (assign) BOOL firstTime;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property NSTimer *timer;

@end

@implementation DTRaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //INITIALIZATIONS
    self.mapAnnotations = [[NSMutableDictionary alloc] init];
    self.friends = [[NSMutableArray alloc] init];
    self.sortedFriends = [[NSMutableArray alloc] init];
    
    [self setupMap];
    
    [self setupFirebase];
    
    HKFinalPointAnnotation *point = [[HKFinalPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([self.game.lat doubleValue], [self.game.lng doubleValue]);
    [point setCoordinate:coordinates];
    [self.raceMap addAnnotation:point];
    
    self.nameLabel.text = self.game.name;
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    [self updateTable];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateTable) userInfo:nil repeats:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void) updateTable {
    NSLog(@"UPDATE TABLE BABYYYYY");
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int k = 0; k<self.friends.count; k++){
        NSDictionary *user = self.friends[k];
        NSArray *arr = [user allValues];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if ([arr[0][@"lat"] floatValue] != 0) {
            [dic setObject:arr[0][@"name"] forKeyedSubscript:@"name"];
            NSString *dist = arr[0][@"distance"];
            int dist2 = [dist intValue];
            if (dist2 > 50) {
                [dic setObject:dist forKeyedSubscript:@"distance"];
            } else {
                [dic setObject:@"0" forKeyedSubscript:@"distance"];
            }
            [dic setObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", [[user allKeys] objectAtIndex:0]] ] forKeyedSubscript:@"image"];
        }
        else {
            [dic setObject:self.users[k][@"name"] forKeyedSubscript:@"name"];
            [dic setObject:@"-1" forKeyedSubscript:@"distance"];
            [dic setObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", self.users[k][@"uid"]]] forKey:@"image"];
        }
        [result addObject:dic];
    }
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    
    self.sortedFriends = [result sortedArrayUsingDescriptors:sortDescriptors];
    [self.friendsTableView reloadData];
}

-(void)setupFirebase{
    self.firebaseUsersURL = [NSString stringWithFormat:@"%@/%@/users", kRoadyFirebase, self.game.mapId];
    NSLog(@"%@",self.firebaseUsersURL);
    self.roadyFirebase = [[Firebase alloc] initWithUrl:self.firebaseUsersURL];
    
    
    self.userFirebaseURL = [NSString stringWithFormat:@"%@/%@/users/%@", kRoadyFirebase, self.game.mapId, activeSession.currentUser.userId];
    NSLog(@"%@",self.userFirebaseURL);
    self.userFirebase = [[Firebase alloc] initWithUrl:self.userFirebaseURL];
    
    [self updateUserLoc];
    
    [self.roadyFirebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        HKCustomPointAnnotation *point = [[HKCustomPointAnnotation alloc] init];
        
        NSString *lat = snapshot.value[@"lat"];
        NSString *lng = snapshot.value[@"lng"];
        
        [self.friends addObject:@{snapshot.key : snapshot.value}];
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
        
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        for (NSDictionary *friend in self.friends) {
            [keys addObject:[[friend allKeys] objectAtIndex:0]];
        }
        NSInteger i =[keys indexOfObject:snapshot.key];
        [self.friends removeObjectAtIndex:i];
        [self.friends addObject:@{snapshot.key : snapshot.value}];
        
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
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude), MKCoordinateSpanMake(.036f, .036f));
        [self.raceMap setRegion:region animated:NO];
        self.firstTime = NO;
    }
    
    [self updateUserLoc];
}

-(void)updateUserLoc{
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[self.game.lat doubleValue] longitude:[self.game.lng doubleValue]];
    
    CLLocationDistance dist = [self.locationManager.location distanceFromLocation:loc2];
    CLLocationSpeed speed = [self.locationManager.location speed];
    [self.userFirebase updateChildValues:@{
                                           @"lat": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude],
                                           @"lng": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude],
                                           @"distance": [NSString stringWithFormat:@"%i", (int)dist],
                                           @"speed": [NSNumber numberWithDouble:speed],
                                           @"name": activeSession.currentUser.name
                                           }];
}

- (IBAction)currentLocationButtonPressed:(id)sender {
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude), MKCoordinateSpanMake(.036f, .036f));
    [self.raceMap setRegion:region animated:NO];
    
}

#pragma mark - MAPS


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id ) annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[HKFinalPointAnnotation class]]) {
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NotCustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"NotCustomPinAnnotationView"];
            pinView.canShowCallout = NO;
            pinView.image = [UIImage imageNamed:@"place-pin"];
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
            UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", ((HKCustomPointAnnotation*)annotation).userID]]]];
            UIGraphicsBeginImageContext( CGSizeMake(30, 30));
            [icon drawInRect:CGRectMake(0,0,30,30)];
            UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            pinView.image = newImage;
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

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    view.canShowCallout = NO;
}

- (void)setUsers:(NSArray *)users{
    _users = users;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    [self.userFirebase removeAllObservers];
    [self.roadyFirebase removeAllObservers];
    [self.timer invalidate];
}

-(void)setGame:(DTRace *)game {
    _game = game;
}
- (IBAction)iWontGoClicked:(id)sender {
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:@"api/races/exit_race"
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self.userFirebase removeValue];
                     DTRootViewController *raceViewController;
                     raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
                     [self presentViewController:raceViewController
                                        animated:YES
                                      completion:nil];
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
    
    cell.nameLabel.text = self.sortedFriends[indexPath.row][@"name"];
    
    int r = ([self.sortedFriends[indexPath.row][@"distance"] intValue]);
    if (r> 999 && r > 0) {
        cell.distanceLabel.text = [NSString stringWithFormat:@"%i kms", r/1000];
    } else if (r > 50) {
        cell.distanceLabel.text = [NSString stringWithFormat:@"%i mts", r];
    } else if (r == -1){
        cell.distanceLabel.text = @"Pending";
    }
    else {
        cell.distanceLabel.text = @"Arrived";
    }
    
    [cell.profilePicture sd_setImageWithURL:self.sortedFriends[indexPath.row][@"image"]];
    return cell;
    
}
- (IBAction)arriveButtonPressed:(id)sender {
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:[NSString stringWithFormat:@"api/races/arrive"]
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"SUCCESS");
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error: %@", error);
                 }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

@end
