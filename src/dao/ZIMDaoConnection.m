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

#import "ZIMDaoConnection.h"

// Defines the integer value for the table column datatype
#define ZIMDAO_DATE								6

/*!
 @category		ZIMDaoConnection (Private)
 @discussion	This category defines the prototpes for this class's private methods.
 @updated		2011-03-23
 */
@interface ZIMDaoConnection (Private)
/*!
 @method			selectorForSettingColumnName:
 @discussion		This method will make a "set" selector for the specified column.
 @param string		The column.
 @return			The "set" selector.
 @updated			2011-04-10
 */
- (SEL) selectorForSettingColumnName: (NSString *)column;
/*!
 @method			capitalizeString:
 @discussion		This method will capitalize the first letter in a string.
 @param string		The string to be modified.
 @return			The modified string.
 @updated			2011-04-08
 @see				http://stackoverflow.com/questions/883897/easy-way-to-set-a-single-character-of-an-nsstring-to-uppercase
 */
- (NSString *) capitalizeString: (NSString *)string;
/*!
 @method			columnTypeAtIndex:inStatement:
 @discussion		This method will determine the data type for the specified column.
 @param column		The column index.
 @param statement	The prepared SQL statement.
 @return			The integer value of the data type for the specified column.
 @updated			2011-04-18
 @see				http://www.sqlite.org/datatype3.html
 @see				http://www.sqlite.org/c3ref/c_blob.html
 */
- (int) columnTypeAtIndex: (int)column inStatement: (sqlite3_stmt *)statement;
/*!
 @method			columnValueAtIndex:withColumnType:inStatement:
 @discussion		This method will fetch the value for the specified column.
 @param column		The column index.
 @param columnType	The integer value of the data type for the specified column.
 @param statement	The prepared SQL statement.
 @return			The prepared value.
 @updated			2011-03-24
 */
- (id) columnValueAtIndex: (int)column withColumnType: (int)columnType inStatement: (sqlite3_stmt *)statement;
@end

@implementation ZIMDaoConnection

- (id) initWithDataSource: (NSString *)dataSource {
	return [self initWithDataSource: dataSource withMultithreadingSupport: NO];
}

- (id) initWithDataSource: (NSString *)dataSource withMultithreadingSupport: (BOOL)multithreading {
	if ((self = [super init])) {
		dataSource = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: dataSource];
		NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile: dataSource];
		NSString *type = [config objectForKey: @"type"];
		NSString *database = [config objectForKey: @"database"];
		if ((type == nil) || ![[type lowercaseString] isEqualToString: @"sqlite"] || (database == nil)) {
			@throw [NSException exceptionWithName: @"ZIMDaoException" reason: @"Failed to load data source." userInfo: nil];
		}
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *workingPath = [NSString pathWithComponents: [NSArray arrayWithObjects: [(NSArray *)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0], database, nil]];
		if (![fileManager fileExistsAtPath: workingPath]) {
			NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: database];
			if ([fileManager fileExistsAtPath: resourcePath]) {
				NSError *error;
				if (![fileManager copyItemAtPath: resourcePath toPath: workingPath error: &error]) {
					@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to copy data source in resource directory to working directory. '%@'", [error localizedDescription]] userInfo: nil];
				}
			}
		}
		_dataSource = [workingPath copy];
		[fileManager release];
		[config release];
		if (multithreading) {
			_mutex = [[NSLock alloc] init];
		}
		[self open];
	}
	return self;
}

- (void) open {
	if (sqlite3_open([_dataSource UTF8String], &_database) != SQLITE_OK) {
		sqlite3_close(_database);
		@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to open database connection. '%S'", sqlite3_errmsg16(_database)] userInfo: nil];
	}
	_isConnected = YES;
}

- (NSNumber *) execute: (NSString *)sql {
	if (_mutex != nil) {
		[_mutex lock];
	}

	sqlite3_stmt *statement = NULL;

	if ((sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) || (sqlite3_step(statement) != SQLITE_DONE)) {
		sqlite3_finalize(statement);
		if (_mutex != nil) {
			[_mutex unlock];
		}
		@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to execute SQL statement. '%S'", sqlite3_errmsg16(_database)] userInfo: nil];
	}

	NSNumber *result = nil;

	if (([sql length] >= 6)  && [[[sql substringWithRange: NSMakeRange(0, 6)] uppercaseString] isEqualToString: @"INSERT"]) {
	 	// Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
		result = [NSNumber numberWithInt: sqlite3_last_insert_rowid(_database)];
	}
	else {
		result = [NSNumber numberWithBool: YES];
	}

	sqlite3_finalize(statement);

	if (_mutex != nil) {
		[_mutex unlock];
	}

	return result;
}

- (NSArray *) query: (NSString *)sql {
	return [self query: sql asObject: [NSMutableDictionary class]];
}

- (NSArray *) query: (NSString *)sql asObject: (Class)model {
	if (_mutex != nil) {
		[_mutex lock];
	}

	sqlite3_stmt *statement = NULL;
	
	if (sqlite3_prepare_v2(_database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		sqlite3_finalize(statement);
		
		if (_mutex != nil) {
			[_mutex unlock];
		}
		
		@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to perform query with SQL statement. '%S'", sqlite3_errmsg16(_database)] userInfo: nil];
	}

	NSMutableArray *columnNames = [[NSMutableArray alloc] init];
	NSMutableArray *columnTypes = [[NSMutableArray alloc] init];
	
	BOOL doFetchColumnInfo = YES;
	int columnCount = 0;
	
	NSMutableArray *records = [[[NSMutableArray alloc] init] autorelease];
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		id record = [[model alloc] init];

		if (doFetchColumnInfo) {
			columnCount = sqlite3_column_count(statement);
			
			for (int index = 0; index < columnCount; index++) {
				NSString *columnName = [NSString stringWithUTF8String: sqlite3_column_name(statement, index)];
				if (!([record isKindOfClass: [NSMutableDictionary class]] || [record respondsToSelector: [self selectorForSettingColumnName: columnName]])) {
					[record release];

					[columnNames release];
					[columnTypes release];
					
					sqlite3_finalize(statement);
					
					if (_mutex != nil) {
						[_mutex unlock];
					}
					
					@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to perform query with SQL statement because column '%@' could not be found in model.", columnName] userInfo: nil];
				}
				else {
					[columnNames addObject: columnName];
					[columnTypes addObject: [NSNumber numberWithInt: [self columnTypeAtIndex: index inStatement: statement]]];
				}
			}

			doFetchColumnInfo = NO;
		}
		
		for (int index = 0; index < columnCount; index++) {
			id value = [self columnValueAtIndex: index withColumnType: [[columnTypes objectAtIndex: index] intValue] inStatement: statement];
			if (value != nil) {
				[record setValue: value forKey: [columnNames objectAtIndex: index]];
			}
		}
		
		[records addObject: record];
		[record release];
	}
	
	[columnNames release];
	[columnTypes release];
	
	sqlite3_finalize(statement);

	if (_mutex != nil) {
		[_mutex unlock];
	}

	return records;
}

- (SEL) selectorForSettingColumnName: (NSString *)column {
	return NSSelectorFromString([NSString stringWithFormat: @"set%@:", [self capitalizeString: column]]);
}

- (NSString *) capitalizeString: (NSString *)string {
	return [string stringByReplacingCharactersInRange: NSMakeRange(0, 1) withString: [[string substringToIndex: 1] uppercaseString]];
}

- (int) columnTypeAtIndex: (int)column inStatement: (sqlite3_stmt *)statement {
	// Declared Datetype - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
	const NSSet *intTypes  = [NSSet setWithObjects: @"BIGINT", @"BOOL", @"BOOLEAN", @"INT", @"INT2", @"INT8", @"INTEGER", @"MEDIUMINT", @"SMALLINT", @"TINYINT", @"UNSIGNED BIG INT", nil];
	const NSSet *realTypes = [NSSet setWithObjects: @"DECIMAL", @"DOUBLE", @"DOUBLE PRECISION", @"FLOAT", @"NUMERIC", @"REAL", nil];
	const NSSet *strTypes  = [NSSet setWithObjects: @"CHAR", @"CHARACTER", @"CLOB", @"NATIONAL VARYING CHARACTER", @"NATIVE CHARACTER", @"NCHAR", @"NVARCHAR", @"TEXT", @"VARCHAR", @"VARIANT", @"VARYING CHARACTER", nil];
	const NSSet *binTypes  = [NSSet setWithObjects: @"BLOB", nil];
	const NSSet *nullTypes = [NSSet setWithObjects: @"NULL", nil];
	const NSSet *dateTypes = [NSSet setWithObjects: @"DATE", @"DATETIME", @"TIMESTAMP", nil];
	// Determine data type of the column - http://www.sqlite.org/c3ref/c_blob.html
	const char *columnType = (const char *)sqlite3_column_decltype(statement, column);
	if (columnType != NULL) {
		NSString *dataType = [[NSString stringWithUTF8String: columnType] uppercaseString];
		NSRange end = [dataType rangeOfString: @"("];
		if (end.location != NSNotFound) {
			dataType = [dataType substringWithRange: NSMakeRange(0, end.location)];
		}
		if ([intTypes containsObject: dataType])	{
			return SQLITE_INTEGER;
		}
		if ([realTypes containsObject: dataType]) {
			return SQLITE_FLOAT;
		}
		if ([strTypes containsObject: dataType]) {
			return SQLITE_TEXT;
		}
		if ([binTypes containsObject: dataType]) {
			return SQLITE_BLOB;
		}
		if ([nullTypes containsObject: dataType]) {
			return SQLITE_NULL;
		}
		if ([dateTypes containsObject: dataType]) {
			return ZIMDAO_DATE;
		}
		return SQLITE_TEXT;
	}
	return sqlite3_column_type(statement, column);
}

- (id) columnValueAtIndex: (int)column withColumnType: (int)columnType inStatement: (sqlite3_stmt *)statement {
	if (columnType == SQLITE_INTEGER) {
		return [NSNumber numberWithInt: sqlite3_column_int(statement, column)];
	}
	if (columnType == SQLITE_FLOAT) {
		return [NSNumber numberWithDouble: sqlite3_column_double(statement, column)];
	}
	if (columnType == SQLITE_TEXT) {
		const char *text = (const char *)sqlite3_column_text(statement, column);
		if (text != NULL) {
			return [NSString stringWithUTF8String: text];
		}
	}
	if (columnType == SQLITE_BLOB) {
		return [NSData dataWithBytes: sqlite3_column_blob(statement, column) length: sqlite3_column_bytes(statement, column)];
	}
	if (columnType == ZIMDAO_DATE) {
		const char *text = (const char *)sqlite3_column_text(statement, column);
		if (text != NULL) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
			NSDate *date = [formatter dateFromString: [NSString stringWithUTF8String: text]];
			[formatter release];
			return date;
		}
	}
	return [NSNull null];
}

- (BOOL) isConnected {
	return _isConnected;
}

- (void) close {
	if (sqlite3_close(_database) != SQLITE_OK) {
		@throw [NSException exceptionWithName: @"ZIMDaoException" reason: [NSString stringWithFormat: @"Failed to close database connection. '%S'", sqlite3_errmsg16(_database)] userInfo: nil];
	}
	_isConnected = NO;
}

- (void) dealloc {
	[self close];
	[_dataSource release];
	if (_mutex != nil) {
		[_mutex release];
	}
	[super dealloc];
}

+ (NSNumber *) dataSource: (NSString *)dataSource execute: (NSString *)sql {
	ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: dataSource withMultithreadingSupport: NO];
	NSNumber *result = [connection execute: sql];
	[connection release];
	return result;
}

+ (NSArray *) dataSource: (NSString *)dataSource query: (NSString *)sql {
	ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: dataSource withMultithreadingSupport: NO];
	NSArray *records = [connection query: sql];
	[connection release];
	return records;
}

+ (NSArray *) dataSource: (NSString *)dataSource query: (NSString *)sql asObject: (Class)model {
	ZIMDaoConnection *connection = [[ZIMDaoConnection alloc] initWithDataSource: dataSource withMultithreadingSupport: NO];
	NSArray *records = [connection query: sql asObject: model];
	[connection release];
	return records;
}

@end
