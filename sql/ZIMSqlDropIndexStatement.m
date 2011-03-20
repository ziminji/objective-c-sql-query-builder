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

#import "ZIMSqlDropIndexStatement.h"

@implementation ZIMSqlDropIndexStatement

- (id) init {
	if (self = [super init]) {
		_index = nil;
		_exists = NO;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) index: (NSString *)index {
	[self index: index exists: NO];
}

- (void) index: (NSString *)index exists: (BOOL)exists {
	_index = index;
	_exists = exists;
}

- (NSString *) statement {
	NSMutableString *sql = [[[NSMutableString alloc] init] autorelease];
	
	[sql appendString: @"DROP INDEX "];
	
	if (_exists) {
		[sql appendString: @"IF EXISTS "];
	}
	
	[sql appendString: _index];
	
	[sql appendString: @";"];
	
	return sql;
}

@end
