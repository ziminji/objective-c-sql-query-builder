/*
 * Copyright 2011-2013 Ziminji
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
	if ((self = [super init])) {
		_table = nil;
		_where = [[NSMutableArray alloc] init];
		_orderBy = [[NSMutableArray alloc] init];
		_limit = 0;
		_offset = 0;
	}
	return self;
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

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 {
	[self where: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
	[_where addObject: [NSArray arrayWithObjects: [ZIMSqlExpression prepareConnector: connector], [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlExpression prepareIdentifier: column1], [operator uppercaseString], [ZIMSqlExpression prepareIdentifier: column2]], nil]];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value {
	[self where: column operator: operator value: value connector: ZIMSqlConnectorAnd];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
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
	[self orderBy: column descending: NO nulls: nil];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending {
	[self orderBy: column descending: descending nulls: nil];
}

- (void) orderBy: (NSString *)column nulls: (NSString *)weight {
	[self orderBy: column descending: NO nulls: weight];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending nulls: (NSString *)weight {
	NSString *field = [ZIMSqlExpression prepareIdentifier: column];
	NSString *order = [ZIMSqlExpression prepareSortOrder: descending];
	weight = [ZIMSqlExpression prepareSortWeight: weight];
	if ([weight isEqualToString: @"FIRST"]) {
		[_orderBy addObject: [NSString stringWithFormat: @"CASE WHEN %@ IS NULL THEN 0 ELSE 1 END, %@ %@", field, field, order]];
	}
	else if ([weight isEqualToString: @"LAST"]) {
		[_orderBy addObject: [NSString stringWithFormat: @"CASE WHEN %@ IS NULL THEN 1 ELSE 0 END, %@ %@", field, field, order]];
	}
	else {
		[_orderBy addObject: [NSString stringWithFormat: @"%@ %@", field, order]];
	}
}

- (void) limit: (NSUInteger)limit {
	_limit = limit;
}

- (void) limit: (NSUInteger)limit offset: (NSUInteger)offset {
	_limit = limit;
	_offset = offset;
}

- (void) offset: (NSUInteger)offset {
	_offset = offset;
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	
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
		[sql appendFormat: @" LIMIT %u", _limit];
	}
	
	if (_offset > 0) {
		[sql appendFormat: @" OFFSET %u", _offset];
	}

	[sql appendString: @";"];

	return sql;
}

@end
