//
//  SettingsVC+Share.h
//  ChitChat
//
//  Created by Manish Kumar on 12/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC (Share) <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
-(void)displaySocialShareOptions;
@end
