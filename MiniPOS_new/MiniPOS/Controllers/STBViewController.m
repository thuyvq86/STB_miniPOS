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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateFrameOfView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateFrameOfView];
    [self addCenterView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCenterView{
    UIStoryboard *dashboardStoryBoard = [UIStoryboard storyboardWithName:@"MessagingStoryboard" bundle:nil];
    self.centerViewController = [dashboardStoryBoard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    _centerViewController.view.frame = [UIScreen mainScreen].bounds;
    
    STBNavigationController *navController = [[STBNavigationController alloc] initWithRootViewController:_centerViewController];
    navController.navigationBarHidden = YES;
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    navController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor: [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]};
    
    [self addChildViewController:navController];
    [self.view addSubview:navController.view];
}

#pragma mark - Setup for iOS 7 & greater

- (void)updateFrameOfView{
    CGRect frame = self.view.frame;
    if (IOS7_OR_GREATER && frame.origin.y != kStatusBarHeight) {
        frame.origin.y = kStatusBarHeight;
        frame.size.height -= frame.origin.y;
        self.view.frame = frame;
    }
}

@end
