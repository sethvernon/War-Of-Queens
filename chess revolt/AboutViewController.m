//
//  AboutViewController.m
//  Chess Revolt - War of Queens
//
//  Created by Seth Vernon on 4/22/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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

- (IBAction)ZoyaApps:(UIButton *)sender
{
    NSURL *Zoya = [NSURL URLWithString:@"http://www.zoyaapps.com"];
    [[UIApplication sharedApplication] openURL:Zoya];
}


- (IBAction)iChoiceAppDesign:(UIButton *)sender
{
    NSURL *iChoice = [NSURL URLWithString:@"http://www.ichoiceappdesign.com"];
    [[UIApplication sharedApplication] openURL:iChoice];
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
