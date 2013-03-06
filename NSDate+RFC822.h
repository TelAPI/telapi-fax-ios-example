//
//  NSDateFormatter+dateFromRFC822.h
//  TelAPIFax
//
//  Created by Matt Williamson on 3/4/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (RFC822)

+ (NSDateFormatter *)rfc822Formatter;

@end

@interface NSDate (RFC822)

+ (NSDate *)dateFromRFC822:(NSString *)date;

@end