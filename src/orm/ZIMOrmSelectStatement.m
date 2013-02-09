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

#import "ZIMDbConnection.h"
#import "ZIMOrmModel.h"
#import "ZIMOrmSelectStatement.h"

@implementation ZIMOrmSelectStatement

- (id) initWithModel: (Class)model {
	if ((self = [super init])) {
		if (![ZIMOrmModel isModel: model]) {
			@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Invalid class type specified." userInfo: nil];
		}
		_model = model;
		_sql = [[ZIMSqlSelectStatement alloc] init];
		NSString *table = [model table];
		[_sql all: [NSString stringWithFormat: @"%@.*", table]];
		[_sql from: table];
	}
	return self;
}

- (void) join: (id)table {
	[_sql join: table];
}

- (void) join: (id)table alias: (NSString *)alias {
	[_sql join: table alias: alias];
}

- (void) join: (id)table type: (NSString *)type {
	[_sql join: table type: type];
}

- (void) join: (id)table alias: (NSString *)alias type: (NSString *)type {
	[_sql join: table alias: alias type: type];
}

- (void) joinOn: (id)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[_sql joinOn: column1 operator: operator column: column2];
}

- (void) joinOn: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
	[_sql joinOn: column1 operator: operator column: column2 connector: connector];
}

- (void) joinOn: (id)column operator: (NSString *)operator value: (id)value {
	[_sql joinOn: column operator: operator value: value];
}

- (void) joinOn: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	[_sql joinOn: column operator: operator value: value connector: connector];
}

- (void) joinUsing: (NSString *)column {
	[_sql joinUsing: column];
}

- (void) whereBlock: (NSString *)brace {
	[_sql whereBlock: brace];
}

- (void) whereBlock: (NSString *)brace connector: (NSString *)connector {
	[_sql whereBlock: brace connector: connector];
}

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 {
	[_sql where: column1 operator: operator column: column2];
}

- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
	[_sql where: column1 operator: operator column: column2 connector: connector];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value {
	[_sql where: column operator: operator value: value];
}

- (void) where: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	[_sql where: column operator: operator value: value connector: connector];
}

- (void) groupBy: (NSString *)column {
	[_sql groupBy: column];
}

- (void) groupByHavingBlock: (NSString *)brace {
	[_sql groupByHavingBlock: brace];
}

- (void) groupByHavingBlock: (NSString *)brace connector: (NSString *)connector {
	[_sql groupByHavingBlock: brace connector: connector];
}

- (void) groupByHaving: (id)column1 operator: (NSString *)operator column: (id)column2 {
	[_sql groupByHaving: column1 operator: operator column: column2];
}

- (void) groupByHaving: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector {
	[_sql groupByHaving: column1 operator: operator column: column2 connector: connector];
}

- (void) groupByHaving: (id)column operator: (NSString *)operator value: (id)value {
	[_sql groupByHaving: column operator: operator value: value];
}

- (void) groupByHaving: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	[_sql groupByHaving: column operator: operator value: value connector: connector];
}

- (void) orderBy: (NSString *)column {
	[_sql orderBy: column descending: NO nulls: nil];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending {
	[_sql orderBy: column descending: descending nulls: nil];
}

- (void) orderBy: (NSString *)column nulls: (NSString *)weight {
	[_sql orderBy: column descending: NO nulls: weight];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending nulls: (NSString *)weight {
	[_sql orderBy: column descending: descending nulls: weight];
}

- (void) limit: (NSUInteger)limit {
	[_sql limit: limit];
}

- (void) limit: (NSUInteger)limit offset: (NSUInteger)offset {
	[_sql limit: limit offset: offset];
}

- (void) offset: (NSUInteger)offset {
	[_sql offset: offset];
}

- (NSString *) statement {
	return [_sql statement];
}

- (NSArray *) query {
	ZIMDbConnection *connection = [[ZIMDbConnection alloc] initWithDataSource: [_model dataSource] withMultithreadingSupport: NO];
	NSArray *records = [connection query: [_sql statement] asObject: _model];
	[connection close];
	return records;
}

@end
