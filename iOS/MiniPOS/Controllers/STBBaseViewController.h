//
//  iSMPBaseViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/14/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STBBaseViewController : UIViewController

#pragma mark - Setup for iOS 7 & newer

- (void)updateFrameOfView;

#pragma mark - Table View

- (void)setupPlainTableView:(UITableView *)tableView
        showScrollIndicator:(BOOL)showScrollIndicator
                  hasBorder:(BOOL)hasBorder
               hasSeparator:(BOOL)hasSeparator;

- (void)setupGroupTableView:(UITableView *)tableView
        showScrollIndicator:(BOOL)showScrollIndicator
               hasSeparator:(BOOL)hasSeparator
          shouldUpdateFrame:(BOOL)shouldUpdateFrame;

- (void)updateFrameOfGroupTableView:(UITableView *)tableView;

- (void)setZeroSeparatorInsetForTableView:(UITableView *)tableView;
- (void)setZeroSeparatorInsetForTableViewCell:(UITableViewCell *)cell;

@end
