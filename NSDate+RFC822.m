//
//  NSDateFormatter+dateFromRFC822.m
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import "NSDate+RFC822.h"

@implementation NSDateFormatter (RFC822)

+ (NSDateFormatter *)rfc822Formatter {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
    	formatter = [[NSDateFormatter alloc] init];
    	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    	[formatter setLocale:enUS];
    	[enUS release];
    	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    }
    return formatter;
}

@end


@implementation NSDate (RFC822)

+ (NSDate *)dateFromRFC822:(NSString *)date {
    NSDateFormatter *formatter = [NSDateFormatter rfc822Formatter];
    return [formatter dateFromString:date];
}

@end
