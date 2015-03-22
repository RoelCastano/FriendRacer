//
//  DTRaceViewController.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+blurred.h"
#import "UIImage+ImageEffects.h"
#import "DTRace.h"

@interface DTRaceViewController : UIViewController
@property (nonatomic, strong) DTRace *game;
@property (nonatomic, strong) NSArray *users;

- (void)setGame:(DTRace *)game;
- (void)setUsers:(NSArray *)users;

@end
