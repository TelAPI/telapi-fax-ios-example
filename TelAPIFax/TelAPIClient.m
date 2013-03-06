//
//  TelAPIClient.m
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import "TelAPIClient.h"

#import "AFJSONRequestOperation.h"

static NSString * const kAFTelAPIBaseURLString = @"https://api.dev.telapi.com/v1/Accounts/%@";

@implementation TelAPIClient

+ (TelAPIClient *)sharedClient {
    static TelAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TelAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:kAFTelAPIBaseURLString, TELAPI_ACCOUNT_SID]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:TELAPI_ACCOUNT_SID password:TELAPI_ACCOUNT_SECRET];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    self.parameterEncoding = AFFormURLParameterEncoding;

    
    return self;
}

@end