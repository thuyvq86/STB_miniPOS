//
//  InputAmount.m
//  CardTest
//
//  Created by Christophe Fontaine on 02/03/11.
//  Copyright 2011 Ingenico. All rights reserved.
//

#import "InputAmount.h"
#import "FirstViewController.h"

@implementation InputAmount
@synthesize amount;
@synthesize customKeypad;
@synthesize currency;
@synthesize parent;


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if (customKeypad) {
		customKeypad.currentTextField = textField;
	}
	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {	
    // Show the numberKeyPad 
    if (!self.customKeypad) {
        self.customKeypad = [NumberKeypadDecimalPoint keypadForTextField:textField];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
	if (textField == self.customKeypad.currentTextField) {
		// Hide the number keypad
		[self.customKeypad removeButtonFromKeyboard];
		self.customKeypad = nil;
	}
}



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set focus to the amount text field
    [amount becomeFirstResponder];
    
    //Set the appropriate currency symbol
    NSNumberFormatter * formatter = [[[NSNumberFormatter alloc] init] autorelease];
    self.currency.text = [formatter currencySymbol];
    
    self.title = NSLocalizedString(@"AMOUNT", @"");
    
    self.amount.placeholder = NSLocalizedString(@"AMOUNT", @"");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set the currency to symbol according to the local settings
    //self.currency.text = [[SettingsManager sharedSettingsManager] currency];
}


//Deprecated in iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//Replacement in iOS 6 of shouldAutorotateToInterfaceOrientation
-(BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


-(void)clearItemTableView {
	amount.text = @"";
}

-(IBAction)done:(id)sender {
    
    if ((self.parent != nil) && ([self.parent class] == [FirstViewController class])) {
        [(FirstViewController *)self.parent setAmount:[NSNumber numberWithDouble:[amount.text doubleValue]]];
    }
    
	[self dismissModalViewControllerAnimated:YES];
}

@end
