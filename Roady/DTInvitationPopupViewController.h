//
//  DTInvitationPopupViewController.h
//  Roady
//
//  Created by Patricio Beltrán on 3/22/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTRace.h"

@interface DTInvitationPopupViewController : UIViewController
@property NSString *adminName;
@property NSString *placeName;
@property NSString *adminUid;
@property DTRace *game;
@property UIViewController *presenter;
@end
