//
//  ChatMessageVC.m
//  ChitChat
//
//  Created by Manish Kumar on 04/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//


#import "MessageModel.h"
#import "AppProtocol.h"
#import "UIImageView+Extras.h"
@interface ChatOutgoing : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *chatMessage;
@property (nonatomic, assign) dispatch_once_t       onceToken;
@property (nonatomic, assign) CGFloat               gapBetweenMessageAndBottom;
@property (nonatomic)           CGFloat             heightRequired;
@property (strong, nonatomic) IBOutlet UIImageView *imgChatBgImage;
@property   (strong, nonatomic) MessageModel    *model;
@end

@implementation ChatOutgoing
-(void)updateWithModel:(MessageModel*)model{
    self.model  =   model;
    self.chatMessage.text   =   [NSString stringWithFormat:@"%@\n%@",self.model.msg, self.model.timeStamp];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    dispatch_once(&_onceToken, ^{
        self.gapBetweenMessageAndBottom = self.contentView.bottom - self.chatMessage.bottom;
        self.contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
    });
    
    [self.chatMessage adjustBottomToFit];
    self.imgChatBgImage.frame   =   self.chatMessage.frame;
    self.imgChatBgImage.image = [self.imgChatBgImage.image stretchableImageWithLeftCapWidth:15 topCapHeight:10];
    self.heightRequired = self.chatMessage.bottom + self.gapBetweenMessageAndBottom;
    CGRect  imageFrame  =   self.imgChatBgImage.frame;
    imageFrame.size =   CGSizeMake(self.chatMessage.frame.size.width + 20, self.chatMessage.frame.size.height+15);
    imageFrame.origin.x =   self.chatMessage.frame.origin.x - 5;
    imageFrame.origin.y =   self.chatMessage.frame.origin.y - 5;
    self.imgChatBgImage.frame = imageFrame;
}
@end

@interface ChatIncoming : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgChatBgImage;
@property (strong, nonatomic) IBOutlet UILabel *chatMessage;
@property (nonatomic, assign) dispatch_once_t       onceToken;
@property (nonatomic, assign) CGFloat               gapBetweenMessageAndBottom;
@property (nonatomic)           CGFloat             heightRequired;
@property   (strong, nonatomic) MessageModel    *model;

@end

@implementation ChatIncoming
-(void)updateWithModel:(MessageModel*)model{
    self.model  =   model;
    self.chatMessage.text   =   [NSString stringWithFormat:@"%@\n%@",self.model.msg, self.model.timeStamp];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    dispatch_once(&_onceToken, ^{
        self.gapBetweenMessageAndBottom = self.contentView.bottom - self.chatMessage.bottom;
        self.contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.autoresizesSubviews=YES;
    });
    
    [self.chatMessage adjustBottomToFit];
    self.imgChatBgImage.frame   =   self.chatMessage.frame;
    self.imgChatBgImage.image = [self.imgChatBgImage.image stretchableImageWithLeftCapWidth:15 topCapHeight:10];
    self.heightRequired = self.chatMessage.bottom + self.gapBetweenMessageAndBottom;
    CGRect  imageFrame  =   self.imgChatBgImage.frame;
    imageFrame.size =   CGSizeMake(self.chatMessage.frame.size.width + 20, self.chatMessage.frame.size.height+15);
    imageFrame.origin.x =   self.chatMessage.frame.origin.x - 15;
    imageFrame.origin.y =   self.chatMessage.frame.origin.y - 5;

    self.imgChatBgImage.frame = imageFrame;
}
@end

#import "ChatMessageVC.h"
#import "MessagingSoundEffect.h"
#import "NSString+Utils.h"
#import "UITextView+Extras.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "SendMessageOperation.h"

@interface ChatMessageVC ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MessageDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSManagedObjectContext *moc;
    CGFloat maxHeightForInputView;
    CGFloat defaultHeightForInputView;
}
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UITableView *tblChats;
@property (strong, nonatomic) IBOutlet UITextView *tfInput;
@property (assign)            BOOL                                isViewAlreadyAdjustedForKeyboardPresence;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDownGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUpGesture;
@property (strong, nonatomic) IBOutlet UIView *bottomInputView;
@property   (strong, nonatomic) NSMutableArray<MessageModel>      *chatList;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UIButton *btnOptions;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property   (nonatomic, strong) UIImage *sendImage;
@property   (nonatomic, strong) NSOperationQueue    *messageOperationQueue;
@end

@implementation ChatMessageVC

-(void)showEarlierMessagesFromStorage:(BOOL)fetchLast{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    
    if (!moc) {
        moc = [storage mainThreadManagedObjectContext];
        
    }

    NSEntityDescription *messageEntityDescription = [NSEntityDescription entityForName:[storage messageEntityName]
                                                                inManagedObjectContext:moc];
    
    
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    [messageFetchRequest setEntity:messageEntityDescription];
    messageFetchRequest.returnsDistinctResults = YES;
    NSSortDescriptor *sd1;
    
    if (fetchLast) {
        sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        [messageFetchRequest setFetchLimit:1];
    }
    else{
        sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        [messageFetchRequest setFetchBatchSize:10];
    }

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    [messageFetchRequest setSortDescriptors:sortDescriptors];

    [messageFetchRequest setReturnsObjectsAsFaults:NO];
    NSString *strjid                =   self.chatWithUser.jidStr;
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"bareJidStr ==  %@", strjid];
    [messageFetchRequest setPredicate:predicate1];
    
    NSError *error;
    NSArray *messages = [moc executeFetchRequest:messageFetchRequest error:&error];
    
    [self print:messages fetchLast:fetchLast];
}

- (NSOperationQueue *)messageOperationQueue {
    if (!_messageOperationQueue) {
        _messageOperationQueue = [[NSOperationQueue alloc] init];
        _messageOperationQueue.name = @"Message Operation Queue";
        _messageOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _messageOperationQueue;
}


-(void)print:(NSArray*)messages fetchLast:(BOOL)fetchLast{
    @autoreleasepool {
        
        if (fetchLast) {
            for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
                if (message.body) {
                    MessageModel *messageModel  =   [MessageModel new];
                    messageModel.sender =   message.bareJidStr;
                    messageModel.msg    =   message.body;
                    messageModel.timeStamp  =   [NSDateFormatter localizedStringFromDate:message.timestamp
                                                                               dateStyle:NSDateFormatterShortStyle
                                                                               timeStyle:NSDateFormatterShortStyle];
                    if (message.outgoing.integerValue > 0) {
                        messageModel.isOutGoing =   YES;
                    }
                    
                    [self.chatList addObject:messageModel];
                    [self.tblChats reloadData];
//                    [self.tblChats beginUpdates];
//                    [self.tblChats insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.chatList.count
//                                                                               inSection:0]]
//                                         withRowAnimation:UITableViewRowAnimationRight];
//                    [self.chatList addObject:messageModel];
//                    [self.tblChats endUpdates];
                }
            }
        }
        else{
            for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
                if (message.body) {
                    MessageModel *messageModel  =   [MessageModel new];
                    messageModel.sender =   message.bareJidStr;
                    messageModel.msg    =   message.body;
                    messageModel.timeStamp  =   [NSDateFormatter localizedStringFromDate:message.timestamp
                                                                               dateStyle:NSDateFormatterShortStyle
                                                                               timeStyle:NSDateFormatterShortStyle];
                    if (message.outgoing.integerValue > 0) {
                        messageModel.isOutGoing =   YES;
                    }
                    
                    [self.chatList addObject:messageModel];
                }
            }
        }
    }
    
    [self scrollToBottomAnimated:YES];
}

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
    ChatMessageVC *className = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatMessageVC"];
    return className;
}
- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tblChats numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tblChats scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

-(void)sendMessage:(NSString*)strMessage completionHandler:(void (^)())handler{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:strMessage];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.chatWithUser.jidStr];
    [message addChild:body];
    
    [theAppDelegate.xmppStream sendElement:message];
    
        if (handler) {
            handler();
        }
}

- (IBAction)didTouchSendMessage:(id)sender {
    
    if (self.tfInput.text.length) {
        [self sendMessage:self.tfInput.text completionHandler:^{
        self.tfInput.text   =   @"";
        }];
        [self showEarlierMessagesFromStorage:YES];
        [MessagingSoundEffect playMessageSentSound];
    }

    
//    SendMessageOperation    *sendOperation  =   [[SendMessageOperation alloc] initWithMessage:self.tfInput.text
//                                                                                       forJid:self.chatWithUser.jidStr];

//    [sendOperation setCompletionBlock:^{
//        [self showEarlierMessagesFromStorage:YES];
//        [MessagingSoundEffect playMessageSentSound];
//    }];
//    [self.messageOperationQueue addOperation:sendOperation];
}

- (IBAction)didTouchOptions:(id)sender {
    UIActionSheet   *actionSheet    =   [[UIActionSheet alloc] initWithTitle:@""
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"Take Photo or Video", nil),
                                         NSLocalizedString(@"Choose Existing Photo", nil),
                                         NSLocalizedString(@"Choose Existing Video", nil),
                                         NSLocalizedString(@"Share Location", nil),
                                         NSLocalizedString(@"Share Contact", nil),
                                         nil];
    [actionSheet showInView:self.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.sendImage = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{  // after animation
    switch (buttonIndex) {
        case 0:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
            }
            else{
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
        }
            break;
        case 1:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
            }
            else{
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
        }
            break;
        case 2:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
            }
            else{
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];

                [self presentViewController:picker animated:YES completion:NULL];
            }
        }
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        default:
            break;
    }
}

- (IBAction)didTouchBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)newMessageReceived:(NSNotification *)notification{
    dispatch_async_main(^{
        NSString    *notificationForJid =   notification.userInfo[@"newMessageRecievedForJid"];
        if ([notificationForJid isEqualToString:self.chatWithUser.jidStr]) {
            [self showEarlierMessagesFromStorage:YES];
            [MessagingSoundEffect playMessageReceivedSound];
        }
    });
//    dispatch_async_default(^{
//        NSString    *notificationForJid =   notification.userInfo[@"newMessageRecievedForJid"];
//        if ([notificationForJid isEqualToString:self.chatWithUser.jidStr]) {
//            [self showEarlierMessagesFromStorage:YES];
//            [MessagingSoundEffect playMessageReceivedSound];
//        }
//    });
}

-(void)registerForKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver: self
    //                                             selector: @selector(keyboardDidShow:)
    //                                                 name: UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification object:nil];
    
}

- (IBAction)handleTApGesture:(id)sender {
    [self.tfInput endEditing:YES];
}
- (IBAction)handleSwipeGesture:(id)sender {
    [self.tfInput endEditing:YES];
}
- (IBAction)handleSwipeUpGesture:(id)sender {
    [self.tfInput becomeFirstResponder];
}

#pragma  mark - textview delegate
//-(void)textViewDidChange:(UITextView *)textView
//{
//    NSString *text = [textView text];
//    UIFont *font = [textView font];
//    CGRect frame    =   textView.frame;
//    
//    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 9999) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    if (size.height < maxHeightForInputView) {
//        [self adjustTextInputViewForHeight:size.height];
//    }
//    /* Adjust text view width with "size.height" */
//}

-(void)adjustTextInputViewForHeight:(CGFloat)proposedTextViewHeight{
    CGRect frame    =   self.tfInput.frame;
    
    frame.size.height  =   (frame.size.height > proposedTextViewHeight) ? frame.size.height : proposedTextViewHeight;
    
    self.tfInput.frame = frame;

    [self adjustTextViewContainerViewForTextHeight:proposedTextViewHeight];
}

-(void)adjustTextViewContainerViewForTextHeight:(CGFloat)textViewHeight{
    CGRect frame    =   self.bottomInputView.frame;
    frame.size.height  =   textViewHeight;
    self.bottomInputView.frame  =   frame;
}

#pragma mark - Keyboard notificaitons
- (void) keyboardWillShow: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        if (!self.isViewAlreadyAdjustedForKeyboardPresence)
        {
            CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            CGRect  tableRect = self.tblChats.frame;
            tableRect.size.height   -=  kbSize.height;
            [self.tblChats setFrame:tableRect];
            
            CGFloat inputViewYCoordinate =   self.view.frame.size.height - (kbSize.height + self.bottomInputView.frame.size.height);
            CGRect inPutViewRect    =   self.bottomInputView.frame;
            inPutViewRect.origin.y  =   inputViewYCoordinate;
            self.bottomInputView.frame = inPutViewRect;
            
            [self enableSwipeDownGesture:YES];
            self.isViewAlreadyAdjustedForKeyboardPresence =   YES;
        }
        
        //change the frame of your talbleiview via kbsize.height
    } completion:^(BOOL finished) {
    }];
}
- (NSTimeInterval) keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary * info = [notification userInfo];
    NSValue* value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue: &duration];
    
    return duration;
}
-(void)enableSwipeDownGesture:(BOOL)enableSwipeDown{
    self.swipeDownGesture.enabled   =   enableSwipeDown;
    self.swipeUpGesture.enabled =   !enableSwipeDown;
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification
{
    [UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
        if (self.isViewAlreadyAdjustedForKeyboardPresence)
        {
            CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            CGRect  tableRect = self.tblChats.frame;
            tableRect.size.height   +=  kbSize.height;
            [self.tblChats setFrame:tableRect];
            
            CGFloat inputViewYCoordinate =   self.view.frame.size.height - self.bottomInputView.frame.size.height;
            CGRect inPutViewRect    =   self.bottomInputView.frame;
            inPutViewRect.origin.y  =   inputViewYCoordinate;
            self.bottomInputView.frame = inPutViewRect;
            [self enableSwipeDownGesture:NO];
            self.isViewAlreadyAdjustedForKeyboardPresence =   NO;
        }
        
    } completion:^(BOOL finished) {
    }];
}
-(void)setupUserImage{
    [self.userImage roundTheImage];
    
    if (self.chatWithUser.photo != nil)
	{
		self.userImage.image =   self.chatWithUser.photo;
	}
	else
	{
		NSData *photoData = [[theAppDelegate xmppvCardAvatarModule] photoDataForJID:self.chatWithUser.jid];
        
		if (photoData != nil)
			self.userImage.image = [UIImage imageWithData:photoData];
		else
			self.userImage.image = [UIImage imageNamed:@"defaultPerson.png"];
	}
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNewMessageRecieved
                                                  object:nil];
}

-(void)vCardReceived:(NSNotification*)notification{
    XMPPvCardTemp *vCard  =   [theAppDelegate.xmppvCardTempModule vCardTempForJID:self.chatWithUser.jid shouldFetch:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [theAppDelegate.xmppvCardTempModule fetchvCardTempForJID:self.chatWithUser.jid ignoreStorage:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:kNewMessageRecieved
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vCardReceived:)
                                                 name:kNotifyVardRecived
                                               object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotification];

    //input default view
    defaultHeightForInputView =   self.tfInput.frame.size.height;
    maxHeightForInputView   =   50;
    self.chatList   =   (NSMutableArray<MessageModel>*)[NSMutableArray new];
    
    self.messageOperationQueue  =   [NSOperationQueue new];
    
    [self showEarlierMessagesFromStorage:NO];
    
    self.lblUserName.text    =  self.chatWithUser.displayName;
    [self.tfInput roundTheCorners];
    [self setupUserImage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
//    switch (result) {
//        case MessageComposeResultCancelled:
//            
//            break;
//        case MessageComposeResultSent:
//            
//            break;
//        case MessageComposeResultFailed:
//            
//            break;
//            
//        default:
//            break;
//    }
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    ChatFooter *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatFooter"];
//
//    return cell.frame.size.height;
    return CGFLOAT_MIN;
}

//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    ChatFooter *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatFooter"];
//    
//    return cell;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel   *msgModel  =   self.chatList[indexPath.row];
    if (msgModel.isOutGoing) {//[msgModel.sender isEqualToString:@"you"] ||
        ChatOutgoing *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatOutgoing"];
        cell.chatMessage.text   =[NSString stringWithFormat:@"%d",indexPath.row];
        [cell updateWithModel:msgModel];
        [cell layoutSubviews];
        return cell.heightRequired;
    }
    ChatIncoming *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatIncoming"];
    cell.chatMessage.text   =  [NSString stringWithFormat:@"%d",indexPath.row];
    [cell updateWithModel:msgModel];
    [cell layoutSubviews];
    return cell.heightRequired;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel   *msgModel  =   self.chatList[indexPath.row];
    if (msgModel.isOutGoing) {  //[msgModel.sender isEqualToString:@"you"]  ||
        ChatOutgoing *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatOutgoing"];
        [cell updateWithModel:msgModel];
        [cell layoutSubviews];
        return cell;
    }
    ChatIncoming *cell    =   [self.tblChats dequeueReusableCellWithIdentifier:@"ChatIncoming"];
    [cell updateWithModel:msgModel];
    [cell layoutSubviews];
    return cell;
}




@end
