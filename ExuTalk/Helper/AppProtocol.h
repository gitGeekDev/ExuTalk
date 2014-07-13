//
//  AppProtocol.h
//  ChitChat
//
//  Created by Manish Kumar on 04/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppProtocol <NSObject>

@end
@protocol ChatDelegate
- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;
@end

@protocol MessageDelegate
- (void)newMessageReceived:(NSDictionary *)messageContent;
@end 