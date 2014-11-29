//
//  AppInfoController.m
//  MiniPOS
//
//  Created by Nam Nguyen on 11/29/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "AppInfoController.h"
#import <iSMP/revision.h>

@implementation AppInfoController

@synthesize appVersion;
@synthesize libiSMPVersion;
@synthesize delegate;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([_navBar respondsToSelector:@selector(setBarTintColor:)])
        [_navBar setBarTintColor:PRIMARY_BACKGROUND_COLOR];
    else
        [_navBar setTintColor:PRIMARY_BACKGROUND_COLOR];
    [_navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                      NSFontAttributeName:[UIFont systemFontOfSize:21.0f]
                                      }];
    
    [_barButtonItemDone setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    //Get the app version
    self.appVersion.text = [AppUtils appVersion];
    self.libiSMPVersion.text = [ICISMPVersion substringFromIndex:6];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UI Actions

- (IBAction)done:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didFinishAppInfoController:)])
        [delegate didFinishAppInfoController:self];
}

@end
