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
    
    self.view.backgroundColor = PRIMARY_BACKGROUND_COLOR;
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

#pragma mark - Table View

- (void)setupPlainTableView:(UITableView *)tableView
        showScrollIndicator:(BOOL)showScrollIndicator
                  hasBorder:(BOOL)hasBorder
               hasSeparator:(BOOL)hasSeparator
{
    //scroll Indicator
    [tableView setShowsHorizontalScrollIndicator:showScrollIndicator];
    [tableView setShowsVerticalScrollIndicator:showScrollIndicator];
    
    //border
    if (hasBorder) {
        [tableView.layer setCornerRadius:TABLEVIEW_CORNER_RADIUS];
        [tableView.layer setBorderColor:[self.view.backgroundColor CGColor]];
        [tableView.layer setBorderWidth:1.0];
        [tableView.layer setMasksToBounds:YES];
    }
    
    //separator
    if (hasSeparator){
        //[tableView setSeparatorColor:[currentTheme colorForTableViewSeparator]];
        [self setZeroSeparatorInsetForTableView:tableView];
    }
    else
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //background
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setOpaque:NO];
}

- (void)setupGroupTableView:(UITableView *)tableView
        showScrollIndicator:(BOOL)showScrollIndicator
               hasSeparator:(BOOL)hasSeparator
          shouldUpdateFrame:(BOOL)shouldUpdateFrame
{
    //scroll Indicator
    [tableView setShowsHorizontalScrollIndicator:showScrollIndicator];
    [tableView setShowsVerticalScrollIndicator:showScrollIndicator];
    
    //separator
    if (hasSeparator){
        //[tableView setSeparatorColor:[currentTheme colorForTableViewSeparator]];
        [self setZeroSeparatorInsetForTableView:tableView];
    }
    else{
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    //background
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setOpaque:NO];
    
    //update frame on iOS 7
    if (shouldUpdateFrame)
        [self updateFrameOfGroupTableView:tableView];
}

- (void)updateFrameOfGroupTableView:(UITableView *)tableView{
    if (IOS7_OR_GREATER){
        float padding = 9.0f;
        
        CGRect frame     = tableView.frame;
        frame.origin.x   = padding;
        frame.size.width -= 2*padding;
        tableView.frame = frame;
    }
}

- (void)setZeroSeparatorInsetForTableView:(UITableView *)tableView{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([tableView respondsToSelector: @selector(setSeparatorInset:)])
        [tableView setSeparatorInset:UIEdgeInsetsZero];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
        [tableView setLayoutMargins:UIEdgeInsetsZero];
#endif
}

- (void)setZeroSeparatorInsetForTableViewCell:(UITableViewCell *)cell{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([cell respondsToSelector: @selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
#endif
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
#endif
}

#pragma mark - Support orientations

// Pre-iOS 6 support
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
