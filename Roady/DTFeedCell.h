//
//  DTFeedCell.h
//  Roady
//
//  Created by Patricio Beltrán on 3/22/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
