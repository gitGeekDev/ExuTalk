//
//  BaseVC.m
//  ChitChat
//
//  Created by Manish Kumar on 13/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([theAppDelegate.xmppStream isDisconnected]) {
        if (![theAppDelegate connect]) {
            [self userLoggedOutOfSystem:nil];
        }
    }
}

-(void)userLoggedOutOfSystem:(NSNotification*)notification{
//    if (!self.loginVc) {
//        self.loginVc    =   [LoginVC instantiateFromStoryboard];
//    }
//    [self.navigationController presentViewController:self.loginVc
//                                            animated:YES
//                                          completion:nil];
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

@end
