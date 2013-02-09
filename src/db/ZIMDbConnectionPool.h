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

@class ZIMDbConnection;

/*!
 @class					ZIMDbConnectionPool
 @discussion			This class represents an SQLite database connection pool.
 @updated				2011-07-16
 @see					http://sourcemaking.com/design_patterns/object_pool
 @see					http://www.webdevelopersjournal.com/columns/connection_pool.html
 */
@interface ZIMDbConnectionPool : NSObject {

	@protected
		NSMutableDictionary *_connections;

}
/*!
 @method				sharedInstance
 @discussion			This method will return a singleton instance of this class.
 @return				A singleton instance of this class.
 @updated				2011-07-16
 */
+ (ZIMDbConnectionPool *) sharedInstance;
/*!
 @method				connection:
 @discussion			This method will return a connection for the specified data source.
 @param dataSource		The file name of the database's PLIST to be used.
 @return				An open connection for the specified data source.
 @updated				2011-10-19
 */
- (ZIMDbConnection *) connection: (NSString *)dataSource;
/*!
 @method				closeAll
 @discussion			This method will close all open database connections in the pool.
 @updated				2011-07-16
 */
- (void) closeAll;
/*!
 @method				destroyAll
 @discussion			This method will destroy all cached database connections in the pool.
 @updated				2011-07-16
 */
- (void) destoryAll;
/*!
 @method				dealloc
 @discussion			This method will free up any remaining open connections.
 @updated				2013-02-09
 */
- (void) dealloc;

@end
