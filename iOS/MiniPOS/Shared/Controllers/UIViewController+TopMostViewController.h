//
//  UIViewController+TopMostViewController.h
//  AutoScout24
//
//  Created by Nam Nguyen on 7/4/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TopMostViewController)

- (UIViewController *)topmostViewController;
- (UIViewController *)topmostViewControllerWithRootViewController:(UIViewController *)rootViewController;

@end
