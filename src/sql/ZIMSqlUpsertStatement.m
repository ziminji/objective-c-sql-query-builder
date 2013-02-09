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

#import "ZIMSqlUpsertStatement.h"

@implementation ZIMSqlUpsertStatement

- (id) init {
	if ((self = [super init])) {
		_compositeKey = nil;
	}
	return self;
}

- (void) matching: (NSArray *)columns { // i.e the (composite) primary key or a unique key
	if (columns != nil) {
		NSMutableSet *compositeKey = [[NSMutableSet alloc] init];
		for (NSString *column in columns) {
			NSString *identifier = [ZIMSqlExpression prepareIdentifier: column];
			if ([_column objectForKey: identifier] == nil) {
				@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Must declare column '%@' before it can be matched against.", identifier] userInfo: nil];
			}
			[compositeKey addObject: identifier];
		}
		_compositeKey = compositeKey;
	}
	else {
		_compositeKey = nil;
	}
}

- (NSString *) statement {
	// Note: Because "INSERT OR REPLACE" requires prior knowledge of the table's columns to properly update a record,
	// this method to mimicing an upsert statement was chosen.  Therefore, always match against either the primary key
	// or a unique key.

	NSMutableString *sql = [[NSMutableString alloc] init];

	[sql appendFormat: @"UPDATE OR IGNORE %@ SET ", _table];
	
	NSMutableArray *set = [[NSMutableArray alloc] init];
	NSMutableArray *where = [[NSMutableArray alloc] init];

	for (NSString *column in _column) {
		if ([_compositeKey containsObject: column]) {
			[where addObject: [NSString stringWithFormat: @"%@ = %@", column, [_column objectForKey: column]]];
		}
		else {
			[set addObject: [NSString stringWithFormat: @"%@ = %@", column, [_column objectForKey: column]]];
		}
	}

	[sql appendString: [set componentsJoinedByString: @", "]];
	[sql appendString: @" WHERE "];
	[sql appendString: [where componentsJoinedByString: @" AND "]];

	[sql appendString: @"; "];

	[sql appendFormat: @"INSERT OR IGNORE INTO %@ ", _table];

	[sql appendFormat: @"(%@) VALUES (%@)", [[_column allKeys] componentsJoinedByString: @", "], [[_column allValues] componentsJoinedByString: @", "]];

	[sql appendString: @";"];

	return sql;
}

@end
