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

#import "ZIMSqlStatement.h"

#define ZIMSqlTokenError						@"ERROR"
#define ZIMSqlTokenHexadecimal					@"HEXADECIMAL"
#define ZIMSqlTokenIdentifier					@"IDENTIFIER"
#define ZIMSqlTokenInteger						@"NUMBER:INTEGER"
#define ZIMSqlTokenKeyword						@"KEYWORD"
#define ZIMSqlTokenLiteral						@"LITERAL"
#define ZIMSqlTokenOperator						@"OPERATOR"
#define ZIMSqlTokenParameter					@"PARAMETER"
#define ZIMSqlTokenReal							@"NUMBER:REAL"
#define ZIMSqlTokenTerminal						@"TERMINAL"
#define ZIMSqlTokenWhitespace					@"WHITESPACE"

/*!
 @class					ZIMSqlTokenizer
 @discussion			This class tokenizes an SQL statement.
 @updated				2011-11-03
 @see					http://www.opensource.apple.com/source/SQLite/SQLite-74/public_source/src/complete.c
 */
@interface ZIMSqlTokenizer : NSObject <NSFastEnumeration, ZIMSqlStatement> {

	@protected
		NSMutableArray *_tuples;

}
/*!
 @method				initWithSqlStatement:
 @discussion			This method initialize the class with the specified SQL statement.
 @param sql				The SQL statement to be tokenized.
 @return				An instance of this class.
 @updated				2012-03-25
 @see					http://www.sqlite.org/lang_expr.html
 @see					http://dev.mysql.com/doc/refman/5.0/en/hexadecimal-literals.html
 */
- (id) initWithSqlStatement: (NSString *)sql;
/*!
 @method				objectAtIndex:
 @discussion			This method returns the object located at index.
 @param index			An index within the bounds of the array.
 @return				A dictionary representing the tuple.
 @updated				2011-07-13
 */
- (id) objectAtIndex: (NSUInteger)index;
/*!
 @method				count
 @discussion			This method returns the number of objects currently in the array.
 @return				The number of objects currently in the array.
 @updated				2011-07-13
 */
- (NSUInteger) count;
/*!
 @method				statement
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was tokenized.
 @updated				2011-11-03
 */
- (NSString *) statement;
/*!
 @method				isKeyword:
 @discussion			This method returns a boolean indicating whether the token is a reserved keyword
 						according to SQLite 3 standards.
 @param token			The token to be evaluated.
 @return				A boolean value indicating whether the token is a reserved keyword.
 @updated				2011-11-26
 @see					http://www.sqlite.org/lang_keywords.html
 @see					http://www.sqlite.org/lang_corefunc.html
 @see					http://www.sqlite.org/lang_datefunc.html
 @see					http://www.sqlite.org/lang_aggfunc.html
 @see					http://cpan.uwinnipeg.ca/htdocs/SQL-ReservedWords/SQL/ReservedWords/SQLite.pm.html
 */
+ (BOOL) isKeyword: (NSString *)token;

@end
