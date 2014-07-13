//
//  AppDelegate.h
//  ExuTalk
//
//  Created by Manish Kumar on 13/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LoginVC.h"
#import "ConversationVC.h"
#import "XMPPFramework.h"
#import "Helper/AppProtocol.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, XMPPRosterDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	XMPPUserCoreDataStorageObject   *userStorage;
    XMPPCoreDataStorage   *xmppCoreDataStorage;
    
	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    UIBarButtonItem *loginButton;
    //
    //
    //    __weak NSObject <SMChatDelegate> *_chatDelegate;
    //	__weak NSObject <SMMessageDelegate> *_messageDelegate;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

//@property (nonatomic, strong)  LoginVC *loginVc;
//@property (nonatomic, strong)  ConversationVC   *convVc;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

//@property (nonatomic, weak) NSObject<MessageDelegate>*  messageDelegate;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
- (NSManagedObjectContext *)managedObjectContext_coreDataSotrage;


@property (nonatomic, assign) id  chatDelegate;
@property (nonatomic, assign) ConversationVC  *messageDelegate;

- (BOOL)connect;
- (void)disconnect;
//-(void)testMessageArchiving;
-(void)archiveMessageViaDelegate:(XMPPMessage*)message outgoing:(BOOL)isOutgoing;
-(void)fetchVCardForJid:(XMPPJID*)jid;
@property (nonatomic, strong) NTAssetJSON *assets;
#define theAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@end