//
//  UIImageView+Extras.m
//  ChitChat
//
//  Created by Manish Kumar on 07/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "UIImageView+Extras.h"

@implementation UIImageView (Extras)
-(void)roundTheImage{
    CALayer *layer  =   self.layer;
    layer.cornerRadius  =   self.frame.size.width / 2;
    self.clipsToBounds = YES;
}
@end
