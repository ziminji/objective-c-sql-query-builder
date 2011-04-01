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
#import "ZIMSqlDeleteStatement.h"

@implementation ZIMSqlDeleteStatement

- (id) init {
	if (self = [super init]) {
		_table = nil;
		_where = [[NSMutableArray alloc] init];
		_orderBy = [[NSMutableArray alloc] init];
		_limit = 0;
		_offset = 0;
	}
	return self;
}

- (void) dealloc {
	[_where release];
	[_orderBy release];
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}

- (void) whereBlock: (NSString *)brace {
	[self whereBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) whereBlock: (NSString *)brace connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [ZIMSqlHelper prepareEncloser: brace], nil]];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[self where: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"WHERE %@ %@ %@", [ZIMSqlHelper prepareField: column1], [operator uppercaseString], [ZIMSqlHelper prepareField: column2]], nil]];
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
		[_where addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"WHERE %@ %@ %@ AND %@", [ZIMSqlHelper prepareField: column], operator, [ZIMSqlHelper prepareValue: [(NSArray *)value objectAtIndex: 0]], [ZIMSqlHelper prepareValue: [(NSArray *)value objectAtIndex: 1]]], nil]];
	}
	else {
		if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}
		[_where addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"WHERE %@ %@ %@", [ZIMSqlHelper prepareField: column], operator, [ZIMSqlHelper prepareValue: value]], nil]];
	}
}

- (void) orderBy: (NSString *)column {
	[self orderBy: column ascending: YES];
}

- (void) orderBy: (NSString *)column ascending: (BOOL)ascending {
	[_orderBy addObject: [NSString stringWithFormat: @"%@ %@", [ZIMSqlHelper prepareField: column], ((ascending) ? @"ASC" : @"DESC")]];
}

- (void) limit: (NSInteger)limit {
	_limit = abs(limit);
}

- (void) offset: (NSInteger)offset {
	_offset = abs(offset);
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendFormat: @"DELETE FROM %@", _table];

	if ([_where count] > 0) {
		BOOL doAppendConnector = NO;
		[sql appendString: @" "];
		for (NSArray *where in _where) {
			NSString *whereClause = [where objectAtIndex: 1];
			if (doAppendConnector && ![whereClause isEqualToString: ZIMSqlEncloserClosingBrace]) {
				[sql appendFormat: @" %@ ", [where objectAtIndex: 0]];
			}
			[sql appendString: whereClause];
			doAppendConnector = (![whereClause isEqualToString: ZIMSqlEncloserOpeningBrace]);
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

@end
