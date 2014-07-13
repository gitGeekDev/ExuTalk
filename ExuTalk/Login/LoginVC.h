//
//  LoginVC.h
//  ChitChat
//
//  Created by Manish Kumar on 24/06/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "BaseVC.h"
extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;

@interface LoginVC : BaseVC
+(instancetype)instantiateFromStoryboard;
@end
