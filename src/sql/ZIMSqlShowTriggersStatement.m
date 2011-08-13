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

#import "ZIMSqlShowTriggersStatement.h"

@implementation ZIMSqlShowTriggersStatement

- (id) init {
	if ((self = [super init])) {
		_from = @"[sqlite_master]";
		_like = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) show: (NSString *)type {
	type = [type uppercaseString];
	if ([type isEqualToString: ZIMSqlShowTypeAll]) {
		_from = @"(SELECT * FROM [sqlite_master] UNION ALL SELECT * FROM [sqlite_temp_master])";
	}
	else if ([type isEqualToString: ZIMSqlShowTypePermanent]) {
		_from = @"[sqlite_master]";
	}
	else if ([type isEqualToString: ZIMSqlShowTypeTemporary] || [type isEqualToString: @"TEMP"]) {
		_from = @"[sqlite_temp_master]";
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMSqlException" reason: @"Invalid set type token provided." userInfo: nil];
	}
}

- (void) like: (NSString *)value {
	_like = [NSString stringWithFormat: @"[name] LIKE %@", [ZIMSqlExpression prepareValue: value]];
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];

	[sql appendString: @"SELECT [name]"];

	[sql appendFormat: @" FROM %@", _from];

	[sql appendString: @" WHERE [type] = 'trigger' AND [name] NOT IN ('sqlite_sequence')"];

	if (_like != nil) {
		[sql appendFormat: @" AND %@", _like];
	}

	[sql appendString: @" ORDER BY [name] ASC"];

	[sql appendString: @";"];
	
	return sql;
}

@end
