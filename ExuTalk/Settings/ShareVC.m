//
//  ShareVC.m
//  ChitChat
//
//  Created by Manish Kumar on 12/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "ShareVC.h"

@interface ShareVC ()<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation ShareVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIActionSheet   *actionSheet    =   [[UIActionSheet alloc] initWithTitle:@""
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Twitter", nil), NSLocalizedString(@"Email", nil), nil];
    [actionSheet showInView:self.view];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            [self facebookTapped];
        }
            break;
        case 1:
        {
            [self tweetTapped];
        }
            break;
        case 2:
        {
            [self emailTapped];
        }
            break;
            
        default:
            break;
    }
}

-(void)facebookTapped{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheet addURL:[NSURL URLWithString:@"codeforce.wordpress.com"]];
        [self presentViewController:fbSheet animated:YES completion:nil];
    }
    else
    {
        
        [UIAlertView showWithTitle:NSLocalizedString(@"Sorry", nil) message:NSLocalizedString(@"You can't send an update to Facebook right now, make sure your device has an internet connection and you have at least one Twitter account setup.", )];
    }
}

- (void)tweetTapped{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet addURL:[NSURL URLWithString:@"codeforce.wordpress.com"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Sorry", nil) message:NSLocalizedString(@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup.", )];
    }
}

-(void)emailTapped{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"Talk on the go - Checkout the ChitChat Mobile App", nil)];
        [mc setMessageBody:@"codeforce.wordpress.com" isHTML:NO];
        [mc setToRecipients:nil];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else{
        [UIAlertView showWithMessage:NSLocalizedString(@"", nil)];
                [UIAlertView showWithTitle:NSLocalizedString(@"Sorry", nil) message:NSLocalizedString(@"Your device is not confiured to send e-mail.", )];
    }
}
@end
