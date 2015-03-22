//
//  DTRootViewController.m
//  Roady
//
//  Created by Patricio Beltrán on 3/21/15.
//  Copyright (c) 2015 Da Team. All rights reserved.
//

#import "DTRootViewController.h"

@interface DTRootViewController ()

@end

@implementation DTRootViewController

-(void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"content"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    self.limitMenuViewSize = YES;
}

@end
