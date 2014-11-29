//
//  TestTableViewController.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 28/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "TestTableViewController.h"
#import "BasicTest.h"

@interface TestTableViewController ()

#define kListTestsByCategory	(0)
#define kListAllTests			(1)

-(void)_reorder:(id)sender;
@end

@implementation TestTableViewController
@synthesize _tableView;
@synthesize testGroup, testCategoryManager;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.testCategoryManager = [[[TestCategoryManager alloc] initWithBaseGroupName:self.testGroup] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"group" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(_reorder:)] autorelease];
	self.navigationItem.rightBarButtonItem.tag = kListTestsByCategory;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark ordering methods
-(void)_reorder:(id)sender {
	self.navigationItem.rightBarButtonItem.tag = !self.navigationItem.rightBarButtonItem.tag;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if( self.navigationItem.rightBarButtonItem.tag == kListAllTests) {
		return 1;		
	} else {
	    return [testCategoryManager.categories count];	
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if ( self.navigationItem.rightBarButtonItem.tag == kListTestsByCategory) {
		return [[testCategoryManager testListForCategory:[testCategoryManager.categories objectAtIndex:section]] count];		
	} else {
		return [[testCategoryManager testListForCategory:@""] count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	Class testClass = nil;
	if ( self.navigationItem.rightBarButtonItem.tag == kListTestsByCategory) {
		testClass = NSClassFromString([[testCategoryManager testListForCategory:[testCategoryManager.categories objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]);
	} else {
		testClass = NSClassFromString([[testCategoryManager testListForCategory:@""] objectAtIndex:indexPath.row]);
	}

    cell.textLabel.text = [NSString stringWithFormat:@"%@%@ - %@", [testClass prefixLetter], [testClass testNumber], [testClass title]];
	cell.detailTextLabel.text = [testClass subtitle];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ( self.navigationItem.rightBarButtonItem.tag == kListTestsByCategory) {
		return [testCategoryManager.categories objectAtIndex:section];
	} else {
		return @"All tests";
	}
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	Class testClass = nil;
   	if ( self.navigationItem.rightBarButtonItem.tag == kListTestsByCategory) {
		testClass = NSClassFromString([[testCategoryManager testListForCategory:[testCategoryManager.categories objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]); 
	} else {
		testClass = NSClassFromString([[testCategoryManager testListForCategory:@""] objectAtIndex:indexPath.row]); 
	}

    UIViewController *detailViewController = [[testClass alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.testCategoryManager = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

