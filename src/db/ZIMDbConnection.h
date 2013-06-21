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

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Requires libsqlite3.dylib

/*!
 @class					ZIMDbConnection
 @discussion			This class represents an SQLite database connection.
 @updated				2012-03-23
 */
@interface ZIMDbConnection : NSObject {

	@protected
		NSString *_dataSource;
		BOOL _readonly;
		NSMutableSet *_privileges;
		NSLock *_mutex;
		sqlite3 *_database;
		BOOL _isConnected;

}
/*!
 @method				initWithDictionary:withMultithreadingSupport:
 @discussion			This constructor creates an instance of this class with the specified data source configuration passed as a dictionary,
 and will attempt to open a database connection.  If the data source does not already
 exist in the working directoy, an attempt will be made to copy the data source from
 the resource directory to the working directory; otherwise, the data source will be
 created in the working directory.
 @param dictionary		The config of the dataSource (as in the PLIST).
 @param multithreading	This determines whether locks should be used.
 @return				An instance of this class.
 @updated				2013-06-15
 */
- (id) initWithDictionary: (NSString *)dictionary withMultithreadingSupport: (BOOL)multithreading;
/*!
 @method				initWithDataSource:withMultithreadingSupport:
 @discussion			This constructor creates an instance of this class with the specified data source
						and will attempt to open a database connection.  If the data source does not already
						exist in the working directoy, an attempt will be made to copy the data source from
						the resource directory to the working directory; otherwise, the data source will be
						created in the working directory.
 @param dataSource		The file name of the database's PLIST to be used.
 @param multithreading	This determines whether locks should be used.
 @return				An instance of this class.
 @updated				2012-03-23
 */
- (id) initWithDataSource: (NSString *)dataSource withMultithreadingSupport: (BOOL)multithreading;
/*!
 @method				initWithDataSource:
 @discussion			This constructor creates an instance of this class with the specified data source
                        and will attempt to open a database connection.  If the data source does not already
                        exist in the working directoy, an attempt will be made to copy the data source from
                        the resource directory to the working directory; otherwise, the data source will be
                        created in the working directory.
 @param dataSource		The file name of the database's PLIST to be used.
 @return				An instance of this class.
 @updated				2011-07-16
 */
- (id) initWithDataSource: (NSString *)dataSource;
/*!
 @method				open
 @discussion			This method will open a connection to the database.
 @updated				2011-07-16
 */
- (void) open;
/*!
 @method				beginTransaction
 @discussion			This method will begin a transaction.
 @return				Whether the transaction has been started.
 @updated				2011-06-23
 @see					http://www.sqlite.org/lang_transaction.html
 */
- (NSNumber *) beginTransaction;
/*!
 @method				execute:
 @discussion			This method will execute the specified SQL statement. (Note: It is
						possible to execute multiple SQL statements via this method.)
 @param sql				The SQL statement to be used.
 @return				Either the last insert row id or TRUE.
 @updated				2012-03-23
 @see					http://www.sqlite.org/c3ref/last_insert_rowid.html
 @see					http://code.google.com/p/sqlite-manager/issues/detail?id=34
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
 @param model			The class to used to map each record.  The class only needs to have
						accessible instance variables and does not necessarily have to conform
						to the Active Record design pattern.
 @return				The result set (i.e. an array of records).
 @updated				2011-10-19
 */
- (NSArray *) query: (NSString *)sql asObject: (Class)model;
/*!
 @method				rollbackTransaction
 @discussion			This method will rollback a transaction.
 @return				Whether the transaction was rollbacked.
 @updated				2011-07-16
 @see					http://www.sqlite.org/lang_transaction.html
 */
- (NSNumber *) rollbackTransaction;
/*!
 @method				commitTransaction
 @discussion			This method will commit a transaction.
 @return				Whether the transaction has been committed.
 @updated				2011-07-16
 @see					http://www.sqlite.org/lang_transaction.html
 */
- (NSNumber *) commitTransaction;
/*!
 @method				vacuum
 @discussion			The method will rebuild the entire database.
 @return				Whether the command was successfully executed.
 @updated				2011-06-30
 @see					http://www.sqlite.org/lang_vacuum.html
 */
- (NSNumber *) vacuum;
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
 @updated				2011-07-16
 */
- (void) close;
/*!
 @method				dealloc
 @discussion			This method will free up the connection should it still remain open.
 @updated				2013-02-09
 */
- (void) dealloc;
/*!
 @method				dataSource:execute:
 @discussion			This method will execute the specified SQL statement.
 @param dataSource		The file name of the database to be used.
 @param sql				The SQL statement to be used.
 @return				Either the last insert row id or TRUE.
 @updated				2011-10-23
 @see					http://www.sqlite.org/c3ref/last_insert_rowid.html
 */
+ (NSNumber *) dataSource: (NSString *)dataSource execute: (NSString *)sql;
/*!
 @method				dataSource:query:
 @discussion			This method will query with the specified SQL statement.
 @param dataSource		The file name of the database to be used.
 @param sql				The SQL statement to be used.
 @return				The result set.
 @updated				2011-10-23
 */
+ (NSArray *) dataSource: (NSString *)dataSource query: (NSString *)sql;
/*!
 @method				dataSource:query:
 @discussion			This method will query with the specified SQL statement.
 @param dataSource		The file name of the database to be used.
 @param sql				The SQL statement to be used.
 @param model			The class to used to map each record.  The class only needs to have
						accessible instance variables and does not necessarily have to conform
						to the Active Record design pattern.
 @return				The result set.
 @updated				2011-10-23
 */
+ (NSArray *) dataSource: (NSString *)dataSource query: (NSString *)sql asObject: (Class)model;

@end
