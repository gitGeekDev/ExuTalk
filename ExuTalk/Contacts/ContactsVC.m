//
//  ContactsVC.m
//  ChitChat
//
//  Created by Manish Kumar on 12/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "ContactsVC.h"
#import "UIImageView+AFNetworking.h"
#import <CoreData/CoreData.h>
#import "UIImageView+Extras.h"

@interface ContactCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
//@property (strong, nonatomic) IBOutlet UILabel *lblLastMessage;
//@property (strong, nonatomic) IBOutlet UILabel *lblTimestamp;
//@property (strong, nonatomic) IBOutlet UILabel *lblUnreadMessageCount;
@property (nonatomic, assign) dispatch_once_t       onceToken;
@end

@implementation ContactCell

-(void)updateWithModel:(XMPPUserCoreDataStorageObject*)model{// userMessageInfo:(NSDictionary*)messageinfo
    dispatch_once(&_onceToken, ^{
        [self.iconView roundTheImage];
    });

    self.lblUsername.text  =   model.displayName;
//    if ([model.jidStr isEqualToString:@"developer.manish.kumar@gmail.com"]) {
//        
//    }
//    if (model.unreadMessages.integerValue > 0) {
//        self.lblUnreadMessageCount.text =  model.unreadMessages.stringValue;
//    }
//    else{
//        self.lblUnreadMessageCount.hidden   =   YES;
//    }
//    self.lblLastMessage.text  =   messageinfo[@"body"];
//    NSDate  *date   =   messageinfo[@"timestamp"];
//    self.lblTimestamp.text =   [NSDateFormatter localizedStringFromDate:date
//                                                              dateStyle:NSDateFormatterNoStyle
//                                                              timeStyle:NSDateFormatterShortStyle];;

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
}
+(NSString *)identifier{
    return NSStringFromClass([self class]);
}
@end

#import "ChatMessageVC.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPLogging.h"
#import "LoginVC.h"
#import "ConversationVC.h"

@interface ContactsVC()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSFetchRequest *fetchRequest;
    NSFetchedResultsController *fetchedResultsController;
    NSArray *filteredContentList;
}
@property (strong, nonatomic) IBOutlet UITableView *tblContacts;

@end

@implementation ContactsVC

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
    ContactsVC *className = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsVC"];
    return className;
}

-(void)showMessageWindowForNotificationMessage:(NSNotification*)notification{
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    filteredContentList = [NSMutableArray new];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTouchEditButton:(id)sender {
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
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

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSManagedObjectContext *moc = [theAppDelegate managedObjectContext_roster];
    NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
    NSString *searchAttribute = @"displayName";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchString];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    filteredContentList = [moc executeFetchRequest:fetchRequest error:&error];
    
    return YES;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tblContacts reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tblContacts) {
        NSInteger numberOfSections = [[[self fetchedResultsController] sections] count];
        return numberOfSections;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if (sender == self.tblContacts) {
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
    if (tableView == self.tblContacts) {
        NSArray *sections = [[self fetchedResultsController] sections];
        
        if (sectionIndex < [sections count])
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
            NSInteger   numberOfRows    =   sectionInfo.numberOfObjects;
            return numberOfRows;
        }
    }
	else{
        return filteredContentList.count;
    }
	return 0;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tblContacts) {
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
    if (tableView == self.tblContacts) {
        XMPPUserCoreDataStorageObject *model = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        ContactCell *cell   =   [self.tblContacts dequeueReusableCellWithIdentifier:[ContactCell.class identifier]];
        [cell updateWithModel:model];
        return cell;
    }
    XMPPUserCoreDataStorageObject *model = filteredContentList[indexPath.row];
    ContactCell *cell = [self.tblContacts dequeueReusableCellWithIdentifier:[ContactCell.class identifier]];
    [cell updateWithModel:model];
    return cell;
}



- (void)searchTableList {
//    NSString *searchString = self.searchBar.text;
    
    //    for (XMPPUserCoreDataStorageObject *user in [self fetchedResultsController]) {
    //        NSComparisonResult result = [tempStr compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
    //        if (result == NSOrderedSame) {
    //            [filteredContentList addObject:tempStr];
    //        }
    //    }
}
@end