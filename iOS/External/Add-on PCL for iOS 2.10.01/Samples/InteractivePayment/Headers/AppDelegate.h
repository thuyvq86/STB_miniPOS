//
//  AppDelegate.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;


//Load the signature view to landscape mode
//-(void)loadSignatureViewInLandscapeModeWithSize:(CGSize)size andParent:(UIViewController *)parent;


@end
