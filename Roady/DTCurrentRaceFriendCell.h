//
//  DTCurrentRaceFriendCell.h
//  Roady
//
//  Created by Patricio Beltrán on 3/22/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTCurrentRaceFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *imageWrapper;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@end
