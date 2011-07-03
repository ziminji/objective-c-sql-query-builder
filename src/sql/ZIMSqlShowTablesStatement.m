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

#import "ZIMSqlShowTablesStatement.h"

@implementation ZIMSqlShowTablesStatement

- (id) init {
	if (self = [super init]) {
		_clause = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) like: (NSString *)value {
	_clause = [NSString stringWithFormat: @"[name] LIKE %@", [ZIMSqlExpression prepareValue: value]];
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];

	[sql appendString: @"SELECT [name] FROM [sqlite_master] WHERE [type] = 'table' AND [name] NOT IN ('sqlite_sequence')"];

	if (_clause != nil) {
		[sql appendFormat: @" AND %@", _clause];
	}

	[sql appendString: @" ORDER BY [name] ASC"];

	[sql appendString: @";"];
	
	return sql;
}

@end
