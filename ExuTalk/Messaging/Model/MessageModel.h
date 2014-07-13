//
//  MessageModel.h
//  ChitChat
//
//  Created by Manish Kumar on 05/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

@protocol MessageModel <NSObject>

@end

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
@property   (nonatomic, strong) NSString    *msg;
@property   (nonatomic, strong) NSString    *sender;
@property   (nonatomic, strong) NSString    *timeStamp;
@property   (nonatomic)         BOOL        isOutGoing;
@end
