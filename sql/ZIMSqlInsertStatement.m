/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZIMSqlInsertStatement.h"
#import "ZIMSqlSelectStatement.h"

/*!
 @category		ZIMSqlInsertStatement (Private)
 @discussion	This category defines the prototpes for this class's private methods.
 @updated		2011-03-13
 */
@interface ZIMSqlInsertStatement (Private)
/*!
 @method			prepareValue:
 @discussion		This method will prepare a value for an SQL statement.
 @param value		The value to be prepared.
 @return			The prepared value.
 @updated			2011-03-24
 */
- (NSString *) prepareValue: (id)value;
@end

@implementation ZIMSqlInsertStatement

- (id) init {
	if (self = [super init]) {
		_table = nil;
		_column = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[_column release];
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}

- (void) column: (NSString *)column value: (id)value {
	[_column setObject: [self prepareValue: value] forKey: column];
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendFormat: @"INSERT INTO %@ ", _table];

	if ([_column count] > 0) {
		[sql appendFormat: @"(%@) VALUES (%@)", [[_column allKeys] componentsJoinedByString: @", "], [[_column allValues] componentsJoinedByString: @", "]];
	}

	[sql appendString: @";"];

	return sql;
}

- (NSString *) prepareValue: (id)value {
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
	else if ([value isKindOfClass: [NSString class]]) {
		return [NSString stringWithFormat: @"'%@'", [[(NSString *)value stringByReplacingOccurrencesOfString: @"\\" withString: @"\\\\"] stringByReplacingOccurrencesOfString: @"\'" withString: @"\\\'"]];
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
	return [NSString stringWithFormat: @"%@", value];
}

@end
