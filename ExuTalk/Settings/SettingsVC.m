//
//  SettingsVC.m
//  ChitChat
//
//  Created by Manish Kumar on 12/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

@interface settingsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblSettingOption;
@end

@implementation settingsCell
-(void)updateWithModel:(NSString*)strOption{
    self.lblSettingOption.text  = strOption;
}
+(NSString*)identifier{
    return @"settingsCell";
}
@end

typedef enum{
    kSectionSocial,
    kTotalSections
}kSections;

typedef enum{
    kRowAbout,
    kRowTellAFriend,
    kTotalRowsInSocialSection
}kSectionSocialRows;


#import "SettingsVC.h"
#import "SettingsVC+Share.h"
#import "AboutVC.h"
#import "ShareVC.h"

@interface SettingsVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tblSettings;

@end

@implementation SettingsVC

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return kTotalSections;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case kSectionSocial:
            return kTotalRowsInSocialSection;
            break;
            
        default:
            break;
    }
    return 0;
}

-(NSString*)optionForIndex:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case kSectionSocial:
        {
            switch (indexPath.row) {
                case kRowAbout:
                    return NSLocalizedString(@"About", nil);
                    break;
                case kRowTellAFriend:
                    return NSLocalizedString(@"Tell A Friend", nil);
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    return @"";
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString  *strOption  =   [self optionForIndex:indexPath];
    
    settingsCell *cell = [self.tblSettings dequeueReusableCellWithIdentifier:[settingsCell.class identifier]];
    [cell updateWithModel:strOption];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case kSectionSocial:
        {
            switch (indexPath.row) {
                case kRowAbout:
                {
                    AboutVC *aboutVc    =   [AboutVC instantiateFromStoryboard];
                    [self.navigationController pushViewController:aboutVc animated:YES];
                }
                    break;
                case kRowTellAFriend:
                {
                    [self displaySocialShareOptions];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

@end
