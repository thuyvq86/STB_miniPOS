//
//  BundleImagePicker.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 07/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "BundleImagePicker.h"


@interface BundleImagePicker ()

@property (nonatomic, copy) NSString * selectedBitmapName;

@end


@implementation BundleImagePicker

@synthesize imageView;
@synthesize bitmapNames;
@synthesize selectedBitmapName;
@synthesize delegate;


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self.bitmapNames count] > 0) {
        NSString * bitmapPath = [self.bitmapNames objectAtIndex:0];
        NSString * bitmapExtension = [bitmapPath pathExtension];
        NSString * bitmapName = [bitmapPath stringByDeletingPathExtension];
        
        self.selectedBitmapName = bitmapPath;
        
        self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bitmapName ofType:bitmapExtension]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -


#pragma mark UI Actions

-(IBAction)done:(id)sender {
    if ([(NSObject *)self.delegate respondsToSelector:@selector(bundleImagePickerDidSelectBitmapWithName:)]) {
        [self.delegate bundleImagePickerDidSelectBitmapWithName:self.selectedBitmapName];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [self.bitmapNames count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString * bitmapName = [self.bitmapNames objectAtIndex:indexPath.row];
    
	cell.textLabel.text = bitmapName;
    if ([bitmapName isEqualToString:self.selectedBitmapName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark -



#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * bitmapPath = [self.bitmapNames objectAtIndex:indexPath.row];
    NSString * bitmapExtension = [bitmapPath pathExtension];
    NSString * bitmapName = [bitmapPath stringByDeletingPathExtension];
    
    self.selectedBitmapName = bitmapPath;
    
	self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:bitmapName ofType:bitmapExtension]];
    
    [tableView reloadData];
}

#pragma mark -


@end
