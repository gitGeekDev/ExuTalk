//
//  ConversationVC.m
//  ChitChat
//
//  Created by Manish Kumar on 26/06/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//
#import "ChatModel.h"
#import "UIImageView+AFNetworking.h"
#import <CoreData/CoreData.h>
#import "UIImageView+Extras.h"

@interface GroupChatCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *lblGroupName;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMessenger;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMessgae;
@property (strong, nonatomic) IBOutlet UILabel *lblUnreadMessageCount;
@end

@implementation GroupChatCell
-(void)updateWithModel:(ChatModel*)model{
    self.lblGroupName.text  =   model.messageSender;
    self.lblLastMessenger.text  =   model.messageSender;
    self.lblLastMessgae.text    =   model.lastMessage;
    self.lblTimeStamp.text =   model.messageTimneStamp;
    [self.iconView setImageWithURL:[NSURL URLWithString:model.senderIconUrl] placeholderImage:[UIImage imageNamed:@"group-icon.png"]];
}
+(NSString *)identifier{
    return NSStringFromClass([self class]);
}
@end

@interface ChatCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *lblUnreadMessageCount;
@property (nonatomic, assign) dispatch_once_t       onceToken;
@end

@implementation ChatCell
//- (AppDelegate *)appDelegate
//{
//	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
//}

-(void)updateWithModel:(XMPPUserCoreDataStorageObject*)model userMessageInfo:(NSDictionary*)messageinfo{
    dispatch_once(&_onceToken, ^{
        [self.iconView roundTheImage];
    });
    
    self.lblUsername.text  =   model.displayName;
    if ([model.jidStr isEqualToString:@"developer.manish.kumar@gmail.com"]) {
        
    }
    if (model.unreadMessages.integerValue > 0) {
        self.lblUnreadMessageCount.text =  model.unreadMessages.stringValue;
    }
    else{
        self.lblUnreadMessageCount.hidden   =   YES;
    }
    self.lblLastMessage.text  =   messageinfo[@"body"];
    NSDate  *date   =   messageinfo[@"timestamp"];
    self.lblTimestamp.text =   [NSDateFormatter localizedStringFromDate:date
                                                              dateStyle:NSDateFormatterNoStyle
                                                              timeStyle:NSDateFormatterShortStyle];;
    
    if (model.photo != nil)
	{
		self.iconView.image =   model.photo;
	}
	else
	{
		NSData *photoData = [[theAppDelegate xmppvCardAvatarModule] photoDataForJID:model.jid];
        
		if (photoData != nil)
			self.iconView.image = [UIImage imageWithData:photoData];
		else
			self.iconView.image = [UIImage imageNamed:@"defaultPerson.png"];
	}

//    [self.iconView setImageWithURL:[NSURL URLWithString:model.senderIconUrl] placeholderImage:[UIImage imageNamed:@"group-icon.png"]];
}
+(NSString *)identifier{
    return NSStringFromClass([self class]);
}
@end

#import "ConversationVC.h"
#import "ChatMessageVC.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPLogging.h"
#import "LoginVC.h"

@interface ConversationVC ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSArray *filteredContentList;
    NSFetchRequest *fetchRequest;
}
@property (strong, nonatomic) IBOutlet UITableView  *tblChats;
@property (strong, nonatomic) IBOutlet UISearchBar  *searchBar;
@property   (nonatomic, strong) NSMutableDictionary *userMessages;
@property   (nonatomic, strong) NSMutableArray      *messageContact;

@end

@implementation ConversationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
+(UIStoryboard *)storyboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StartUp" bundle:nil];
    return storyboard;
}

+(instancetype)instantiateFromStoryboard
{
    ConversationVC *className = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationVC"];
    return className;
}

-(void)showMessageWindowForNotificationMessage:(NSNotification*)notification{
    
}

-(void)testMessageArchiving{
    
    fetchedResultsController    =   nil;
    //contact entity
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *contactEntityDescription = [NSEntityDescription entityForName:[storage contactEntityName]
                                                                inManagedObjectContext:moc];
    
    
    
    //    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSSortDescriptor *jidSort = [[NSSortDescriptor alloc] initWithKey:@"bareJidStr" ascending:NO];
    NSArray *contactSortDescriptors = [NSArray arrayWithObjects:jidSort, nil];
    
    
    
    
    NSFetchRequest *contactFetchRequest = [[NSFetchRequest alloc] init];
    [contactFetchRequest setEntity:contactEntityDescription];
    [contactFetchRequest setSortDescriptors:contactSortDescriptors];
    
    contactFetchRequest.resultType = NSDictionaryResultType;
    NSDictionary * contactEntityProperties = [contactEntityDescription propertiesByName];
    NSPropertyDescription * contactJidProp = [contactEntityProperties objectForKey:@"bareJidStr"];
    NSPropertyDescription * contactBareJidProp = [contactEntityProperties objectForKey:@"streamBareJidStr"];
//    NSPropertyDescription * timeStampProp = [contactEntityProperties objectForKey:@"timestamp"];
    
    contactFetchRequest.propertiesToGroupBy = [NSArray arrayWithObjects:contactJidProp, contactBareJidProp, nil];
    contactFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:contactJidProp, contactBareJidProp, nil];
    contactFetchRequest.returnsDistinctResults = YES;
    [contactFetchRequest setFetchBatchSize:10];
    
    NSError *contactError;
    NSArray *contacts = [moc executeFetchRequest:contactFetchRequest error:&contactError];
    if (!self.messageContact) {
        self.messageContact =   [NSMutableArray new];
    }
    [self.messageContact removeAllObjects];
    [self.messageContact addObjectsFromArray:contacts];
    
    if (!self.userMessages) {
        self.userMessages =   [NSMutableDictionary new];
    }
    [self.userMessages removeAllObjects];

    for (NSDictionary *dictContact in self.messageContact) {
        NSEntityDescription *messageEntityDescription = [NSEntityDescription entityForName:[storage messageEntityName]
                                                                    inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, jidSort, nil];
        
        NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
        [messageFetchRequest setEntity:messageEntityDescription];
        [messageFetchRequest setSortDescriptors:sortDescriptors];
        
        messageFetchRequest.resultType = NSDictionaryResultType;
        NSDictionary * messageEntityProperties = [messageEntityDescription propertiesByName];
        NSPropertyDescription * messageJidProp = [messageEntityProperties objectForKey:@"bareJidStr"];
        NSPropertyDescription * msgProp = [messageEntityProperties objectForKey:@"body"];
        NSPropertyDescription * timeStampProp = [messageEntityProperties objectForKey:@"timestamp"];
        NSPropertyDescription * jid = [messageEntityProperties objectForKey:@"jid"];

        messageFetchRequest.propertiesToGroupBy = [NSArray arrayWithObjects:messageJidProp, msgProp, timeStampProp, jid, nil];
        messageFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:messageJidProp, msgProp, timeStampProp, jid, nil];
        messageFetchRequest.returnsDistinctResults = YES;
        [messageFetchRequest setFetchLimit:1];
        
        NSString *strjid                =   dictContact[@"bareJidStr"];
        NSString *streamBareJidStr      =   dictContact[@"streamBareJidStr"];
        
        NSPredicate *predicate;
        if (streamBareJidStr) {
            predicate   =   [NSPredicate predicateWithFormat:@"bareJidStr ==  %@ AND streamBareJidStr == %@", strjid,streamBareJidStr];
        }
        else{
            predicate   =   [NSPredicate predicateWithFormat:@"bareJidStr ==  %@", strjid];
        }
        [messageFetchRequest setPredicate:predicate];
        NSError *messageError;
        NSArray *messages = [moc executeFetchRequest:messageFetchRequest error:&messageError];
        
        self.userMessages[strjid]   =   messages[0];
    }
    
    [self.tblChats reloadData];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self testMessageArchiving];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageContact =   [NSMutableArray new];
    filteredContentList = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMessageWindowForNotificationMessage:)
                                                 name:kGOTMESSAGENOTIFICATION
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:kNewMessageRecieved
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedOutOfSystem:)
                                                 name:kUserLoggedOut
                                               object:nil];
    // Do any additional setup after loading the view.
}

-(void)newMessageReceived:(NSNotification*)notification{
    [self testMessageArchiving];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTouchEditButton:(id)sender {
}

- (IBAction)didTouchWriteButton:(id)sender {
    [theAppDelegate disconnect];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//- (AppDelegate *)appDelegate
//{
//	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
//}

- (NSFetchedResultsController *)fetchedResultsController
{    
	if (fetchedResultsController == nil && self.messageContact.count)
	{
		NSManagedObjectContext *moc = [theAppDelegate managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
       
        if (self.messageContact.count) {
            NSMutableArray *arr =   [NSMutableArray new];
            for (NSDictionary *dict in self.messageContact) {
                [arr addObject:dict[@"bareJidStr"]];
            }
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr IN %@", arr];
            [fetchRequest setPredicate:predicate];
        }

		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
            //			DDLogError(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tblChats reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
    return numberOfSections;
}
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if (sender == self.tblChats) {
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
            
            int section = [sectionInfo.name intValue];
            switch (section)
            {
                case 0  : return @"Available";
                case 1  : return @"Away";
                default : return @"Offline";
            }
        }
    }
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSInteger   numberOfRows    =   0;
    if (tableView == self.tblChats) {
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
             numberOfRows   =   sectionInfo.numberOfObjects;
        }
    }
    else{
        numberOfRows  =   filteredContentList.count;
    }
	
	return numberOfRows;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tblChats) {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        ChatMessageVC  *chatVc  =   [ChatMessageVC instantiateFromStoryboard];
        chatVc.chatWithUser =   user;
        [self.navigationController pushViewController:chatVc animated:YES];
    }
    else{
        XMPPUserCoreDataStorageObject *user = filteredContentList[indexPath.row];
        
        ChatMessageVC  *chatVc  =   [ChatMessageVC instantiateFromStoryboard];
        chatVc.chatWithUser =   user;
        [self.navigationController pushViewController:chatVc animated:YES];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tblChats) {
        XMPPUserCoreDataStorageObject *model = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        ChatCell *cell   =   [self.tblChats dequeueReusableCellWithIdentifier:[ChatCell.class identifier]];
        NSDictionary    *dictMessage    =   self.userMessages[model.jidStr];
        [cell updateWithModel:model userMessageInfo:dictMessage];
        return cell;
    }

    else{
        XMPPUserCoreDataStorageObject *model = filteredContentList[indexPath.row];
        
        ChatCell *cell   =   [self.tblChats dequeueReusableCellWithIdentifier:[ChatCell.class identifier]];
        NSDictionary    *dictMessage    =   self.userMessages[model.jidStr];
        [cell updateWithModel:model userMessageInfo:dictMessage];
        return cell;
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSManagedObjectContext *moc = [theAppDelegate managedObjectContext_roster];
    NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
    NSString *searchAttribute = @"displayName";

    if (self.messageContact.count) {
        NSMutableArray *arr =   [NSMutableArray new];
        for (NSDictionary *dict in self.messageContact) {
            [arr addObject:dict[@"bareJidStr"]];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr IN %@ AND %K BEGINSWITH[cd] %@", arr,searchAttribute, searchString];
        [fetchRequest setPredicate:predicate];
    }
    else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchString];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    filteredContentList = [moc executeFetchRequest:fetchRequest error:&error];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 84;
}
@end