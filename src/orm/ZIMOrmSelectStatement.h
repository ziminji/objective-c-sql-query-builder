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
#import "ZIMSqlSelectStatement.h"

/*!
 @class					ZIMOrmSelectStatement
 @discussion			This class will loads the results of found by the query in the specified
						model.
 @updated				2011-05-01
 */
@interface ZIMOrmSelectStatement : NSObject <ZIMSqlStatement> {

	@protected
		Class _model;
		ZIMSqlSelectStatement *_sql;

}
/*!
 @method				initWithDataSource:
 @discussion			This constructor creates an instance of this class with the specified model.
 @param model			The model's class.
 @return				An instance of this class.
 @updated				2012-03-24
 */
- (id) initWithModel: (Class)model;
/*!
 @method				join:
 @discussion			This method will add a join clause to the SQL statement.
 @param table			The table to used in the clause.
 @updated				2012-03-24
 */
- (void) join: (id)table;
/*!
 @method				join:type:
 @discussion			This method will add a join clause to the SQL statement.
 @param table			The table to used in the clause.
 @param type			The type of join clause.
 @updated				2012-03-24
 */
- (void) join: (id)table type: (NSString *)type; // type of JOIN: CROSS, INNER, LEFT, etc.
/*!
 @method				join:alias:
 @discussion			This method will add a join clause to the SQL statement.
 @param table			The table to used in the clause.
 @param alias			The alias to be used.
 @updated				2012-03-24
 */
- (void) join: (id)table alias: (NSString *)alias;
/*!
 @method				join:alias:type:
 @discussion			This method will add a join clause to the SQL statement.
 @param table			The table to used in the clause.
 @param alias			The alias to be used.
 @param type			The type of join clause.
 @updated				2012-03-24
 */
- (void) join: (id)table alias: (NSString *)alias type: (NSString *)type; // type of JOIN: CROSS, INNER, LEFT, etc.
/*!
 @method				joinOn:operator:column:
 @discussion			This method will add a join condition to the last defined join clause.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be tested on.
 @updated				2012-03-24
 */
- (void) joinOn: (id)column1 operator: (NSString *)operator column: (id)column2;
/*!
 @method				joinOn:operator:column:connector:
 @discussion			This method will add a join condition to the last defined join clause.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be tested on.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) joinOn: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector;
/*!
 @method				joinOn:operator:value:
 @discussion			This method will add a join condition to the last defined join clause.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @updated				2012-03-24
 */
- (void) joinOn: (id)column operator: (NSString *)operator value: (id)value;
/*!
 @method				joinOn:operator:value:connector:
 @discussion			This method will add a join condition to the last defined join clause.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) joinOn: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector;
/*!
 @method				joinUsing:
 @discussion			This method will add a join condition to the SQL statement.
 @param column			The column to be used.
 @updated				2011-04-02
 */
- (void) joinUsing: (NSString *)column;
/*!
 @method				whereBlock:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @updated				2011-04-02
 */
- (void) whereBlock: (NSString *)brace;
/*!
 @method				whereBlock:connector:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @param connector		The connector to be used.
 @updated				2011-04-02
 */
- (void) whereBlock: (NSString *)brace connector: (NSString *)connector;
/*!
 @method				where:operator:column:
 @discussion			This method will add a where clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @updated				2012-03-24
 */
- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2;
/*!
 @method				where:operator:column:connector:
 @discussion			This method will add a where clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) where: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector;
/*!
 @method				where:operator:value:
 @discussion			This method will add a where clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @updated				2012-03-24
 */
- (void) where: (id)column operator: (NSString *)operator value: (id)value; // wrap primitives with NSNumber
/*!
 @method				where:operator:value:connector:
 @discussion			This method will add a where clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) where: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector; // wrap primitives with NSNumber
/*!
 @method				groupBy:
 @discussion			This method will add a group by clause to the SQL statement.
 @param column			The column to be grouped.
 @updated				2011-04-02
 */
- (void) groupBy: (NSString *)column;
/*!
 @method				groupByHavingBlock:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @updated				2011-04-02
 */
- (void) groupByHavingBlock: (NSString *)brace;
/*!
 @method				groupByHavingBlock:connector:
 @discussion			This method will start or end a block.
 @param brace			The brace to be used; it is either an opening or closing brace.
 @param connector		The connector to be used.
 @updated				2011-04-02
 */
- (void) groupByHavingBlock: (NSString *)brace connector: (NSString *)connector;
/*!
 @method				groupByHaving:operator:column:
 @discussion			This method will add a having clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @updated				2012-03-24
 */
- (void) groupByHaving: (id)column1 operator: (NSString *)operator column: (id)column2;
/*!
 @method				groupByHaving:operator:column:connector:
 @discussion			This method will add a having clause to the SQL statement.
 @param column1			The column to be tested.
 @param operator		The operator to be used.
 @param column2			The column to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) groupByHaving: (id)column1 operator: (NSString *)operator column: (id)column2 connector: (NSString *)connector;
/*!
 @method				groupByHaving:operator:value:
 @discussion			This method will add a having clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @updated				2012-03-24
 */
- (void) groupByHaving: (id)column operator: (NSString *)operator value: (id)value; // wrap primitives with NSNumber
/*!
 @method				groupByHaving:operator:value:connector:
 @discussion			This method will add a having clause to the SQL statement.
 @param column			The column to be tested.
 @param operator		The operator to be used.
 @param value			The value to be compared.
 @param connector		The connector to be used.
 @updated				2012-03-24
 */
- (void) groupByHaving: (id)column operator: (NSString *)operator value: (id)value connector: (NSString *)connector; // wrap primitives with NSNumber
/*!
 @method				orderBy:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @updated				2012-03-19
 */
- (void) orderBy: (NSString *)column; // ORDER BY [COLUMN] ASC
/*!
 @method				orderBy:descending:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param descending		This will determine whether the column should be ordered in descending order.
 @updated				2012-03-19
 */
- (void) orderBy: (NSString *)column descending: (BOOL)descending; // ORDER BY [COLUMN] [ASC | DESC]
/*!
 @method				orderBy:nulls:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param weight			This indicates how nulls are to be weighed when comparing with non-nulls.
 @updated				2012-03-19
 @see					http://sqlite.org/cvstrac/wiki?p=UnsupportedSql
 @see					https://hibernate.onjira.com/browse/HHH-465
 @see					http://sqlblog.com/blogs/denis_gobo/archive/2007/10/19/3048.aspx
 */
- (void) orderBy: (NSString *)column nulls: (NSString *)weight; // ORDER BY [COLUMN] ASC [NULLS FIRST | NULLS LAST]
/*!
 @method				orderBy:descending:nulls:
 @discussion			This method will add an order by clause to the SQL statement.
 @param column			The column to be ordered.
 @param descending		This will determine whether the column should be ordered in descending order.
 @param weight			This indicates how nulls are to be weighed when comparing with non-nulls.
 @updated				2012-03-19
 @see					http://sqlite.org/cvstrac/wiki?p=UnsupportedSql
 @see					https://hibernate.onjira.com/browse/HHH-465
 @see					http://sqlblog.com/blogs/denis_gobo/archive/2007/10/19/3048.aspx
 */
- (void) orderBy: (NSString *)column descending: (BOOL)descending nulls: (NSString *)weight; // ORDER BY [COLUMN] [ASC | DESC] [NULLS FIRST | NULLS LAST]
/*!
 @method				limit:
 @discussion			This method will add a limit clause to the SQL statement.
 @param limit			The number of records to be returned.
 @updated				2012-03-18
 */
- (void) limit: (NSUInteger)limit;
/*!
 @method				limit:offset:
 @discussion			This method will add a limit clause and an offset clause to the SQL statement.
 @param limit			The number of records to be returned.
 @param offset			The starting point to start evaluating.
 @updated				2012-03-18
 */
- (void) limit: (NSUInteger)limit offset: (NSUInteger)offset;
/*!
 @method				offset:
 @discussion			This method will add an offset clause to the SQL statement.
 @param offset			The starting point to start evaluating.
 @updated				2012-03-18
 */
- (void) offset: (NSUInteger)offset;
/*!
 @method				query
 @discussion			This method will return the SQL statement.
 @return				The SQL statement that was constructed.
 @updated				2011-10-23
 */
- (NSArray *) query;

@end
