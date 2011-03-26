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

#import "ZIMSqlUpdateStatement.h"
#import "ZIMSqlSelectStatement.h"

/*!
 @category		ZIMSqlUpdateStatement (Private)
 @discussion	This category defines the prototpes for this class's private methods.
 @updated		2011-03-13
 */
@interface ZIMSqlUpdateStatement (Private)
/*!
 @method			prepareValue:
 @discussion		This method will prepare a value for an SQL statement.
 @param value		The value to be prepared.
 @return			The prepared value.
 @updated			2011-03-26
 */
- (NSString *) prepareValue: (id)value;
@end

@implementation ZIMSqlUpdateStatement

- (id) init {
	if (self = [super init]) {
		_table = nil;
		_column = [[NSMutableArray alloc] init];
		_where = [[NSMutableArray alloc] init];
		_orderBy = [[NSMutableArray alloc] init];
		_limit = 0;
		_offset = 0;
	}
	return self;
}

- (void) dealloc {
	[_column release];
	[_where release];
	[_orderBy release];
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}

- (void) column: (NSString *)column value: (id)value {
	[_column addObject: [NSString stringWithFormat: @"%@ = %@", column, [self prepareValue: value]]];
}

- (void) whereBlock: (NSString *)brace {
	[self whereBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) whereBlock: (NSString *)brace connector: (NSString *)connector {
	if (!([brace isEqualToString: ZIMSqlBlockOpeningBrace] || [brace isEqualToString: ZIMSqlBlockClosingBrace])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid brace token." userInfo: nil];
	}
	[_where addObject: [NSArray arrayWithObjects: connector, brace, nil]];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[self where: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: connector, [NSString stringWithFormat: @"WHERE %@ %@ %@", column1, [operator uppercaseString], column2], nil]];
}

- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value {
	[self where: column operator: operator value: value connector: ZIMSqlConnectorAnd];
}

- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	operator = [operator uppercaseString];
	if ([operator isEqualToString: ZIMSqlOperatorBetween] || [operator isEqualToString: ZIMSqlOperatorNotBetween]) {
		if (![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}
		[_where addObject: [NSArray arrayWithObjects: connector, [NSString stringWithFormat: @"WHERE %@ %@ %@ AND %@", column, operator, [self prepareValue: [(NSArray *)value objectAtIndex: 0]], [self prepareValue: [(NSArray *)value objectAtIndex: 1]]], nil]];
	}
	else {
		if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}		
		[_where addObject: [NSArray arrayWithObjects: connector, [NSString stringWithFormat: @"WHERE %@ %@ %@", column, operator, [self prepareValue: value]], nil]];
	}
}

- (void) orderBy: (NSString *)column {
	[self orderBy: column ascending: YES];
}

- (void) orderBy: (NSString *)column ascending: (BOOL)ascending {
	[_orderBy addObject: [NSString stringWithFormat: @"%@ %@", column, ((ascending) ? @"ASC" : @"DESC")]];
}

- (void) limit: (NSInteger)limit {
	_limit = abs(limit);
}

- (void) offset: (NSInteger)offset {
	_offset = abs(offset);
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];

	[sql appendFormat: @"UPDATE %@ SET ", _table];
	
	if ([_column count] > 0) {
		[sql appendString: [_column componentsJoinedByString: @", "]];
	}

	if ([_where count] > 0) {
		BOOL doAppendConnector = NO;
		[sql appendString: @" "];
		for (NSArray *where in _where) {
			NSString *whereClause = [where objectAtIndex: 1];
			if (doAppendConnector && ![whereClause isEqualToString: ZIMSqlBlockClosingBrace]) {
				[sql appendFormat: @" %@ ", [where objectAtIndex: 0]];
			}
			[sql appendString: whereClause];
			doAppendConnector = (![whereClause isEqualToString: ZIMSqlBlockOpeningBrace]);
		}
	}
	
	
	if ([_orderBy count] > 0) {
		[sql appendFormat: @" ORDER BY %@", [_orderBy componentsJoinedByString: @", "]];
	}
	
	if (_limit > 0) {
		[sql appendFormat: @" LIMIT %d", _limit];
	}
	
	if (_offset > 0) {
		[sql appendFormat: @" OFFSET %d", _offset];
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
