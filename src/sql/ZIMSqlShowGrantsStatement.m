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

#import "ZIMSqlShowGrantsStatement.h"

@implementation ZIMSqlShowGrantsStatement

#if !defined(ZIMDbPropertyList)
    #define ZIMDbPropertyList @"db.plist" // Override this pre-processing instruction in your <project-name>_Prefix.pch
#endif

- (id) init {
	if ((self = [super init])) {
		NSString *file = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: ZIMDbPropertyList];
		_plist = [NSDictionary dictionaryWithContentsOfFile: file];
	}
	return self;
}

- (void) forGrantee: (NSString *)dataSource {
	if (dataSource != nil) {
		NSDictionary *config = [_plist objectForKey: dataSource];
		if (config == nil) {
	        @throw [NSException exceptionWithName: @"ZIMDbException" reason: @"Failed to load data source." userInfo: nil];
	    }
	}
	_dataSource = dataSource;
}

// GRANTEE | TABLE_CATALOG | PRIVILEGE_TYPE | IS_GRANTABLE
- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];

	[sql appendString: @"SELECT * FROM ("];

	int index = 0;
	for (NSString *dataSource in _plist) {
		if ((_dataSource == nil) || [_dataSource isEqualToString: dataSource]) {
			NSDictionary *config = [_plist objectForKey: dataSource];

			NSString *grantee = [NSString stringWithFormat: @" %@ AS [GRANTEE],", [ZIMSqlExpression prepareValue: [NSString stringWithFormat: @"'%@'@'localhost'", dataSource]]];
			NSString *catalog = @" NULL AS [TABLE_CATALOG],";
			NSString *grantable = @" 'NO' AS [IS_GRANTABLE]";

			NSMutableSet *types = [[NSMutableSet alloc] init];
			NSArray *privileges = [config objectForKey: @"privileges"];

		    if (privileges != nil) {
				for (NSString *privilege in privileges) {
				    [types addObject: [privilege uppercaseString]];
				}
		    }
			else {
				[types addObject: @"ALTER"];
				[types addObject: @"ANALYZE"];
				[types addObject: @"ATTACH"];
				[types addObject: @"CREATE"];
				[types addObject: @"DELETE"];
				[types addObject: @"DETACH"];
				[types addObject: @"DROP"];
				[types addObject: @"EXPLAIN"];
				[types addObject: @"INSERT"];
				[types addObject: @"PRAGMA"];
				[types addObject: @"REINDEX"];
				[types addObject: @"SELECT"];
				[types addObject: @"UPDATE"];
				[types addObject: @"VACUUM"];
			}
		    [types addObject: @"BEGIN"];
		    [types addObject: @"COMMIT"];
		    [types addObject: @"ROLLBACK"];

			for (NSString *type in types) {
				if (index > 0) {
					[sql appendString: @" UNION ALL "];
				}
				[sql appendString: @"SELECT"];
				[sql appendString: grantee];
				[sql appendString: catalog];
				[sql appendFormat: @" '%@' AS [PRIVILEGE_TYPE],", type];
				[sql appendString: grantable];
				index++;
			}
		}
	}

	[sql appendString: @") ORDER BY [GRANTEE], [PRIVILEGE_TYPE];"];

	return sql;
}

@end
