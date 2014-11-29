//
//  UIViewController+PresentViewAnimation.m
//  ImmoScout24
//
//  Created by Phuc Ngo on 12/26/13.
//  Copyright (c) 2013 ImmoScout24. All rights reserved.
//

#import "UIViewController+PresentViewAnimation.h"

@implementation UIViewController (PresentViewAnimation)

#pragma mark - Animation present modal

- (void)presentViewControllerWithModalAnimation:(UIViewController *)controller{
    [self presentViewControllerWithModalAnimation:controller completion:nil];
}

- (void)dismissViewControllerWithModalAnimation:(UIViewController *)controller{
    [self dismissViewControllerWithModalAnimation:controller completion:nil];
}

- (void)presentViewControllerWithModalAnimation:(UIViewController *)controller completion: (void (^)(void))completion{
    // Begin ignoring events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    controller.view.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        if (UIAppDelegate.window.rootViewController == self) {
            frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        controller.view.frame = frame;
    } completion:^(BOOL finished) {
        // End ignoring events
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (completion)
            completion();
    }];
}

- (void)dismissViewControllerWithModalAnimation:(UIViewController *)controller completion: (void (^)(void))completion{
    // Begin ignoring events
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        controller.view.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
        
        // End ignoring events
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if (completion)
            completion();
    }];
}

@end
