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
		return [NSString stringWithFormat: @"DEFAULT '%@'", [[(NSString *)value stringByReplacingOccurrencesOfString: @"\\" withString: @"\\\\"] stringByReplacingOccurrencesOfString: @"\'" withString: @"\\\'"]];
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

+ (NSString *) prepareConnector: (NSString *)connector {
	connector = [connector uppercaseString];
	if (!([connector isEqualToString: ZIMSqlConnectorAnd] || [connector isEqualToString: ZIMSqlConnectorOr])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid connector token provided." userInfo: nil];
	}
	return connector;
}

+ (NSString *) prepareEnclosure: (NSString *)enclosure {
	if (!([enclosure isEqualToString: ZIMSqlEnclosureOpeningBrace] || [enclosure isEqualToString: ZIMSqlEnclosureClosingBrace])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid enclosure token provided." userInfo: nil];
	}
	return enclosure;
}

+ (NSString *) prepareIdentifier: (NSString *)identifier {
	if (([identifier length] >= 6)  && [[[identifier substringWithRange: NSMakeRange(0, 6)] uppercaseString] isEqualToString: @"SELECT"]) {
		identifier = [(ZIMSqlSelectStatement *)identifier statement];
		identifier = [identifier substringWithRange: NSMakeRange(0, [identifier length] - 1)];
		identifier = [NSString stringWithFormat: @"(%@)", identifier];
		return identifier;
	}
	return identifier;
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
