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

#import <sqlite3.h> // Requires libsqlite3.dylib
#import "NSString+ZIMExtString.h"
#import "ZIMSqlExpression.h"
#import "ZIMSqlSelectStatement.h"

NSString *ZIMSqlDefaultValue(id value) {
	if ((value == nil) || [value isKindOfClass: [NSNull class]]) {
		return @"DEFAULT NULL";
	}
	else if ([value isKindOfClass: [NSNumber class]]) {
		return [NSString stringWithFormat: @"DEFAULT %@", value];
	}
	else if ([value isKindOfClass: [NSString class]]) {
		char *escapedValue = sqlite3_mprintf("DEFAULT '%q'", [(NSString *)value UTF8String]);
        NSString *string = [NSString stringWithUTF8String: (const char *)escapedValue];
        sqlite3_free(escapedValue);
		return string;
	}
	else if ([value isKindOfClass: [NSData class]]) {
		NSData *data = (NSData *)value;
		int length = [data length];
		NSMutableString *buffer = [[[NSMutableString alloc] init] autorelease];
		[buffer appendString: @"DEFAULT '"];
		const unsigned char *dataBuffer = [data bytes];
		for (int i = 0; i < length; i++) {
			[buffer appendFormat: @"%02x", (unsigned long)dataBuffer[i]];
		}
		[buffer appendString: @"'"];
		return buffer;
	}
	else if ([value isKindOfClass: [NSDate class]]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		NSString *date = [NSString stringWithFormat: @"DEFAULT '%@'", [formatter stringFromDate: (NSDate *)value]];
		[formatter release];
		return date;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Unable to set default value. '%@'", value] userInfo: nil];
	}
}

NSString *ZIMSqlDataTypeChar(NSInteger x) {
	return [NSString stringWithFormat: @"CHAR(%d)", x];
}

NSString *ZIMSqlDataTypeCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"CHARACTER(%d)", x];
}

NSString *ZIMSqlDataTypeDecimal(NSInteger x, NSInteger y) {
	return [NSString stringWithFormat: @"DECIMAL(%d, %d)", x, y];
}

NSString *ZIMSqlDataTypeNativeCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"NATIVE CHARACTER(%d)", x];
}

NSString *ZIMSqlDataTypeNChar(NSInteger x) {
	return [NSString stringWithFormat: @"NCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeNVarChar(NSInteger x) {
	return [NSString stringWithFormat: @"NVARCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeVarChar(NSInteger x) {
	return [NSString stringWithFormat: @"VARCHAR(%d)", x];
}

NSString *ZIMSqlDataTypeVaryingCharacter(NSInteger x) {
	return [NSString stringWithFormat: @"VARYING CHARACTER(%d)", x];
}

@implementation ZIMSqlExpression

+ (NSString *) prepareAlias: (NSString *)token {
	NSCharacterSet *removables = [NSCharacterSet characterSetWithCharactersInString: @";\"'`[]\n\r\t"];
	token = [[token componentsSeparatedByCharactersInSet: removables] componentsJoinedByString: @""];
	token = [NSString stringWithFormat: @"[%@]", token];
	return token;
}

+ (NSString *) prepareConnector: (NSString *)token {
	token = [token uppercaseString];
	if (!([token isEqualToString: ZIMSqlConnectorAnd] || [token isEqualToString: ZIMSqlConnectorOr])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid connector token provided." userInfo: nil];
	}
	return token;
}

+ (NSString *) prepareEnclosure: (NSString *)token {
	if (!([token isEqualToString: ZIMSqlEnclosureOpeningBrace] || [token isEqualToString: ZIMSqlEnclosureClosingBrace])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid enclosure token provided." userInfo: nil];
	}
	return token;
}

+ (NSString *) prepareIdentifier: (NSString *)token {
	if ([[[NSString firstTokenInString: token scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString: @" ;\"'`[]\n\r\t"]] uppercaseString] isEqualToString: @"SELECT"]) {
		while ([token hasSuffix: @";"]) {
			token = [token substringWithRange: NSMakeRange(0, [token length] - 1)];
		}
		token = [NSString stringWithFormat: @"(%@)", token];
		return token;
	}
	/*
	NSMutableString *result = [NSMutableString stringWithCapacity: [token length]];
	NSScanner *scanner = [NSScanner scannerWithString: token];
	NSCharacterSet *stopSet = [NSCharacterSet characterSetWithCharactersInString: @";\"'`[]\n\r"];
	while (![scanner isAtEnd]) {
	 	NSString *buffer;
		if ([scanner scanUpToCharactersFromSet: stopSet intoString: &buffer]) {
	  		[result appendString: buffer];
	 	}
		else {
	  		[scanner setScanLocation: ([scanner scanLocation] + 1)];
	 	}
	}
	NSArray *segments = [result componentsSeparatedByString: @"."];
	token = [NSString stringWithFormat: @"[%@]", [segments componentsJoinedByString: @"].["]];
	*/
	return token;
}

+ (NSString *) prepareJoinType: (NSString *)token {
	const NSSet *joinTypes = [NSSet setWithObjects: ZIMSqlJoinTypeCross, ZIMSqlJoinTypeInner, ZIMSqlJoinTypeLeft, ZIMSqlJoinTypeLeftOuter, ZIMSqlJoinTypeNatural, ZIMSqlJoinTypeNaturalCross, ZIMSqlJoinTypeNaturalInner, ZIMSqlJoinTypeNaturalLeft, ZIMSqlJoinTypeNaturalLeftOuter, nil];
	if ((token == nil) || [token isEqualToString: ZIMSqlJoinTypeNone]) {
		token = ZIMSqlJoinTypeInner;
	}
	else if ([token isEqualToString: @","]) {
		token = ZIMSqlJoinTypeCross;
	}
	else {
		token = [token uppercaseString];
	}
	if (![joinTypes containsObject: token])	{
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid join type token provided." userInfo: nil];
	}
	return token;
}

+ (NSInteger) prepareNaturalNumber: (NSInteger)number {
	return abs(number);
}

+ (NSString *) prepareSortOrder: (BOOL)descending {
	return (descending) ? @"DESC" : @"ASC";
}

+ (NSString *) prepareValue: (id)value {
	if ((value == nil) || [value isKindOfClass: [NSNull class]]) {
		return @"NULL";
	}
	else if ([value isKindOfClass: [ZIMSqlSelectStatement class]]) {
		NSString *statement = [(ZIMSqlSelectStatement *)value statement];
		statement = [statement substringWithRange: NSMakeRange(0, [statement length] - 1)];
		statement = [NSString stringWithFormat: @"(%@)", statement];
		return statement;
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
        char *escapedValue = sqlite3_mprintf("'%q'", [(NSString *)value UTF8String]);
        NSString *string = [NSString stringWithUTF8String: (const char *)escapedValue];
        sqlite3_free(escapedValue);
		return string;
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
