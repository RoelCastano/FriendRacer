//
//  DTNewRaceViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTNewRaceViewController.h"
#import "DTSearchPlaceModalViewController.h"
#import "PBFoursquareVenue.h"
#import "DTFacebookFriendCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <RestKit/RestKit.h>
#import "HMApiClient.h"
#import "Session.h"
#import "MHUser.h"
#import "DTRaceViewController.h"
#import "DTRace.h"

@interface DTNewRaceViewController () <DTSearchPlaceDelegate, UITableViewDelegate, UITableViewDataSource>
@property PBFoursquareVenue *selectedVenue;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (weak, nonatomic) IBOutlet UIButton *venueButton;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UIButton *startRacingButton;
@property (weak, nonatomic) IBOutlet UIView *startRacingWrapper;
@property NSArray *friends;
@property NSMutableArray *selectedFriends;
@end

@implementation DTNewRaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    [self loadFacebookFriends];
    self.startRacingButton.enabled = [self shouldPermitStartRace];
    [self updateStartRaceView];
    self.selectedFriends = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectedVenue) {
        self.venueButton.hidden = YES;
        self.venueLabel.hidden = NO;
        self.venueLabel.text = self.selectedVenue.name;
    }
    else {
        self.venueButton.hidden = NO;
        self.venueLabel.hidden = YES;
    }
}

#pragma mark - TableView delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"facebookFriend"];
    
    if (!cell) {
        cell = [[DTFacebookFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"facebookFriend"];
    }
    
    cell.name.text = self.friends[indexPath.row][@"name"];
    cell.profilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", self.friends[indexPath.row][@"uid"]]]]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DTFacebookFriendCell *cell = ((DTFacebookFriendCell *)[tableView cellForRowAtIndexPath:indexPath]);
    
    if (cell.selectedFriend) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:((NSDictionary *)self.friends[indexPath.row])[@"uid"]];
        cell.selectedFriend = NO;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:((NSDictionary *)self.friends[indexPath.row])[@"uid"]];
        cell.selectedFriend = YES;
    }
    
    self.startRacingButton.enabled = [self shouldPermitStartRace];
    [self updateStartRaceView];
}

#pragma mark - venue delegate

- (void)selectVenue:(PBFoursquareVenue *)venue {
    self.selectedVenue = venue;
    self.startRacingButton.enabled = [self shouldPermitStartRace];
    [self updateStartRaceView];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"placeChoosing"]) {
        ((DTSearchPlaceModalViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - load friends

- (void)loadFacebookFriends {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient getPath:[NSString stringWithFormat:@"api/users/friends"]
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *error;
                    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                    NSMutableArray *results = [[NSMutableArray alloc] init];
                    for (NSDictionary *object in jsonObject) {
                        [results addObject:@{ @"name" : object[@"name"],
                                              @"uid" : object[@"uid"]
                                              }];
                    }
                    self.friends = [NSArray arrayWithArray:results];
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [self.friendsTable reloadData];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
}

#pragma mark - start race

- (BOOL)shouldPermitStartRace {
    return [self.selectedFriends count] > 0 && self.selectedVenue;
}

- (void)updateStartRaceView {
    if (self.startRacingButton.enabled) {
        self.startRacingWrapper.backgroundColor = [UIColor colorWithRed:77.0/255.0 green:119.0/255.0 blue:244.0/255.0 alpha:1.0];
    }
    else {
        self.startRacingWrapper.backgroundColor = [UIColor grayColor];
    }
}
- (IBAction)raceShouldStart:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray *membersArray = [[NSMutableArray alloc] init];
    for (NSString *friendUid in self.selectedFriends) {
        [membersArray addObject:@{@"uid" : friendUid}];
    }
    NSDictionary *params = @{@"race" : @{ @"name" : self.selectedVenue.name,
                                          @"lat" : self.selectedVenue.lat,
                                          @"lng" : self.selectedVenue.lng,
                                          @"members" : membersArray
                                     }};
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:[NSString stringWithFormat:@"api/races"]
              parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *error;
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                    DTRaceViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"raceController"];
                    DTRace *race = [[DTRace alloc] initWithName:jsonObject[@"name"]
                                                          mapId:jsonObject[@"map_id"]
                                                            lat:jsonObject[@"lat"]
                                                            lng:jsonObject[@"lng"]];
                    viewController.game = race;
                    viewController.users = [NSArray arrayWithArray:jsonObject[@"users"]];
                    [self presentViewController:viewController
                                       animated:YES
                                     completion:^{
                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     }];
                }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
}

@end
