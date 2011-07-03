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
	_table = [ZIMSqlExpression prepareIdentifier: table];
}

- (void) whereBlock: (NSString *)brace {
	[self whereBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) whereBlock: (NSString *)brace connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [ZIMSqlExpression prepareEnclosure: brace], nil]];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[self where: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlExpression prepareIdentifier: column1], [operator uppercaseString], [ZIMSqlExpression prepareIdentifier: column2]], nil]];
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
		[_where addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@ AND %@", [ZIMSqlExpression prepareIdentifier: column], operator, [ZIMSqlExpression prepareValue: [(NSArray *)value objectAtIndex: 0]], [ZIMSqlExpression prepareValue: [(NSArray *)value objectAtIndex: 1]]], nil]];
	}
	else {
		if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
		}
		else if ([value isKindOfClass: [NSNull class]]) {
			if ([operator isEqualToString: ZIMSqlOperatorEqualTo]) {
				operator = ZIMSqlOperatorIs;
			}
			else if ([operator isEqualToString: ZIMSqlOperatorNotEqualTo] || [operator isEqualToString: @"!="]) {
				operator = ZIMSqlOperatorIsNot;
			}
		}
		[_where addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlExpression prepareIdentifier: column], operator, [ZIMSqlExpression prepareValue: value]], nil]];
	}
}

- (void) orderBy: (NSString *)column {
	[self orderBy: column descending: NO];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending {
	[_orderBy addObject: [NSString stringWithFormat: @"%@ %@", [ZIMSqlExpression prepareIdentifier: column], [ZIMSqlExpression prepareSortOrder: descending]]];
}

- (void) limit: (NSInteger)limit {
	_limit = [ZIMSqlExpression prepareNaturalNumber: limit];
}

- (void) offset: (NSInteger)offset {
	_offset = [ZIMSqlExpression prepareNaturalNumber: offset];
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendFormat: @"DELETE FROM %@", _table];

	if ([_where count] > 0) {
		BOOL doAppendConnector = NO;
		[sql appendString: @" WHERE "];
		for (NSArray *where in _where) {
			NSString *whereClause = [where objectAtIndex: 1];
			if (doAppendConnector && ![whereClause isEqualToString: ZIMSqlEnclosureClosingBrace]) {
				[sql appendFormat: @" %@ ", [where objectAtIndex: 0]];
			}
			[sql appendString: whereClause];
			doAppendConnector = (![whereClause isEqualToString: ZIMSqlEnclosureOpeningBrace]);
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
