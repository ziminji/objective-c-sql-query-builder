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

#import "ZIMSqlExplainStatement.h"

@implementation ZIMSqlExplainStatement

- (id) init {
	if ((self = [super init])) {
		_level = 0;
		_statement = nil;
	}
	return self;
}

- (void) level: (NSUInteger)level {
	_level = level;
}

- (void) sql: (id<ZIMSqlStatement>)sql {
	_statement = [sql statement];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];

	[sql appendString: @"EXPLAIN "];
	
	if (_level > 0) {
		[sql appendString: @"QUERY PLAN "];
	}

	[sql appendString: _statement];
	
	[sql appendString: @";"];

	return sql;
}

@end
