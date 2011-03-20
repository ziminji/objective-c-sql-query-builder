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

#import "ZIMSqlCreateTableStatement.h"

@implementation ZIMSqlCreateTableStatement

- (id) init {
	if (self = [super init]) {
		_table = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}
/*
- (void) column: (NSString *)column type: (NSString *)type length: (NSInteger)length notNull: (BOOL) nnull primaryKey: (BOOL)key unique: (BOOL)unique defaultValue: (NSString *)value {

}
*/
- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendFormat: @"CREATE TABLE %@ ", _table];
	
	[sql appendString: @";"];
	
	return sql;
	//return @"CREATE TABLE test_table (col1 INTEGER NOT NULL, col2 CHAR(25), col3 VARCHAR(25), col4 NUMERIC NOT NULL, col5 TEXT(25), PRIMARY KEY (col1),	UNIQUE (col2));";
}

@end
