//
//  STBViewController.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STBViewController : STBBaseViewController{
    
    __weak IBOutlet UIActivityIndicatorView *_activityIndicatorView;
    __weak IBOutlet UILabel *_lblLoadingMessage;
}

@end
