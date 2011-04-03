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

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Requires libsqlite3.dylib

/*!
 @class					ZIMDaoConnection
 @discussion			This class represents an SQL statements.
 @updated				2011-03-30
 */
@interface ZIMDaoConnection : NSObject {

	@protected
		NSString *_dataSource;
		NSLock *_mutex;
		sqlite3 *_database;
		BOOL _isConnected;

}
/*!
 @method				initWithDataSource:
 @discussion			This constructor creates an instance of this class with the specified data source
						and will attempt to open a database connection.  If the data source does not already
						exist in the working directoy, an attempt will be made to copy the data source from
						the resource directory to the working directory; otherwise, the data source will be
						created in the working directory.
 @param dataSource		The file name of the database to be used.
 @updated				2011-03-30
 */
- (id) initWithDataSource: (NSString *)dataSource;
/*!
 @method				initWithDataSource:withMultithreadingSupport:
 @discussion			This constructor creates an instance of this class with the specified data source
						and will attempt to open a database connection.  If the data source does not already
						exist in the working directoy, an attempt will be made to copy the data source from
						the resource directory to the working directory; otherwise, the data source will be
						created in the working directory.
 @param dataSource		The file name of the database to be used.
 @param support			This determines whether locks should be used.
 @updated				2011-03-30
 */
- (id) initWithDataSource: (NSString *)dataSource withMultithreadingSupport: (BOOL)support;
/*!
 @method				open
 @discussion			This method will open a connection to the database.
 @updated				2011-03-23
 */
- (void) open;
/*!
 @method				execute:
 @discussion			This method will execute the specified SQL statement.
 @param sql				The SQL statement to be used.
 @return				Either the last insert row id or TRUE.
 @updated				2011-03-30
 */
- (NSNumber *) execute: (NSString *)sql;
/*!
 @method				query:
 @discussion			This method will query with the specified SQL statement and will map
						each record to an NSDictionary.
 @param sql				The SQL statement to be used.
 @return				The result set (i.e. an array of records).
 @updated				2011-04-02
 */
- (NSArray *) query: (NSString *)sql;
/*!
 @method				query:asObject:
 @discussion			This method will query with the specified SQL statement and will map
						each record to the specified object (i.e. model).
 @param sql				The SQL statement to be used.
 @return				The result set (i.e. an array of records).
 @updated				2011-04-02
 */
- (NSArray *) query: (NSString *)sql asObject: (Class)model;
/*!
 @method				isConnected
 @discussion			This method checks whether a database connection currently exists.
 @return				Indicates whether a database connection exists.
 @updated				2011-03-23
 */
- (BOOL) isConnected;
/*!
 @method				close
 @discussion			This method will close an open database connection.
 @updated				2011-03-23
 */
- (void) close;
/*!
 @method				dataSource:execute:
 @discussion			This method will execute the specified SQL statement.
 @param dataSource		The file name of the database to be used.
 @param sql				The SQL statement to be used.
 @return				Either the last insert row id or TRUE.
 @updated				2011-03-30
 */
+ (NSNumber *) dataSource: (NSString *)dataSource execute: (NSString *)sql;
/*!
 @method				dataSource:query:
 @discussion			This method will query with the specified SQL statement.
 @param dataSource		The file name of the database to be used.
 @param sql				The SQL statement to be used.
 @return				The result set.
 @updated				2011-03-30
 */
+ (NSArray *) dataSource: (NSString *)dataSource query: (NSString *)sql;

@end
