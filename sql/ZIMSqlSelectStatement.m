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
#import "ZIMSqlSelectStatement.h"

@implementation ZIMSqlSelectStatement

- (id) init {
	if (self = [super init]) {
		_distinct = NO;
		_column = [[NSMutableArray alloc] init];
		_table = [[NSMutableArray alloc] init];
		_join = [[NSMutableArray alloc] init];
		_where = [[NSMutableArray alloc] init];
		_groupBy = [[NSMutableArray alloc] init];
		_having = [[NSMutableArray alloc] init];
		_orderBy = [[NSMutableArray alloc] init];
		_limit = 0;
		_offset = 0;
		_compound = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc {
	[_column release];
	[_table release];
	[_join release];
	[_where release];
	[_groupBy release];
	[_having release];
	[_orderBy release];
	[_compound release];
	[super dealloc];
}

- (void) distinct: (BOOL)distinct {
	_distinct = distinct;
}

- (void) column: (NSString *)column {
	[_column addObject: [ZIMSqlHelper prepareField: column]];
}

- (void) column: (NSString *)column alias: (NSString *)alias {
	[_column addObject: [NSString stringWithFormat: @"%@ AS %@", [ZIMSqlHelper prepareField: column], alias]];
}

- (void) from: (NSString *)table {
	[_table addObject: [ZIMSqlHelper prepareField: table]];
}

- (void) from: (NSString *)table alias: (NSString *)alias {
	[_table addObject: [NSString stringWithFormat: @"%@ %@", [ZIMSqlHelper prepareField: table], alias]];
}

- (void) join: (NSString *)table {
	[self join: table type: nil];
}

- (void) join: (NSString *)table alias: (NSString *)alias {
	[self join: table alias: alias type: nil];
}

- (void) join: (NSString *)table type: (NSString *)type {
	[_join addObject: [NSArray arrayWithObjects: (((type == nil) || [type isEqualToString: ZIMSqlJoinTypeNone]) ? [NSString stringWithFormat: @" JOIN %@", [ZIMSqlHelper prepareField: table]] : [NSString stringWithFormat: @" %@ JOIN %@", [type uppercaseString], [ZIMSqlHelper prepareField: table]]), [[[NSMutableArray alloc] init] autorelease], [[[NSMutableArray alloc] init] autorelease], nil]];
}

- (void) join: (NSString *)table alias: (NSString *)alias type: (NSString *)type {
	[self join: [NSString stringWithFormat: @"%@ %@", [ZIMSqlHelper prepareField: table], alias] type: type];
}

- (void) joinOn: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	NSUInteger length = [_join count];
	if (length > 0) {
		NSUInteger index = length - 1;
		NSMutableArray *joinCondition = (NSMutableArray *)[[_join objectAtIndex: index] objectAtIndex: 2];
		if ([joinCondition count] > 0) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"May not declare two different types of constraints on a JOIN statement." userInfo: nil];
		}
		joinCondition = (NSMutableArray *)[[_join objectAtIndex: index] objectAtIndex: 1];
		[joinCondition addObject: [NSString stringWithFormat: @"%@ %@ %@", [ZIMSqlHelper prepareField: column1], [operator uppercaseString], [ZIMSqlHelper prepareField: column2]]];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Must declare a JOIN clause before declaring a constraint." userInfo: nil];
	}
}

- (void) joinUsing: (NSString *)column {
	NSUInteger length = [_join count];
	if (length > 0) {
		NSUInteger index = length - 1;
		NSMutableArray *joinCondition = (NSMutableArray *)[[_join objectAtIndex: index] objectAtIndex: 1];
		if ([joinCondition count] > 0) {
			@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"May not declare two different types of constraints on a JOIN statement." userInfo: nil];
		}
		joinCondition = (NSMutableArray *)[[_join objectAtIndex: index] objectAtIndex: 2];
		[joinCondition addObject: [ZIMSqlHelper prepareField: column]];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Must declare a JOIN clause before declaring a constraint." userInfo: nil];
	}
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

- (void) groupBy: (NSString *)column {
	[_groupBy addObject: [ZIMSqlHelper prepareField: column]];
}

- (void) groupByHavingBlock: (NSString *)brace {
	[self groupByHavingBlock: brace connector: ZIMSqlConnectorAnd];
}

- (void) groupByHavingBlock: (NSString *)brace connector: (NSString *)connector {
	if ([_groupBy count] > 0) {
		[_having addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [ZIMSqlHelper prepareEncloser: brace], nil]];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Must declare a GROUP BY clause before declaring a constraint." userInfo: nil];
	}
}

- (void) groupByHaving: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[self groupByHaving: column1 operator: operator column: column2 connector: ZIMSqlConnectorAnd];
}

- (void) groupByHaving: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	if ([_groupBy count] > 0) {
		[_having addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"HAVING %@ %@ %@", [ZIMSqlHelper prepareField: column1], [operator uppercaseString], [ZIMSqlHelper prepareField: column2]], nil]];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Must declare a GROUP BY clause before declaring a constraint." userInfo: nil];
	}
}

- (void) groupByHaving: (NSString *)column operator: (NSString *)operator value: (id)value {
	[self groupByHaving: column operator: operator value: value connector: ZIMSqlConnectorAnd];
}

- (void) groupByHaving: (NSString *)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	if ([_groupBy count] > 0) {
		operator = [operator uppercaseString];
		if ([operator isEqualToString: ZIMSqlOperatorBetween] || [operator isEqualToString: ZIMSqlOperatorNotBetween]) {
			if (![value isKindOfClass: [NSArray class]]) {
				@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
			}
			[_having addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"HAVING %@ %@ %@ AND %@", [ZIMSqlHelper prepareField: column], operator, [ZIMSqlHelper prepareValue: [(NSArray *)value objectAtIndex: 0]], [ZIMSqlHelper prepareValue: [(NSArray *)value objectAtIndex: 1]]], nil]];
		}
		else {
			if (([operator isEqualToString: ZIMSqlOperatorIn] || [operator isEqualToString: ZIMSqlOperatorNotIn]) && ![value isKindOfClass: [NSArray class]]) {
				@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Operator requires the value to be declared as an array." userInfo: nil];
			}
			[_having addObject: [NSArray arrayWithObjects: [ZIMSqlHelper prepareConnector: connector], [NSString stringWithFormat: @"HAVING %@ %@ %@", [ZIMSqlHelper prepareField: column], operator, [ZIMSqlHelper prepareValue: value]], nil]];
		}
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Must declare a GROUP BY clause before declaring a constraint." userInfo: nil];
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

- (void) compoundWith: (NSString *)statement operator: (NSString *)operator {
	if (!(([statement length] >= 6)  && [[[statement substringWithRange: NSMakeRange(0, 6)] uppercaseString] isEqualToString: @"SELECT"])) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"May only compound a select statement." userInfo: nil];
	}
	operator = [operator uppercaseString];
	if (![[NSSet setWithObjects: ZIMSqlOperatorExcept, ZIMSqlOperatorIntersect, ZIMSqlOperatorUnion, ZIMSqlOperatorUnionALL, nil] isSubsetOfSet: [NSSet setWithObject: operator]]) {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid operator." userInfo: nil];
	}
	[_compound addObject: [NSString stringWithFormat: @"%@ %@", operator, statement]];
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendString: @"SELECT "];
	
	if (_distinct) {
		[sql appendString: @"DISTINCT "];
	}
	
	if ([_column count] > 0) {
		[sql appendString: [_column componentsJoinedByString: @", "]];
	}
	else {
		[sql appendString: @"*"];
	}
	
	if ([_table count] > 0) {
		[sql appendString: @" FROM "];
		[sql appendString: [_table componentsJoinedByString: @", "]];
	}

	for (NSArray *join in _join) {
		[sql appendString: (NSString *)[join objectAtIndex: 0]];
		NSArray *joinCondition = (NSArray *)[join objectAtIndex: 2];
		if ([joinCondition count] > 0) {
			[sql appendString: @" USING "];
			[sql appendString: [joinCondition componentsJoinedByString: @", "]];
		}
		else {
			joinCondition = (NSArray *)[join objectAtIndex: 1];
			[sql appendFormat: @" ON (%@)", [joinCondition componentsJoinedByString: @" AND "]];
		}
	}

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

	if ([_groupBy count] > 0) {
		[sql appendFormat: @" GROUP BY %@", [_groupBy componentsJoinedByString: @", "]];
	}
	
	if ([_having count] > 0) {
		BOOL doAppendConnector = NO;
		[sql appendString: @" "];
		for (NSArray *having in _having) {
			NSString *havingClause = [having objectAtIndex: 1];
			if (doAppendConnector && ![havingClause isEqualToString: ZIMSqlEncloserClosingBrace]) {
				[sql appendFormat: @" %@ ", [having objectAtIndex: 0]];
			}
			[sql appendString: havingClause];
			doAppendConnector = (![havingClause isEqualToString: ZIMSqlEncloserOpeningBrace]);
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

	for (NSString *compound in _compound) {
		[sql appendFormat: @" %@", compound];
	}

	[sql appendString: @";"];

	return sql;
}

@end
