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

#import "ZIMDbConnection.h"
#import "ZIMDbConnectionPool.h"

@implementation ZIMDbConnectionPool

+ (ZIMDbConnectionPool *) sharedInstance {
	static ZIMDbConnectionPool *_singleton = nil;
	static dispatch_once_t _dispatched;
	dispatch_once(&_dispatched, ^{
		_singleton = [[ZIMDbConnectionPool alloc] init];
	});
	return _singleton;
}

- (id) init {
	if ((self = [super init])) {
		_connections = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (ZIMDbConnection *) connection: (NSString *)dataSource {
	ZIMDbConnection *connection = nil;
	@synchronized(self) {
		connection = [_connections objectForKey: dataSource];
		if (connection == nil) {
			connection = [[ZIMDbConnection alloc] initWithDataSource: dataSource];
			[_connections setObject: connection forKey: dataSource];
		}
		else {
			[connection open];
		}
	}
	return connection;
}

- (void) closeAll {
	for (ZIMDbConnection *connection in _connections) {
		[connection close];
	}
}

- (void) destoryAll {
	[_connections removeAllObjects];
}

- (void) dealloc {
	[self closeAll];
}

@end
