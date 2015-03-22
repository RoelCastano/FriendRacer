//
//  DTInvitationPopupViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/22/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTInvitationPopupViewController.h"
#import "HMApiClient.h"

@interface DTInvitationPopupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *adminNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@end

@implementation DTInvitationPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adminNameLabel.text = self.adminName;
    self.placeLabel.text = self.placeName;
}

- (IBAction)didClickedAccpet:(id)sender {
    [HMApiClient sharedClient];
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient postPath:@""
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     
                 }];
}

- (IBAction)didClickedReject:(id)sender {

}



@end
