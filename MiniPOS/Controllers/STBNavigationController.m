//
//  iSMPNavigationController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 10/14/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "STBNavigationController.h"

@interface STBNavigationController ()

@end

@implementation STBNavigationController

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

#pragma mark - Support Orientations

// lower iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    //ipad behavior
    if (INTERFACE_IS_IPAD){
        return YES;
    }
    else{
        //iphone behavior
        if([self canBeRotated])
            return YES;
        
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

- (BOOL)shouldAutorotate {
    //ipad behavior
    if (INTERFACE_IS_IPAD){
        return YES;
    }
    else{
        //iphone behavior
        if([self canBeRotated])
            return YES;
        
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations{
    //ipad behavior
    if (INTERFACE_IS_IPAD){
        return UIInterfaceOrientationMaskAll;
    }
    else{
        //iphone behavior
        if([self canBeRotated])
            return UIInterfaceOrientationMaskAll;
        
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)canBeRotated{
    /*
    if (self.viewControllers && [self.viewControllers count] >= 1){
        id presentedViewController = [self.viewControllers objectAtIndex:self.viewControllers.count-1];
        NSString *className = NSStringFromClass([presentedViewController class]);
        //DLog(@"PresentedViewController: %@", className);
        
        if ([className isEqualToString:NSStringFromClass([XXX class])])]
            ){
            return YES;
        }
    }
    */
    
    return NO;
}

@end
