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

#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "ZIMDaoConnection.h"
#import "ZIMOrmModel.h"
#import "ZIMSqlDeleteStatement.h"
#import "ZIMSqlInsertStatement.h"
#import "ZIMSqlSelectStatement.h"
#import "ZIMSqlUpdateStatement.h"

@implementation ZIMOrmModel

#if !defined(ZIMOrmDataSource)
	#define ZIMOrmDataSource @"sqlite.plist" // Define this pre-processing instruction "ZIMOrmDataSource" in <project-name>_Prefix.pch
#endif

- (id) init {
	if (self = [super init]) {
		_saved = nil;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) delete {
	if (![[self class] isSaveable]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because this model is not savable." userInfo: nil];
	}
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: [[self class] dataSource]];
		[connection execute: @"BEGIN IMMEDIATE TRANSACTION;"];
		ZIMSqlDeleteStatement *sql = [[ZIMSqlDeleteStatement alloc] init];
		[sql table: [[self class] table]];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if (value == nil) {
				[sql release];
				[connection release];
				@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to delete record because column '%@' is not assigned a value.", column] userInfo: nil];
			}
			[sql where: column operator: ZIMSqlOperatorEqualTo value: value];
		}
		[connection execute: [sql statement]];
		[sql release];
		_saved = nil;
		[connection execute: @"COMMIT TRANSACTION;"];
		[connection release];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because no primary key has been declared." userInfo: nil];
	}
}

- (void) load {
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMSqlSelectStatement *sql = [[ZIMSqlSelectStatement alloc] init];
		[sql from: [[self class] table]];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if (value == nil) {
				[sql release];
				@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to load record because column '%@' is not assigned a value.", column] userInfo: nil];
			}
			[sql where: column operator: ZIMSqlOperatorEqualTo value: value];
		}
		[sql limit: 1];
		ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: [[self class] dataSource]];
		[connection execute: @"BEGIN IMMEDIATE TRANSACTION;"];
		NSArray *records = [connection query: [sql statement]];
		[connection execute: @"COMMIT TRANSACTION;"];
		[connection release];
		[sql release];
		if ([records count] != 1) {
			@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to load record because the declared primary is invalid." userInfo: nil];
		}
		NSDictionary *record = [records objectAtIndex: 0];
		for (NSString *column in record) {
			[self setValue: [record valueForKey: column] forKey: column];
		}
		_saved = [self hashCode];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to load record because no primary key has been declared." userInfo: nil];
	}
}

- (void) save {
	if (![[self class] isSaveable]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to save record because this model is not savable." userInfo: nil];
	}
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: [[self class] dataSource]];
		[connection execute: @"BEGIN IMMEDIATE TRANSACTION;"];
		NSMutableDictionary *columns = [[NSMutableDictionary alloc] initWithDictionary: [[self class] columns]];
		NSString *hashCode = [self hashCode];
		BOOL doInsert = (hashCode == nil);
		if (!doInsert) {
			doInsert = ((_saved == nil) || ![_saved isEqualToString: hashCode]);
			if (doInsert) {
				ZIMSqlSelectStatement *select = [[ZIMSqlSelectStatement alloc] init];
				[select column: @"1" alias: @"IsFound"];
				[select from: [[self class] table]];
				for (NSString *column in primaryKey) {
					[select where: column operator: ZIMSqlOperatorEqualTo value: [self valueForKey: column]];
				}
				[select limit: 1];
				NSArray *records = [connection query: [select statement]];
				doInsert = ([records count] == 0);
				[select release];
			}
			if (!doInsert) {
				for (NSString *column in primaryKey) {
					[columns removeObjectForKey: column];
				}
				if ([columns count] > 0) {
					ZIMSqlUpdateStatement *update = [[ZIMSqlUpdateStatement alloc] init];
					[update table: [[self class] table]];
					for (NSString *column in columns) {
						[update column: column value: [self valueForKey: column]];
					}
					for (NSString *column in primaryKey) {
						NSString *value = [self valueForKey: column];
						if (value == nil) {
							[update release];
							[columns release];
							[connection release];
							@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to save record because column '%@' has no assigned value.", column] userInfo: nil];
						}
						[update where: column operator: ZIMSqlOperatorEqualTo value: value];
					}
					[connection execute: [update statement]];
					[update release];
					_saved = hashCode;
				}
			}
		}
		if (doInsert) {
			if ([[self class] isAutoIncremented] && (hashCode == nil)) {
				for (NSString *column in primaryKey) {
					[columns removeObjectForKey: column];
				}
			}
			if ([columns count] > 0) {
				ZIMSqlInsertStatement *insert = [[ZIMSqlInsertStatement alloc] init];
				[insert table: [[self class] table]];
				for (NSString *column in columns) {
					NSString *value = [self valueForKey: column];
					if ((value == nil) && [primaryKey containsObject: column]) {
						[insert release];
						[columns release];
						[connection release];
						@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to save record because column '%@' has no assigned value.", column] userInfo: nil];
					}
					[insert column: column value: value];
				}
				NSNumber *result = [connection execute: [insert statement]];
				if ([[self class] isAutoIncremented] && (hashCode == nil)) {
					[self setValue: result forKey: [primaryKey objectAtIndex: 0]];
				}
				[insert release];
				_saved = [self hashCode];
			}
		}
		[columns release];
		[connection execute: @"COMMIT TRANSACTION;"];
		[connection release];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to save record because no primary key has been declared." userInfo: nil];
	}
}

- (NSString *) hashCode {
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		NSMutableString *buffer = [[NSMutableString alloc] init];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if (value == nil) {
				[buffer release];
				return nil;
			}
			[buffer appendFormat: @"%@=%@", column, value];
		}
		const char *cString = [buffer UTF8String];
		[buffer release];
		unsigned char digest[CC_SHA1_DIGEST_LENGTH];
		CC_SHA1(cString, strlen(cString), digest);
		NSMutableString *hashKey = [NSMutableString stringWithCapacity: CC_SHA1_DIGEST_LENGTH * 2];
		for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
			[hashKey appendFormat: @"%02X", digest[i]];
		}
		return [hashKey lowercaseString];
	}
	return nil;
}

+ (NSString *) dataSource {
	return ZIMOrmDataSource;
}

+ (NSString *) table {
	return NSStringFromClass([self class]);
}

+ (NSArray *) primaryKey {
	return [NSArray arrayWithObject: @"pk"];
}

+ (BOOL) isAutoIncremented {
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey == nil) || ([primaryKey count] != 1)) {
		return NO;
	}
	return YES;
}

+ (NSDictionary *) columns {
	// TODO get instance variables from super classes as well to allow further subclassing
	NSSet *configurations = [[NSSet alloc] initWithObjects: @"_saved", nil];
	unsigned int columnCount;
	Ivar *vars = class_copyIvarList([self class], &columnCount);
	int capacity = (columnCount - [configurations count]) * 2;
	NSMutableDictionary *columns = [[[NSMutableDictionary alloc] initWithCapacity: capacity] autorelease];
	for (int i = 0; i < columnCount; i++) {
		Ivar var = vars[i];
		NSString *columnName = [NSString stringWithUTF8String: ivar_getName(var)];
		if (![configurations containsObject: columnName]) {
			NSString *columnType = [NSString stringWithUTF8String: ivar_getTypeEncoding(var)]; // http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
			[columns setObject: columnType forKey: columnName];
		}
	}
	free(vars);
	[configurations release];
	return columns;
}

+ (BOOL) isSaveable {
	return YES;
}

@end
