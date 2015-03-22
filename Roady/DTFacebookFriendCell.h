//
//  DTFacebookFriendCell.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFacebookFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, assign) BOOL selectedFriend;
@end
