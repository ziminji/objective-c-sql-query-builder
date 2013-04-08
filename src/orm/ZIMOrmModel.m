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

#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "ZIMDbConnection.h"
#import "ZIMOrmModel.h"
#import "ZIMSqlDeleteStatement.h"
#import "ZIMSqlInsertStatement.h"
#import "ZIMSqlSelectStatement.h"
#import "ZIMSqlUpdateStatement.h"

/*!
 @category		ZIMOrmModel (Private)
 @discussion	This category defines the prototpes for this class's private methods.
 @updated		2012-03-10
 */
@interface ZIMOrmModel (Private)
/*!
 @method				hashCode
 @discussion			This method returns a hash code that is calculated by first concatenating the value
						assigned to each primary key and then finding the SHA1 has for the concatenated string.
 @updated				2012-03-11
 */
- (NSString *) hashCode;
@end

@implementation ZIMOrmModel

#if !defined(ZIMOrmDataSource)
    #define ZIMOrmDataSource @"live" // Override this pre-processing instruction in your <project-name>_Prefix.pch
#endif

@synthesize delegate = _delegate;

- (id) initWithDelegate: (id)delegate {
	if ((self = [super init])) {
		_delegate = delegate;
		_saved = nil;
	}
	return self;
}

- (id) init {
	return [self initWithDelegate: nil];
}

- (id) belongsTo: (Class)model foreignKey: (NSArray *)foreignKey {
	if (![ZIMOrmModel isModel: model]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Invalid class type specified." userInfo: nil];
	}
	id record = [[model alloc] init];
	NSArray *primaryKey = [model primaryKey];
	int columnCount = [primaryKey count];
	for (int i = 0; i < columnCount; i++) {
		[record setValue: [self valueForKey: [foreignKey objectAtIndex: i]] forKey: [primaryKey objectAtIndex: i]];
	}
	[(ZIMOrmModel *)record load];
	return record;
}

- (id) hasOne: (Class)model foreignKey: (NSArray *)foreignKey {
	NSArray *records = [self hasMany: model foreignKey: foreignKey options: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInteger: 1], ZIMOrmOptionLimit, nil]];
	return [records objectAtIndex: 0];
}

- (NSArray *) hasMany: (Class)model foreignKey: (NSArray *)foreignKey {
	return [self hasMany: model foreignKey: foreignKey options: nil];
}

- (NSArray *) hasMany: (Class)model foreignKey: (NSArray *)foreignKey options: (NSDictionary *)options {
	if (![ZIMOrmModel isModel: model]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Invalid class type specified." userInfo: nil];
	}
	ZIMSqlSelectStatement *sql = [[ZIMSqlSelectStatement alloc] init];
	[sql from: [model table]];
	NSArray *primaryKey = [[self class] primaryKey];
	int columnCount = [primaryKey count];
	for (int i = 0; i < columnCount; i++) {
		[sql where: [foreignKey objectAtIndex: i] operator: ZIMSqlOperatorEqualTo value: [self valueForKey: [primaryKey objectAtIndex: i]]];
	}
	if (options != nil) {
		if ([options objectForKey: ZIMOrmOptionLimit] != nil) {
			[sql limit: [[options objectForKey: ZIMOrmOptionLimit] integerValue]];
		}
		if ([options objectForKey: ZIMOrmOptionOffset] != nil) {
			[sql offset: [[options objectForKey: ZIMOrmOptionOffset] integerValue]];
		}
	}
	NSArray *records = [ZIMDbConnection dataSource: [model dataSource] query: [sql statement] asObject: model];
	return records;
}

- (void) delete {
	if (![[self class] isSaveable]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because this model is not savable." userInfo: nil];
	}
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelWillBeginDeletingRecord:)]) {
		[_delegate modelWillBeginDeletingRecord: self];
	}
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMSqlDeleteStatement *sql = [[ZIMSqlDeleteStatement alloc] init];
		[sql table: [[self class] table]];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if (value == nil) {
				@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to delete record because column '%@' is not assigned a value.", column] userInfo: nil];
			}
			[sql where: column operator: ZIMSqlOperatorEqualTo value: value];
		}
		ZIMDbConnection *connection = [[ZIMDbConnection alloc] initWithDataSource: [[self class] dataSource]];
		[connection beginTransaction];
		[connection execute: [sql statement]];
		[connection commitTransaction];
		[connection close];
		_saved = nil;
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to delete record because no primary key has been declared." userInfo: nil];
	}
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelDidFinishDeletingRecord:)]) {
		[_delegate modelDidFinishDeletingRecord: self];
	}
}

- (void) load {
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelWillBeginLoadingRecord:)]) {
		[_delegate modelWillBeginLoadingRecord: self];
	}
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMSqlSelectStatement *sql = [[ZIMSqlSelectStatement alloc] init];
		[sql from: [[self class] table]];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if (value == nil) {
				@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to load record because column '%@' is not assigned a value.", column] userInfo: nil];
			}
			[sql where: column operator: ZIMSqlOperatorEqualTo value: value];
		}
		[sql limit: 1];
		NSArray *records = [ZIMDbConnection dataSource: [[self class] dataSource] query: [sql statement]];
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
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelDidFinishLoadingRecord:)]) {
		[_delegate modelDidFinishLoadingRecord: self];
	}
}

- (void) save {
	if (![[self class] isSaveable]) {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to save record because this model is not savable." userInfo: nil];
	}
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelWillBeginSavingRecord:)]) {
		[_delegate modelWillBeginSavingRecord: self];
	}
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		ZIMDbConnection *connection = [[ZIMDbConnection alloc] initWithDataSource: [[self class] dataSource]];
		[connection beginTransaction];
		NSMutableDictionary *columns = [[NSMutableDictionary alloc] initWithDictionary: [[self class] columns]];
		NSString *hashCode = [self hashCode];
		BOOL doInsert = (hashCode == nil);
		if (!doInsert) {
			doInsert = ((_saved == nil) || ![_saved isEqualToString: hashCode]);
			if (doInsert) {
				ZIMSqlSelectStatement *select = [[ZIMSqlSelectStatement alloc] init];
				[select column: [NSNumber numberWithInteger: 1] alias: @"IsFound"];
				[select from: [[self class] table]];
				for (NSString *column in primaryKey) {
					[select where: column operator: ZIMSqlOperatorEqualTo value: [self valueForKey: column]];
				}
				[select limit: 1];
				NSArray *records = [connection query: [select statement]];
				doInsert = ([records count] == 0);
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
							[connection rollbackTransaction];
							[connection close];
							@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to save record because column '%@' has no assigned value.", column] userInfo: nil];
						}
						[update where: column operator: ZIMSqlOperatorEqualTo value: value];
					}
					[connection execute: [update statement]];
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
				[insert into: [[self class] table]];
				for (NSString *column in columns) {
					NSString *value = [self valueForKey: column];
					if ((value == nil) && [primaryKey containsObject: column]) {
						[connection rollbackTransaction];
						[connection close];
						@throw [NSException exceptionWithName: @"ZIMOrmException" reason: [NSString stringWithFormat: @"Failed to save record because column '%@' has no assigned value.", column] userInfo: nil];
					}
					[insert column: column value: value];
				}
				NSNumber *result = [connection execute: [insert statement]];
				if ([[self class] isAutoIncremented] && (hashCode == nil)) {
					[self setValue: result forKey: [primaryKey objectAtIndex: 0]];
				}
				_saved = [self hashCode];
			}
		}
		[connection commitTransaction];
		[connection close];
	}
	else {
		@throw [NSException exceptionWithName: @"ZIMOrmException" reason: @"Failed to save record because no primary key has been declared." userInfo: nil];
	}
	if ((_delegate != nil) && [_delegate respondsToSelector: @selector(modelDidFinishSavingRecord:)]) {
		[_delegate modelDidFinishSavingRecord: self];
	}
}

- (NSString *) hashCode {
	NSArray *primaryKey = [[self class] primaryKey];
	if ((primaryKey != nil) && ([primaryKey count] > 0)) {
		NSMutableString *buffer = [[NSMutableString alloc] init];
		for (NSString *column in primaryKey) {
			id value = [self valueForKey: column];
			if ((value != nil) && ! [value isKindOfClass: [NSNull class]]) {
				[buffer appendFormat: @"%@=%@", column, value];
			}
		}
		if ([buffer length] > 0) {
			const char *cString = [buffer UTF8String];
			unsigned char digest[CC_SHA512_DIGEST_LENGTH];
			CC_SHA512(cString, strlen(cString), digest);
			NSMutableString *hash = [NSMutableString stringWithCapacity: CC_SHA512_DIGEST_LENGTH * 2];
			for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
				[hash appendFormat: @"%02x", digest[i]];
			}
			return [hash lowercaseString];
		}
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
	NSMutableDictionary *columns = [[NSMutableDictionary alloc] initWithCapacity: capacity];
	for (int i = 0; i < columnCount; i++) {
		Ivar var = vars[i];
		NSString *columnName = [NSString stringWithUTF8String: ivar_getName(var)];
		if (![configurations containsObject: columnName]) {
			if ([columnName hasPrefix: @"_"]) {
				columnName = [columnName substringWithRange: NSMakeRange(1, [columnName length])];
			}
			NSString *columnType = [NSString stringWithUTF8String: ivar_getTypeEncoding(var)]; // http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
			[columns setObject: columnType forKey: columnName];
		}
	}
	free(vars);
	return columns;
}

+ (BOOL) isSaveable {
	return YES;
}

+ (BOOL) isModel: (Class)model {
	Class superClass = model;
	while ((superClass != nil) && (superClass != [ZIMOrmModel class])) {
		superClass = class_getSuperclass(superClass);
	}
	if (superClass == nil) {
		return NO;
	}
	return YES;
}

@end
