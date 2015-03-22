//
//  AppDelegate.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RoadyCore.h"
#import <Parse/Parse.h>
#import "DTRootViewController.h"
#import <MaryPopin/UIViewController+MaryPopin.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DTInvitationPopupViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FBLoginView class];
    [FBProfilePictureView class];
    [Parse setApplicationId:@"tOCVLE1A2PEzghDSCvjPnbIvVgizMR9X0lZQ7lgb"
                  clientKey:@"XpC3YNJHVwqV2SDlQnVoPlVgKoRRCZjlOv8Xt7OS"];
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error on register: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DTInvitationPopupViewController *popupController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"invitationPopup"];
    popupController.adminName = userInfo[@"admin"];
    popupController.placeName = userInfo[@"race_name"];
    popupController.game = [[DTRace alloc] initWithName:userInfo[@"race_name"]
                                                  mapId:userInfo[@"race"][@"map_id"]
                                                    lat:userInfo[@"race"][@"lat"]
                                                    lng:userInfo[@"race"][@"lng"]];
    
    BKTBlurParameters *blurParameters = [BKTBlurParameters new];
    blurParameters.alpha = 1.0f;
    blurParameters.radius = 8.0f;
    blurParameters.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    [popupController setBlurParameters:blurParameters];
    [popupController setPreferedPopinContentSize:CGSizeMake(280, 300)];
    [popupController setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    [popupController setPopinAlignment:BKTPopinAlignementOptionCentered];
    [popupController setPopinOptions:BKTPopinDisableAutoDismiss];
    UIViewController *viewcontroller;
    
    if ([self.window.rootViewController.presentedViewController isKindOfClass:[DTRootViewController class]]) {
        viewcontroller = ((DTRootViewController *)self.window.rootViewController.presentedViewController).contentViewController;
    }
    else {
        viewcontroller = self.window.rootViewController.presentedViewController;
    }
    popupController.presenter = viewcontroller;
    [viewcontroller presentPopinController:popupController animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}




- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
