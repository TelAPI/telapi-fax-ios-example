//
//  FaxDetailViewViewController.h
//  TelAPIFax
//
//  Created by Matt Williamson on 3/5/13.
//
//

#import <UIKit/UIKit.h>
#import "NSDate+RFC822.h"

@interface FaxDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSDictionary *faxDict;
@property (nonatomic, retain) IBOutlet UIWebView *preview;

- (id)initWithFaxDict:(NSDictionary *)faxDictionary;

@end
