//
//  SendMessageOperation.h
//  ChitChat
//
//  Created by Manish Kumar on 13/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendMessageOperation : NSOperation
- (instancetype)initWithMessage:(NSString *)message
                         forJid:(NSString *)forJid;

@end
