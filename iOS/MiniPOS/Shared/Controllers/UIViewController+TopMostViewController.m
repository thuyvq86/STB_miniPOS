//
//  UIViewController+TopMostViewController.m
//  AutoScout24
//
//  Created by Nam Nguyen on 7/4/14.
//  Copyright (c) 2014 AutoScout24. All rights reserved.
//

#import "UIViewController+TopMostViewController.h"

@implementation UIViewController (TopMostViewController)

- (UIViewController *)topmostViewController{
    return [self topmostViewControllerWithRootViewController:self];
}

- (UIViewController *)topmostViewControllerWithRootViewController:(UIViewController *)rootViewController{
    UIViewController *topController = rootViewController;
    
    UIViewController *next = nil;
    while ((next = [self _topMostController:topController]) != nil) {
        topController = next;
    }
    
    return topController;
}

#pragma mark - Private Helpers

- (UIViewController *)_topMostController:(UIViewController *)cont {
    UIViewController *topController = cont;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible)
            topController = visible;
    }
    
    return (topController != cont ? topController : nil);
}

@end
