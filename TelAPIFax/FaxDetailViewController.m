//
//  FaxDetailViewViewController.m
//  TelAPIFax
//
//  Created by Matt Williamson on 3/5/13.
//
//

#import "FaxDetailViewController.h"

@interface FaxDetailViewController ()

@end

@implementation FaxDetailViewController

@synthesize faxDict, preview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFaxDict:(NSDictionary *)faxDictionary {
    self.faxDict = faxDictionary;
    
    return [super init];
}

//- (void)setFaxDict:(NSDictionary *)faxDict {
//    
//}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url;
    
    if ([[self.faxDict objectForKey:@"direction"] isEqual:@"out"]) {
        url = [NSURL URLWithString:[self.faxDict objectForKey:@"original_url"]];
    } else {
        url = [NSURL URLWithString:[self.faxDict objectForKey:@"processed_url"]];
    }
    
    NSLog(@"Loading %@", url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.preview loadRequest:request];
    
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellEditingStyleNone;
    }
    
    NSDateFormatter *dateFormatter;
    
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"SID";
            cell.detailTextLabel.text = [self.faxDict objectForKey:@"sid"];
            break;
            
        case 1:
            dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSString *startTimeFriendly = [dateFormatter stringFromDate:[NSDate dateFromRFC822:[self.faxDict objectForKey:@"start_time"]]];
            
            cell.textLabel.text = @"Start Time";
            cell.detailTextLabel.text = startTimeFriendly;
            break;
            
        case 2:
            dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            NSString *endTimeFriendly = [dateFormatter stringFromDate:[NSDate dateFromRFC822:[self.faxDict objectForKey:@"end_time"]]];
            
            cell.textLabel.text = @"End Time";
            cell.detailTextLabel.text = endTimeFriendly;
            break;
            
        case 3:
            cell.textLabel.text = @"Direction";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.faxDict objectForKey:@"direction"]];
            break;
            
        case 4:
            cell.textLabel.text = @"Status";
            cell.detailTextLabel.text = [self.faxDict objectForKey:@"status"];
            
            // Show red if there was an error
            if ([[self.faxDict objectForKey:@"status"] isEqualToString:@"success"]) {
                cell.detailTextLabel.textColor = [UIColor blackColor];
            } else if([[self.faxDict objectForKey:@"status"] isEqualToString:@"queued"]) {
                cell.detailTextLabel.textColor = [UIColor grayColor];
            } else if([[self.faxDict objectForKey:@"status"] isEqualToString:@"receiving"] || [[self.faxDict objectForKey:@"status"] isEqualToString:@"sending"]) {
                cell.detailTextLabel.textColor = [UIColor greenColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor redColor];
            }
            break;
        
        case 5:
            cell.textLabel.text = @"To";
            cell.detailTextLabel.text = [self.faxDict objectForKey:@"to"];
            break;
            
        case 6:
            cell.textLabel.text = @"From";
            cell.detailTextLabel.text = [self.faxDict objectForKey:@"from"];
            break;
            
        case 7:
            cell.textLabel.text = @"Pages";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.faxDict objectForKey:@"pages"]];
            break;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDelegate
- (IBAction)viewFaxImage:(id)sender {
    NSURL *url;
    
    if ([[self.faxDict objectForKey:@"direction"] isEqual:@"out"]) {
        url = [NSURL URLWithString:[self.faxDict objectForKey:@"original_url"]];
    } else {
        url = [NSURL URLWithString:[self.faxDict objectForKey:@"processed_url"]];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Fax Detail";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.faxDict release];
    [self.preview release];
    [super dealloc];
}

@end
