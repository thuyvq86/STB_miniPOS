//
//  iSMPBaseViewController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/14/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBBaseViewController.h"

@interface STBBaseViewController ()

@end

@implementation STBBaseViewController

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

#pragma mark - Setup for iOS 7 & greater

- (void)updateFrameOfView{
    CGRect frame = self.view.frame;
    if (IOS7_OR_GREATER && frame.origin.y != kStatusBarHeight) {
        frame.origin.y = kStatusBarHeight;
        frame.size.height -= frame.origin.y;
        self.view.frame = frame;
    }
}

#pragma mark - Support orientations

// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(INTERFACE_IS_IPAD)
        return YES;
    
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate {
    if(INTERFACE_IS_IPAD)
        return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if(INTERFACE_IS_IPAD)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
