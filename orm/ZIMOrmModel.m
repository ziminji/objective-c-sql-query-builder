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

#import <objc/runtime.h>
#import "ZIMDaoConnection.h"
#import "ZIMOrmModel.h"
#import "ZIMSqlDeleteStatement.h"
#import "ZIMSqlInsertStatement.h"
#import "ZIMSqlUpdateStatement.h"

@implementation ZIMOrmModel

#if !defined(ZIMOrmDataSource)
	// Define pre-processing instruction "ZIMOrmDataSource" in <project-name>_Prefix.pch 
	#define ZIMOrmDataSource		@"DefaultDB.sqlite"
#endif

- (id) init {
	if (self = [super init]) {
		_primaryKey = [NSSet setWithObject: @"pk"];
		_autoIncremented = YES;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) delete {
	if ((_primaryKey != nil) && ([_primaryKey count] > 0)) {
		ZIMSqlDeleteStatement *sql = [[ZIMSqlDeleteStatement alloc] init];
		[sql table: [[self class] table]];
		for (NSString *column in _primaryKey) {
			NSString *value = [self valueForKey: column];
			if (value == nil) {
				[sql release];
				@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to delete record because column '%@' has no assigned value.", column] userInfo: nil];
			}
			[sql where: column operator: ZIMSqlOperatorEqualTo value: [self valueForKey: column]];
		}
		[ZIMDaoConnection dataSource: [[self class] dataSource] execute: [sql statement]];
		[sql release];
		_saved = NO;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because no primary key has been declared." userInfo: nil];
	}
}

- (void) save {
	if ((_primaryKey != nil) && ([_primaryKey count] > 0)) {
		NSMutableDictionary *columns = [[NSMutableDictionary alloc] initWithDictionary: [[self class] columns]];
		if (!_saved) {
			if (_autoIncremented) {
				for (NSString *column in _primaryKey) {
					[columns removeObjectForKey: column];
				}
			}
			if ([columns count] > 0) {
				ZIMSqlInsertStatement *sql = [[ZIMSqlInsertStatement alloc] init];
				[sql table: [[self class] table]];
				for (NSString *column in columns) {
					[sql column: column value: [self valueForKey: column]];
				}
				NSNumber *result = [ZIMDaoConnection dataSource: [[self class] dataSource] execute: [sql statement]];
				if (_autoIncremented) {
					[self setValue: result forKey: [[_primaryKey allObjects] objectAtIndex: 0]];
				}
				[sql release];
				_saved = YES;
			}
		}
		else {
			for (NSString *column in _primaryKey) {
				[columns removeObjectForKey: column];
			}
			if ([columns count] > 0) {
				ZIMSqlUpdateStatement *sql = [[ZIMSqlUpdateStatement alloc] init];
				[sql table: [[self class] table]];
				for (NSString *column in columns) {
					[sql column: column value: [self valueForKey: column]];
				}
				for (NSString *column in _primaryKey) {
					NSString *value = [self valueForKey: column];
					if (value == nil) {
						[sql release];
						@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to delete record because column '%@' has no assigned value.", column] userInfo: nil];
					}
					[sql where: column operator: ZIMSqlOperatorEqualTo value: [self valueForKey: column]];
				}
				[ZIMDaoConnection dataSource: [[self class] dataSource] execute: [sql statement]];
				[sql release];
			}
		}
		[columns release];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because no primary key has been declared." userInfo: nil];
	}
}

+ (NSString *) dataSource {
	return ZIMOrmDataSource;
}

+ (NSString *) table {
	return NSStringFromClass([self class]);
}

+ (NSDictionary *) columns {	
	NSSet *configurations = [[NSSet alloc] initWithObjects: @"_primaryKey", @"_autoIncremented", @"_saved", nil];

	unsigned int columnCount;

	Ivar *vars = class_copyIvarList([self class], &columnCount);

	NSMutableDictionary *columns = [[[NSMutableDictionary alloc] initWithCapacity: columnCount] autorelease];

	for (int i = 0; i < columnCount; i++) {
		Ivar var = vars[i];
		
		NSString *columnName = [NSString stringWithUTF8String: ivar_getName(var)];
		NSString *columnType = [NSString stringWithUTF8String: ivar_getTypeEncoding(var)];
		
		if (![configurations containsObject: columnName]) {
			[columns setObject: columnType forKey: columnName];
		}
	}
	
	free(vars);

	[configurations release];

	return columns;
}

@end
