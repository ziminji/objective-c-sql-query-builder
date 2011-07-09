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

#import "ZIMSqlCreateIndexStatement.h"

@implementation ZIMSqlCreateIndexStatement

- (id) init {
	if (self = [super init]) {
		_unique = NO;
		_index = nil;
		_table = nil;
		_column = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void) dealloc {
	[_column release];
	[super dealloc];
}

- (void) unique: (BOOL)unique {
	_unique = unique;
}

- (void) index: (NSString *)index on: (NSString *)table {
	_index = [ZIMSqlExpression prepareIdentifier: index];
	_table = [ZIMSqlExpression prepareIdentifier: table];
}

- (void) column: (NSString *)column {
	[_column addObject: [ZIMSqlExpression prepareIdentifier: column]];
}

- (void) columns: (NSSet *)columns {
	for (NSString *column in columns) {
		[_column addObject: [ZIMSqlExpression prepareIdentifier: column]];
	}
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];

	[sql appendString: @"CREATE"];

	if (_unique) {
		[sql appendString: @" UNIQUE"];
	}

	[sql appendFormat: @" INDEX %@ ON %@", _index, _table];
	
	if ([_column count] > 0) {
		[sql appendFormat: @" (%@)", [[_column allObjects] componentsJoinedByString: @", "]];
	}

	[sql appendString: @";"];

	return sql;
}

@end
