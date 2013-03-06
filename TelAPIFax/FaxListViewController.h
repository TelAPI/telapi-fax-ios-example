//
//  FaxListViewController.h
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import "ListViewController.h"
#import "TelAPIClient.h"
#import "NSDate+RFC822.h"
#import "FaxDetailViewController.h"

@interface FaxListViewController : ListViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *faxList;

- (void)reloadTableViewDataSource;

@end
