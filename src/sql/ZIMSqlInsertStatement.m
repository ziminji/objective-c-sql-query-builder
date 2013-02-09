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

#import "ZIMSqlInsertStatement.h"

@implementation ZIMSqlInsertStatement

- (id) init {
	if ((self = [super init])) {
		_table = nil;
		_column = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) into: (NSString *)table {
	_table = [ZIMSqlExpression prepareIdentifier: table];
}

- (void) column: (NSString *)column value: (id)value {
	[_column setObject: [ZIMSqlExpression prepareValue: value] forKey: [ZIMSqlExpression prepareIdentifier: column]];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	
	[sql appendFormat: @"INSERT INTO %@ ", _table];

	if ([_column count] > 0) {
		[sql appendFormat: @"(%@) VALUES (%@)", [[_column allKeys] componentsJoinedByString: @", "], [[_column allValues] componentsJoinedByString: @", "]];
	}

	[sql appendString: @";"];

	return sql;
}

@end
