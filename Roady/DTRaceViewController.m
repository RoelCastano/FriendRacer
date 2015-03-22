//
//  DTRaceViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTRaceViewController.h"
#import "HKCustomPointAnnotation.h"
#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>

#define kEavesdrop @"https://roady.firebaseio.com/races"


@interface DTRaceViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKAnnotation>
@property (weak, nonatomic) IBOutlet MKMapView *raceMap;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (strong, nonatomic) NSMutableArray *mapAnnotations;
@property (assign) BOOL firstTime;

@end

@implementation DTRaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MAP CONFIGURATION
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

    // Do any additional setup after loading the view.
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
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"schools_maps"];
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
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    view.canShowCallout = YES;
}

- (void)setUsers:(NSArray *)users{
    _users = users;
}

-(void)setGame:(DTRace *)game {
    _game = game;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
