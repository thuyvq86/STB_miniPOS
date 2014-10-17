//
//  ApplicationThemeManager.h
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationThemeDelegate.h"
//Custom controls
#import "UIButtonBase.h"
#import "UIButtonPrimary.h"
#import "UIButtonSecondary.h"

@interface ApplicationThemeManager : NSObject

+ (id <ApplicationThemeDelegate>)sharedTheme;

//custom style for navigation bar
+ (void)themeForNavigationBar:(UINavigationBar *)navigationBar;

@end
