/*
 * Copyright 2011-2012 Ziminji
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
		[_sql from: [model table]];
	}
	return self;
}

- (void) dealloc {
	[_sql release];
	[super dealloc];
}

- (void) join: (NSString *)table {
	[_sql join: table];
}

- (void) join: (NSString *)table alias: (NSString *)alias {
	[_sql join: table alias: alias];
}

- (void) join: (NSString *)table type: (NSString *)type {
	[_sql join: table type: type];
}

- (void) join: (NSString *)table alias: (NSString *)alias type: (NSString *)type {
	[_sql join: table alias: alias type: type];
}

- (void) joinOn: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[_sql joinOn: column1 operator: operator column: column2];
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

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[_sql where: column1 operator: operator column: column2];
}

- (void) where: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	[_sql where: column1 operator: operator column: column2 connector: connector];
}

- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value {
	[_sql where: column operator: operator value: value];
}

- (void) where: (NSString *)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
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

- (void) groupByHaving: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 {
	[_sql groupByHaving: column1 operator: operator column: column2];
}

- (void) groupByHaving: (NSString *)column1 operator: (NSString *)operator column: (NSString *)column2 connector: (NSString *)connector {
	[_sql groupByHaving: column1 operator: operator column: column2 connector: connector];
}

- (void) groupByHaving: (NSString *)column operator: (NSString *)operator value: (id)value {
	[_sql groupByHaving: column operator: operator value: value];
}

- (void) groupByHaving: (NSString *)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector {
	[_sql groupByHaving: column operator: operator value: value connector: connector];
}

- (void) orderBy: (NSString *)column {
	[_sql orderBy: column];
}

- (void) orderBy: (NSString *)column descending: (BOOL)descending {
	[_sql orderBy: column descending: descending];
}

- (void) limit: (NSInteger)limit {
	[_sql limit: limit];
}

- (void) offset: (NSInteger)offset {
	[_sql offset: offset];
}

- (NSString *) statement {
	return [_sql statement];
}

- (NSArray *) query {
	ZIMDbConnection *connection = [[ZIMDbConnection alloc] initWithDataSource: [_model dataSource] withMultithreadingSupport: NO];
	NSArray *records = [connection query: [_sql statement] asObject: _model];
	[connection release];
	return records;
}

@end
