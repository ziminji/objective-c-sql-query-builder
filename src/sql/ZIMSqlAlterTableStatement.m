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

#import "ZIMSqlAlterTableStatement.h"

@implementation ZIMSqlAlterTableStatement

- (id) init {
	if (self = [super init]) {
		_table = nil;
		_clause = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) table: (NSString *)table {
	_table = table;
}

- (void) column: (NSString *)column type: (NSString *)type {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
}

- (void) column: (NSString *)column type: (NSString *)type defaultValue: (NSString *)value {
	_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ %@", column, type, value];
}

- (void) column: (NSString *)column type: (NSString *)type primaryKey: (BOOL)primaryKey {
	if (primaryKey) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ PRIMARY KEY", column, type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
	}
}

- (void) column: (NSString *)column type: (NSString *)type unique: (BOOL)unique {
	if (unique) {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@ UNIQUE", column, type];
	}
	else {
		_clause = [NSString stringWithFormat: @"ADD COLUMN %@ %@", column, type];
	}
}

- (void) rename: (NSString *)table {
	_clause = [NSString stringWithFormat: @"RENAME TO %@", table];
}

- (NSString *) statement {	
	return [NSString stringWithFormat: @"ALTER TABLE %@ %@;", _table, _clause];
}

@end
