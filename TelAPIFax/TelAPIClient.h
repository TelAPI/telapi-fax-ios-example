//
//  TelAPIClient.h
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import "Constants.h"
#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface TelAPIClient : AFHTTPClient

+ (TelAPIClient *)sharedClient;

@end
