//
//  UIButtonBase.h
//  MiniPOS
//
//  Created by Nam Nguyen on 9/28/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonBase : UIButton

//setup
- (void)setTitleColorForType:(ButtonType)buttonType;
- (void)setupBackgroundImageForType:(ButtonType)buttonType;
- (void)setBackgroundImageNormal:(UIImage *)backgroundImageNormal backgroundImageTouch:(UIImage *)backgroundImageTouch;

//texts alignment
- (void)fitButton;
- (void)fitButton:(AlignmentType)alignmentType;

@end
