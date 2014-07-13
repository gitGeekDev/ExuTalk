//
//  NetworkDisconnectedVC.m
//  ChitChat
//
//  Created by Manish Kumar on 13/07/14.
//  Copyright (c) 2014 Manish Kumar. All rights reserved.
//

#import "NetworkDisconnectedVC.h"

@interface NetworkDisconnectedVC ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *networkActivityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *btnRetry;

@end

@implementation NetworkDisconnectedVC

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
- (IBAction)didTouchRetry:(id)sender {
    [theAppDelegate connect];
}

@end
