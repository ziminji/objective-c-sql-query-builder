/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZIMSqlHelper.h"
#import "ZIMSqlStatement.h"
#import "ZIMSqlSelectStatement.h"

@implementation ZIMSqlHelper

+ (NSString *) prepareConnector: (NSString *)connector {
	if (!([connector isEqualToString: ZIMSqlConnectorAnd] || [connector isEqualToString: ZIMSqlConnectorOr])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid connector token provided." userInfo: nil];
	}
	return connector;
}

+ (NSString *) prepareEncloser: (NSString *)encloser {
	if (!([encloser isEqualToString: ZIMSqlEncloserOpeningBrace] || [encloser isEqualToString: ZIMSqlEncloserClosingBrace])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid encloser token provided." userInfo: nil];
	}
	return encloser;
}

+ (NSString *) prepareField: (NSString *)field {
	if (([field length] >= 6)  && [[[field substringWithRange: NSMakeRange(0, 6)] uppercaseString] isEqualToString: @"SELECT"]) {
		return [NSString stringWithFormat: @"(%@)", field];
	}
	return field;
}

+ (NSString *) prepareValue: (id)value {
	if ([value isKindOfClass: [ZIMSqlSelectStatement class]]) {
		return [NSString stringWithFormat: @"(%@)", [(ZIMSqlSelectStatement *)value statement]];
	}
	else if ([value isKindOfClass: [NSArray class]]) {
		NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
		[str appendString: @"("];
		for (int i = 0; i < [value count]; i++) {
			if (i > 0) {
				[str appendString: @", "];
			}
			[str appendString: [self prepareValue: [value objectAtIndex: i]]];
		}
		[str appendString: @")"];
		return str;
	}
	else if ([value isKindOfClass: [NSNumber class]]) {
		return [NSString stringWithFormat: @"%@", value];
	}
	else if ([value isKindOfClass: [NSString class]]) {
		return [NSString stringWithFormat: @"'%@'", [[(NSString *)value stringByReplacingOccurrencesOfString: @"\\" withString: @"\\\\"] stringByReplacingOccurrencesOfString: @"\'" withString: @"\\\'"]];
	}
	else if ([value isKindOfClass: [NSData class]]) {
		NSData *data = (NSData *)value;
		int length = [data length];
		NSMutableString *buffer = [[[NSMutableString alloc] init] autorelease];
		[buffer appendString: @"'"];
		const unsigned char *dataBuffer = [data bytes];
		for (int i = 0; i < length; i++) {
			[buffer appendFormat: @"%02x", (unsigned long)dataBuffer[i]];
		}
		[buffer appendString: @"'"];
		return buffer;
	}
	else if ([value isKindOfClass: [NSNull class]]) {
		return @"null";
	}
	else if ([value isKindOfClass: [NSDate class]]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		NSString *date = [NSString stringWithFormat: @"'%@'", [formatter stringFromDate: (NSDate *)value]];
		[formatter release];
		return date;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Unable to prepare value. '%@'", value] userInfo: nil];
	}
}

@end
