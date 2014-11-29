//
//  UIViewController+PresentViewAnimation.h
//  ImmoScout24
//
//  Created by Phuc Ngo on 12/26/13.
//  Copyright (c) 2013 ImmoScout24. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PresentViewAnimation)

- (void)presentViewControllerWithModalAnimation:(UIViewController *)controller;
- (void)dismissViewControllerWithModalAnimation:(UIViewController *)controller;
- (void)presentViewControllerWithModalAnimation:(UIViewController *)controller completion: (void (^)(void))completion;
- (void)dismissViewControllerWithModalAnimation:(UIViewController *)controller completion: (void (^)(void))completion;

@end
