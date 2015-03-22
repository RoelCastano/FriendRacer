//
//  DTFacebookFriendCell.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTFacebookFriendCell.h"

@interface DTFacebookFriendCell()
@property (weak, nonatomic) IBOutlet UIView *profileWrapper;
@end

@implementation DTFacebookFriendCell

- (void)awakeFromNib {
    self.profileWrapper.clipsToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
