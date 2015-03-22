//
//  DTInvitationPopupViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/22/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTInvitationPopupViewController.h"
#import "HMApiClient.h"
#import <MaryPopin/UIViewController+MaryPopin.h>
#import "DTRaceViewController.h"
#import "DTRace.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DTInvitationPopupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *adminNameLabel;
@property (weak, nonatomic) IBOutlet UIView *participantsView;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *inviteeImage;
@end

@implementation DTInvitationPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.participantsView.layer.cornerRadius = self.participantsView.frame.size.height/2;
    self.participantsView.layer.masksToBounds = YES;
    self.adminNameLabel.text = self.adminName;
    self.placeLabel.text = self.placeName;
    self.containerView.layer.cornerRadius = 8.0f;
    self.containerView.layer.masksToBounds = YES;
    self.inviteeImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", self.adminUid]]]];
    self.inviteeImage.layer.cornerRadius = self.inviteeImage.frame.size.height/2;
    [self.inviteeImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.inviteeImage setClipsToBounds:YES];
    [self.inviteeImage.layer setBorderWidth:1.0f];
    
}

- (IBAction)didClickedAccpet:(id)sender {
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:@"api/users/accept_race"
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self dismissCurrentPopinControllerAnimated:YES completion:^{
                         NSError *error;
                         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                         DTRaceViewController *raceViewController;
                         raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"raceController"];
                         raceViewController.users = [NSArray arrayWithArray:jsonObject[@"race"][@"users"]];
                         
                         raceViewController.game = [[DTRace alloc] initWithName:jsonObject[@"race"][@"name"]
                                                                          mapId:jsonObject[@"race"][@"map_id"]
                                                                            lat:jsonObject[@"race"][@"lat"]
                                                                            lng:jsonObject[@"race"][@"lng"]];
                         [MBProgressHUD showHUDAddedTo:raceViewController.view animated:YES];
                         [self presentViewController:raceViewController
                                            animated:YES
                                          completion:^{
                                              [MBProgressHUD hideAllHUDsForView:raceViewController.view animated:YES];
                                          }];
                     }];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [self dismissCurrentPopinControllerAnimated:YES completion:^{
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error on the request." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [alert show];
                     }];
                 }];
}

- (IBAction)didClickedReject:(id)sender {
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:@"api/races/exit_race"
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [self.presenter dismissCurrentPopinControllerAnimated:YES];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [self dismissCurrentPopinControllerAnimated:YES completion:^{
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error on the request." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [alert show];
                     }];
                 }];
}



@end
