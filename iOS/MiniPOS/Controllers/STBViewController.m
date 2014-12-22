//
//  STBViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBViewController.h"
#import "STBCenterViewController.h"

@interface STBViewController ()

@property (strong, nonatomic) STBCenterViewController *centerViewController;

@end

@implementation STBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self addCenterView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateFrameOfView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self updateFrameOfView];
//    [self addCenterView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCenterView{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    UIStoryboard *dashboardStoryBoard = [UIStoryboard storyboardWithName:@"MessagingStoryboard" bundle:nil];
    self.centerViewController = [dashboardStoryBoard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    _centerViewController.view.frame = frame;
    
    STBNavigationController *navController = [[STBNavigationController alloc] initWithRootViewController:_centerViewController];
    navController.navigationBarHidden = YES;
    
    [self addChildViewController:navController];
    [self.view addSubview:navController.view];
}

@end
