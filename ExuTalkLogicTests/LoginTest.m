//
//  LoginTest.m
//  ExuTalk
//
//  Created by Manish Kumar on 01/08/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoginVC.h"
//#import "AppDelegate.h"

@interface LoginTest : XCTestCase
-(void)testLogin;

@end

@implementation LoginTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}
-(void)testLogin{
    NSString *strName   =   [[NSUserDefaults standardUserDefaults] valueForKey:kXMPPmyJID];
    NSString *strPwd   =	[[NSUserDefaults standardUserDefaults] valueForKey:kXMPPmyPassword];
    
    NSLog(@"%@",strName);
    XCTAssertTrue([@"manish0782@gmail.com" isEqualToString:strName], @"");
    XCTAssertTrue([@"manish7282" isEqualToString:strPwd], @"");
}

@end
