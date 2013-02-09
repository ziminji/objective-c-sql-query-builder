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

#import "ZIMSqlInsertStatement.h"

/*!
 @class					ZIMSqlUpsertStatement
 @discussion			This class represents an SQL upsert statement. Execute as a transaction.
 @updated				2011-11-01
 @see					http://www.sqlite.org/lang_insert.html
 @see					http://www.sqlite.org/lang_update.html
 @see					http://stackoverflow.com/questions/418898/sqlite-upsert-not-insert-or-replace
 @see					http://www.firebirdsql.org/refdocs/langrefupd21-update-or-insert.html
 */
@interface ZIMSqlUpsertStatement : ZIMSqlInsertStatement {

	@protected
		NSMutableSet *_compositeKey;

}
/*!
 @method				matching:
 @discussion			This method will use the specified columns as the (composite) primary key
						or as a unique key to match against.
 @param columns			The columns to be matched.
 @updated				2012-03-17
 */
- (void) matching: (NSArray *)columns;

@end
