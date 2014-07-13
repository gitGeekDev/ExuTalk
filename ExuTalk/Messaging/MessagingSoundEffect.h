//
//  MessagingSoundEffect.h
//  ChitChat
//
//  Created by Manish Kumar on 05/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MessagingSoundEffect : NSObject
+ (void)playMessageReceivedSound;
+ (void)playMessageSentSound;
@end
