//
//  DTSearchPlaceModalViewController.h
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBFoursquareVenue.h"

@protocol DTSearchPlaceDelegate <NSObject>
- (void)selectVenue:(PBFoursquareVenue *)venue;
@end

@interface DTSearchPlaceModalViewController : UIViewController
@property id<DTSearchPlaceDelegate> delegate;
@end
