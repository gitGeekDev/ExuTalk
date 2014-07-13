//
//  SendMessageOperation.m
//  ChitChat
//
//  Created by Manish Kumar on 13/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "SendMessageOperation.h"

@interface SendMessageOperation()
@property   (nonatomic, readwrite, strong) NSString    *strMessage;
@property   (nonatomic, readwrite, strong) NSString    *strJid;
@end

@implementation SendMessageOperation
- (instancetype)initWithMessage:(NSString *)strMessage
                   forJid:(NSString *)forJid{
    
    if (self = [super init]) {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:strMessage];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:forJid];
        [message addChild:body];
        [theAppDelegate.xmppStream sendElement:message];
    }
    return self;
}

#pragma mark -
#pragma mark - sending message

// 3: Regularly check for isCancelled, to make sure the operation terminates as soon as possible.
- (void)main {
    // 4: Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool, because blocks are more efficient. You might use NSAuoreleasePool instead and that would be fine.
    @autoreleasepool {
        if (self.isCancelled)
            return;
        }
}

@end
