//
//  FaxListViewController.m
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import "FaxListViewController.h"

@interface FaxListViewController ()

@end

@implementation FaxListViewController

@synthesize faxList;

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
    [super didReceiveMemoryWarning];
}

#pragma mark - ListViewController

// This is the core method you should implement
- (void)reloadTableViewDataSource {
	_reloading = YES;
    
    // Here you would make an HTTP request or something like that
    // Call [self doneLoadingTableViewData] when you are done
    [[TelAPIClient sharedClient] getPath:@"/Faxes.json" parameters:nil success:^(id JSON) {
//        NSLog(@"TelAPI Response: %@", JSON);
        
        self.faxList = [JSON objectForKey:@"faxes"];
        
        NSLog(@"TelAPI Response: %@", self.faxList);
//        NSLog(@"Row count 1: %d", self.faxList.count);
        
        [self.table reloadData];
        [self doneLoadingTableViewData];
    } failure:^(NSHTTPURLResponse *operation, NSError *error) {
        
        NSLog(@"Error submitting fax to TelAPI: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error Sending Fax"
                                    message:@"Some error from TelAPI"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Row count: %d", self.faxList.count);
    return self.faxList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    

    NSDictionary *fax = [self.faxList objectAtIndex:indexPath.row];
    
    NSDate *dateUpdated = [NSDate dateFromRFC822:[fax objectForKey:@"date_updated"]];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:dateUpdated];

    
    if([@"out" isEqualToString:[fax objectForKey:@"direction"]]) {
        cell.imageView.image = [UIImage imageNamed:@"56-cloud.png"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [fax objectForKey:@"to"]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"57-download.png"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [fax objectForKey:@"from"]];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", formattedDateString, [fax objectForKey:@"status"]];
    
    
    
    // Show red if there was an error
    if ([[fax objectForKey:@"status"] isEqualToString:@"success"]) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else if([[fax objectForKey:@"status"] isEqualToString:@"queued"]) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else if([[fax objectForKey:@"status"] isEqualToString:@"receiving"] || [[fax objectForKey:@"status"] isEqualToString:@"sending"]) {
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return [NSString stringWithFormat:@"Section %i", section];
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *faxDict = [self.faxList objectAtIndex:indexPath.row];
    FaxDetailViewController *detail = [[[FaxDetailViewController alloc] initWithFaxDict:faxDict] autorelease];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Fax List";
}

- (void)viewDidUnload
{
    [super viewDidUnload]; // Always call superclass methods first, since you are using inheritance
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) dealloc {
    [self.faxList release];
    
    [super dealloc];
}
@end
