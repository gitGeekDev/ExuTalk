//
//  ChatMessageVC.h
//  ChitChat
//
//  Created by Manish Kumar on 04/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "BaseVC.h"
#import "XMPPUserCoreDataStorageObject.h"

@interface ChatMessageVC : BaseVC
+(instancetype)instantiateFromStoryboard;
@property   (nonatomic, strong) XMPPUserCoreDataStorageObject *chatWithUser;
@end
