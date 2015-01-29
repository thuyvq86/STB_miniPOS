//
//  InputAmount.h
//  CardTest
//
//  Created by Christophe Fontaine on 02/03/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface InputAmount : UIViewController <UITextFieldDelegate>{
	IBOutlet UITextField	*amount;
}
@property (nonatomic, retain) 	IBOutlet UITextField       * amount;
@property (nonatomic, retain) 	IBOutlet UILabel           * currency;
@property (nonatomic, retain)   NumberKeypadDecimalPoint   * customKeypad;

@property (nonatomic, assign)   UIViewController           * parent;


-(IBAction)done:(id)sender;

@end
