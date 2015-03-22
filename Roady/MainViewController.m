//
//  MainViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "MainViewController.h"
#import <REFrostedViewController/REFrostedViewController.h>
#import "DTFeedCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <RestKit/RestKit.h>
#import "HMApiClient.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property NSArray *feed;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    
    [self loadFeed];
    
    UIImage *logoImage = [UIImage imageNamed:@"logo-navbar"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 55.0f, 35.0f)];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:logoImage];
    
    self.navigationItem.titleView = imageView;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuDidOpen:(id)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feed count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedUserCell"];
    
    if (!cell) {
        cell = [[DTFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feedUserCell"];
    }
    
    NSString *yourString = [NSString stringWithFormat:@"%@ %@ to %@.", self.feed[indexPath.row][@"name"], self.feed[indexPath.row][@"message"], self.feed[indexPath.row][@"race_name"]];
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
    NSString *boldString = self.feed[indexPath.row][@"name"];
    NSRange boldRange = [yourString rangeOfString:boldString];
    [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange];
    [cell.messageLabel setAttributedText: yourAttributedString];
    
    [cell.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", self.feed[indexPath.row][@"uid"]]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

#pragma mark - loadFeed
-(void)loadFeed {
    AFHTTPClient *httpClient = [HMApiClient sharedClient];
    [httpClient getPath:@"api/races/feed"
             parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSError *error;
                 NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                 self.feed = [NSArray arrayWithArray:jsonObject];
                 [self.feedTableView reloadData];
             }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"fail");
                }];
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
