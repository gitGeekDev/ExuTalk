//
//  ChatModel.h
//  ChitChat
//
//  Created by Manish Kumar on 02/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

@protocol ChatModel  <NSObject>

@end

#import <Foundation/Foundation.h>

@interface ChatModel : NSObject
@property (nonatomic, strong)   NSString    *userName;
@property (nonatomic, strong)   NSString    *lastMessage;
@property (nonatomic, strong)   NSString    *messageId;
@property (nonatomic, strong)   NSString    *messageSender;
@property (nonatomic, strong)   NSString    *messageTimneStamp;
@property (nonatomic, strong)   NSArray     *messageList;
@property (nonatomic, strong)   NSString    *senderIconUrl;
@end
