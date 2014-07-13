//
//  NSURLRequest+Extras.h
//  ChargePoint
//
//  Created by Navi Singh on 5/6/14.
//  Copyright (c) 2014 Chargepoint Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Extras)
-(NSString *)curl;

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
-(NSString *)curlDecoded;
@end

@interface NSURL (curl)
-(NSString *)curl;
@end
