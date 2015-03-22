//
//  UIView+blurred.m
//  HKFacebook
//
//  Created by Roel Castano on 11/14/14.
//  Copyright (c) 2014 Roel Castano. All rights reserved.
//

#import "UIView+blurred.h"

@implementation UIView (blurred)

-(UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
