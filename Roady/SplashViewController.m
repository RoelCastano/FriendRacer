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
    
    DTRootViewController *rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"raceController"];
    [self presentViewController:rootViewController
                       animated:YES
                     completion:nil];
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
