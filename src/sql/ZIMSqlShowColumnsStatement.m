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

#import <sqlite3.h> // Requires libsqlite3.dylib
#import "ZIMSqlShowColumnsStatement.h"

@implementation ZIMSqlShowColumnsStatement

- (id) init {
	if ((self = [super init])) {
		_table = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) from: (NSString *)table {
	_table = table;
}

- (NSString *) statement {
	char *xsql = sqlite3_mprintf("PRAGMA table_info(%s);", [_table UTF8String]);
	NSString *sql = [NSString stringWithUTF8String: (const char *)xsql];
	sqlite3_free(xsql);
	return sql;
}

@end
