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
#import "ZIMSqlInsertStatement.h"

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
	[_column setObject: [ZIMSqlHelper prepareValue: value] forKey: column];
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

@end
