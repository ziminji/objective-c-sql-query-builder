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

#import "ZIMSqlCreateTableStatement.h"

@implementation ZIMSqlCreateTableStatement

- (id) init {
	if ((self = [super init])) {
		_table = nil;
		_temporary = NO;
		_column = [[NSMutableDictionary alloc] init];
		_primaryKey = nil;
		_unique = nil;
	}
	return self;
}

- (void) dealloc {
	[_column release];
	[super dealloc];
}

- (void) table: (NSString *)table {
	[self table: table temporary: NO];
}

- (void) table: (NSString *)table temporary: (BOOL)temporary {
	_table = [ZIMSqlExpression prepareIdentifier: table];
	_temporary = temporary;
}

- (void) column: (NSString *)column type: (NSString *)type {
	[_column setObject: [NSString stringWithFormat: @"%@ %@", column, type] forKey: column];
}

- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value {
	[_column setObject: [NSString stringWithFormat: @"%@ %@ %@", column, type, value] forKey: column];
}

- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey {
	if (primaryKey) {
		[_column setObject: [NSString stringWithFormat: @"%@ %@ PRIMARY KEY", column, type] forKey: column];
	}
	else {
		[_column setObject: [NSString stringWithFormat: @"%@ %@", column, type] forKey: column];
	}
}

- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique {
	if (unique) {
		[_column setObject: [NSString stringWithFormat: @"%@ %@ UNIQUE", column, type] forKey: column];
	}
	else {
		[_column setObject: [NSString stringWithFormat: @"%@ %@", column, type] forKey: column];
	}
}

- (void) primaryKey: (NSArray *)columns {
	if (columns != nil) {
		for (NSString *column in columns) {
			if ([_column objectForKey: column] == nil) {
				@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Must declare column '%@' before primary key can be assigned.", column] userInfo: nil];
			}
		}
		_primaryKey = [NSString stringWithFormat: @"PRIMARY KEY (%@)", [columns componentsJoinedByString: @", "]];
	}
	else {
		_primaryKey = nil;
	}
}

- (void) unique: (NSArray *)columns {
	if (columns != nil) {
		for (NSString *column in columns) {
			if ([_column objectForKey: column] == nil) {
				@throw [NSException exceptionWithName: @"ZIMSqlException" reason: [NSString stringWithFormat: @"Must declare column '%@' before applying unique constraint.", column] userInfo: nil];
			}
		}
		_unique = [NSString stringWithFormat: @"UNIQUE (%@)", [columns componentsJoinedByString: @", "]];
	}
	else {
		_unique = nil;
	}
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendString: @"CREATE"];

	if (_temporary) {
		[sql appendString: @" TEMPORARY"];
	}
	
	[sql appendFormat: @" TABLE %@ (", _table];

	int i = 0;
	for (NSString *column in _column) {
		if (i > 0) {
			[sql appendFormat: @", %@", (NSString *)[_column objectForKey: column]];
		}
		else {
			[sql appendString: (NSString *)[_column objectForKey: column]];
		}
		i++;
	}

	if (_primaryKey != nil) {
		[sql appendFormat: @", %@", _primaryKey];
	}

	if (_unique != nil) {
		[sql appendFormat: @", %@", _unique];
	}

	[sql appendString: @");"];
	
	return sql;
}

@end
