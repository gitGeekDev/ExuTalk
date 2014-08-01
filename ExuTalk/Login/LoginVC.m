//
//  LoginVC.m
//  ChitChat
//
//  Created by Manish Kumar on 24/06/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

@protocol LoginCellDelegate <NSObject>
-(void)login;
@end

#import "LoginModel.h"

@interface LoginCell : UITableViewCell <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *tfInputField;
@property (strong, nonatomic) NSString *fieldName;
@property   (strong, nonatomic) LoginModel  *model;
@property   (strong, nonatomic) NSObject    *loginDelegate;
@end

@implementation LoginCell
NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

+(NSString*)identifier{
    return [self.class description];
}

-(void)updateWithModel:(LoginModel*)model{
    self.model  =   model;
    
    if ([self.fieldName isEqualToString:@"userName"]) {
        self.tfInputField.text = self.model.userName;
    }
    else{
        self.tfInputField.text = self.model.password;
        self.tfInputField.secureTextEntry   =   YES;
    }
}

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if ([self.fieldName isEqualToString:@"userName"]) {
        [self.model setValue:textField.text forKeyPath:self.fieldName];
        [self setField:textField forKey:kXMPPmyJID];
    }
    else{
        [self.model setValue:textField.text forKeyPath:self.fieldName];
        [self setField:textField forKey:kXMPPmyPassword];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.fieldName isEqualToString:@"password"]) {
        [self setField:textField forKey:kXMPPmyPassword];
        [self.loginDelegate performSelector:@selector(login)];
    }
    return YES;
}
@end

#import "LoginVC.h"
@interface LoginVC ()<UITableViewDataSource, UITableViewDelegate, LoginCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property   (strong, nonatomic) LoginModel  *loginModel;

@end

@implementation LoginVC

-(void)login{
    if ([theAppDelegate connect])
	{
        self.title  = [[[theAppDelegate xmppStream] myJID] bare];
        [self dismissViewControllerAnimated:YES completion:nil];
	} else
	{
		self.title = @"No JID";
	}
}

+(UIStoryboard *)storyboard
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StartUp" bundle:nil];
    return storyboard;
}

+(instancetype)instantiateFromStoryboard
{
    LoginVC *className = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    return className;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)viewWillAppear:(BOOL)animated{
//    self.loginModel.userName = ([[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID])?:@"";
//    self.loginModel.password = ([[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword])?:@"";
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginModel =   [[LoginModel alloc] init];
    self.loginModel.userName    =   @"";
    self.loginModel.password    =   @"";
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapSignUp:(id)sender {
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginCell   *cell   =   [self.tableView dequeueReusableCellWithIdentifier:[LoginCell.class identifier]];
    if (indexPath.row == 0) {
        cell.fieldName  =   @"userName";
    }
    else{
        cell.fieldName  =   @"password";
    }
    [cell updateWithModel:self.loginModel];
    cell.loginDelegate  =   self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
@end
