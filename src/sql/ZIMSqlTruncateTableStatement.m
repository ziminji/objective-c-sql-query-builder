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

#import "ZIMSqlTruncateTableStatement.h"

@implementation ZIMSqlTruncateTableStatement

- (id) init {
	if ((self = [super init])) {
		_tableIdentifier = nil;
		_tableName = nil;
	}
	return self;
}

- (void) table: (NSString *)table {
	_tableIdentifier = [ZIMSqlExpression prepareIdentifier: table];
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"[^a-z0-9_ ]" options: NSRegularExpressionCaseInsensitive error: &error];
	NSString *tableName = [regex stringByReplacingMatchesInString: table options: 0 range: NSMakeRange(0, [table length]) withTemplate: @""];
	tableName = [tableName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	_tableName = [ZIMSqlExpression prepareValue: tableName];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	[sql appendFormat: @"DELETE FROM %@; ", _tableIdentifier];
	[sql appendFormat: @"DELETE FROM [sqlite_sequence] WHERE [name] = %@;", _tableName];
	return sql;
}

@end
