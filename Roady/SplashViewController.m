//
//  SplashViewController.m
//  Roady
//
//  Created by Roel Castano on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "SplashViewController.h"
#import "PBFoursquareAPI.h"
#import "RoadyCore.h"
#import "Session.h"
#import <Parse/Parse.h>
#import "DTRootViewController.h"
#import <RestKit/RestKit.h>
#import "HMApiClient.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DTRaceViewController.h"
#import "DTRace.h"
#import <MaryPopin/UIViewController+MaryPopin.h>
#import "DTInvitationPopupViewController.h"

@interface SplashViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property CLLocationManager *locationManager;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.loginView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    MHUser *currentUser = [[MHUser alloc] initWithName:user.name authToken:[FBSession activeSession].accessTokenData.accessToken andId:user.objectID];
    [Session newSessionForUser:currentUser];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient getPath:[NSString stringWithFormat:@"api/users/current_race"]
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    currentInstallation.channels = @[];
                    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"userId-%@", activeSession.currentUser.userId] forKey:@"channels"];
                    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
                    [currentInstallation saveInBackground];

                    NSError *error;
                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                    if (jsonObject) {
                        if (![jsonObject[@"accepted"] boolValue]){
                            DTRootViewController *raceViewController;
                            raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
                            [self presentViewController:raceViewController
                                               animated:YES
                                             completion:^{
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 DTInvitationPopupViewController *popupController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"invitationPopup"];
                                                 popupController.adminName = jsonObject[@"race"][@"admin_name"];
                                                 popupController.placeName = jsonObject[@"race"][@"name"];
                                                 popupController.game = [[DTRace alloc] initWithName:jsonObject[@"race"][@"name"]
                                                                                               mapId:jsonObject[@"race"][@"map_id"]
                                                                                                 lat:jsonObject[@"race"][@"lat"]
                                                                                                 lng:jsonObject[@"race"][@"lng"]];
                                                 
                                                 BKTBlurParameters *blurParameters = [BKTBlurParameters new];
                                                 blurParameters.alpha = 1.0f;
                                                 blurParameters.radius = 8.0f;
                                                 blurParameters.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                                                 
                                                 [popupController setBlurParameters:blurParameters];
                                                 [popupController setPreferedPopinContentSize:CGSizeMake(280, 300)];
                                                 [popupController setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
                                                 [popupController setPopinAlignment:BKTPopinAlignementOptionCentered];
                                                 [popupController setPopinOptions:BKTPopinDisableAutoDismiss];
                                                 [raceViewController presentPopinController:popupController animated:YES completion:nil];
                                             }];
                        }
                        else {
                            //parse json object to game object
                            DTRaceViewController *raceViewController;
                            raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"raceController"];
                            raceViewController.users = [NSArray arrayWithArray:jsonObject[@"race"][@"users"]];
                            
                            raceViewController.game = [[DTRace alloc] initWithName:jsonObject[@"race"][@"name"]
                                                                             mapId:jsonObject[@"race"][@"map_id"]
                                                                               lat:jsonObject[@"race"][@"lat"]
                                                                               lng:jsonObject[@"race"][@"lng"]];
                            [self presentViewController:raceViewController
                                               animated:YES
                                             completion:^{
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                             }];
                        }
                        
                    }
                    else {
                        DTRootViewController *raceViewController;
                        raceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
                        [self presentViewController:raceViewController
                                           animated:YES
                                         completion:^{
                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                         }];
                        
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
}

@end
