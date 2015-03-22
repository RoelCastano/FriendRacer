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
#import "DTRootViewController.h"
#import <RestKit/RestKit.h>
#import "HMApiClient.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DTRaceViewController.h"
#import "DTRace.h"

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
                     NSError *error;
                     NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                     UIViewController *viewController;
                     if (jsonObject) {
                         //parse json object to game object
                         viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"raceController"];
                         ((DTRaceViewController *)viewController).game = [[DTRace alloc] initWithName:jsonObject[@"name"]
                                                                                                mapId:jsonObject[@"map_id"]
                                                                                                  lat:jsonObject[@"lat"]
                                                                                                  lng:jsonObject[@"lng"]];
                     }
                     else {
                         viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
                     }
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
