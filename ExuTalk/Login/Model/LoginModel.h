//
//  LoginModel.h
//  ChitChat
//
//  Created by Manish Kumar on 24/06/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//
@protocol LoginModel <NSObject>

@end
#import <Foundation/Foundation.h>

@interface LoginModel : NSObject
@property (nonatomic, strong)   NSString    *userName;
@property (nonatomic, strong)   NSString    *password;

@end
