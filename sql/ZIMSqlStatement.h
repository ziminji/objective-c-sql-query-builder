/*
 * Copyright 2011 Ziminji
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
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

// Block Statement Tokens
#define ZIMSqlBlockOpeningBrace					@"("
#define ZIMSqlBlockClosingBrace					@")"

// Connectors
#define ZIMSqlConnectorAnd						@"AND"
#define ZIMSqlConnectorOr						@"OR"

// Join Types -- http://sqlite.org/syntaxdiagrams.html#join-op
#define ZIMSqlJoinTypeCross						@"CROSS"
#define ZIMSqlJoinTypeInner						@"INNER"
#define ZIMSqlJoinTypeLeft						@"LEFT"
#define ZIMSqlJoinTypeLeftOuter					@"LEFT OUTER"
#define ZIMSqlJoinTypeNatural					@"NATURAL"
#define ZIMSqlJoinTypeNaturalCross				@"NATURAL CROSS"
#define ZIMSqlJoinTypeNaturalInner				@"NATURAL INNER"
#define ZIMSqlJoinTypeNaturalLeft				@"NATURAL LEFT"
#define ZIMSqlJoinTypeNaturalLeftOuter			@"NATURAL LEFT OUTER"
#define ZIMSqlJoinTypeNone						@""

// Expressions -- http://zetcode.com/databases/sqlitetutorial/expressions/
// Arithmetic Operators
#define ZIMSqlOperatorAdd						@"+"
#define ZIMSqlOperatorSubtract					@"-"
#define ZIMSqlOperatorMultiply					@"*"
#define ZIMSqlOperatorDivide					@"/"
#define ZIMSqlOperatorMod						@"%"

// Boolean Operators
#define ZIMSqlOperatorAnd						@"AND"
#define ZIMSqlOperatorOr						@"OR"
#define ZIMSqlOperatorNot						@"NOT"

// Relational Operators
#define ZIMSqlOperatorLessThan					@"<"
#define ZIMSqlOperatorLessThanOrEqualTo			@"<="
#define ZIMSqlOperatorGreaterThan				@">"
#define ZIMSqlOperatorGreaterThanOrEqualTo		@">="
#define ZIMSqlOperatorEqualTo					@"="
#define ZIMSqlOperatorNotEqualTo				@"<>"

// Bitwise Operators
#define ZIMSqlOperatorBitwiseAnd				@"&"
#define ZIMSqlOperatorBitwiseOr					@"|"
#define ZIMSqlOperatorBitwiseShiftLeft			@"<<"
#define ZIMSqlOperatorBitwiseShiftRight			@">>"
#define ZIMSqlOperatorBitwiseNegation			@"~"

// Additional Operator
#define ZIMSqlOperatorConcatenate				@"||"
#define ZIMSqlOperatorIn						@"IN"
#define ZIMSqlOperatorNotIn						@"NOT IN"
#define ZIMSqlOperatorIs						@"IS"
#define ZIMSqlOperatorIsNot						@"IS NOT"
#define ZIMSqlOperatorLike						@"LIKE"
#define ZIMSqlOperatorNotLike					@"NOT LIKE"
#define ZIMSqlOperatorGlob						@"GLOB"
#define ZIMSqlOperatorNotGlob					@"NOT GLOB"
#define ZIMSqlOperatorBetween					@"BETWEEN"
#define ZIMSqlOperatorNotBetween				@"NOT BETWEEN"

// Default Values -- http://forums.realsoftware.com/viewtopic.php?f=3&t=35179
#define ZIMSqlDefaultValueIsAutoIncremented		@"PRIMARY KEY AUTOINCREMENT"
#define ZIMSqlDefaultValueIsNull				@"DEFAULT NULL";
#define ZIMSqlDefaultValueIsNotNull				@"NOT NULL"
#define ZIMSqlDefaultValueIsCurrentDate			@"DEFAULT CURRENT_DATE"
#define ZIMSqlDefaultValueIsCurrentDateTime		@"DEFAULT (datetime('now','localtime'))"
#define ZIMSqlDefaultValueIsCurrentTime			@"DEFAULT CURRENT_TIME"
#define ZIMSqlDefaultValueIsCurrentTimestamp	@"DEFAULT CURRENT_TIMESTAMP"
NSString *ZIMSqlDefaultValue(id value);

// Declared Datetype -- http://www.sqlite.org/datatype3.html
#define ZIMSqlDataTypeBigInt					@"BIGINT"
#define ZIMSqlDataTypeBlob						@"BLOB"
#define ZIMSqlDataTypeBoolean					@"BOOLEAN"
#define ZIMSqlDataTypeClob						@"CLOB"
#define ZIMSqlDataTypeDate						@"DATE"
#define ZIMSqlDataTypeDateTime					@"DATETIME"
#define ZIMSqlDataTypeDouble					@"DOUBLE"
#define ZIMSqlDataTypeDoublePrecision			@"DOUBLE PRECISION"
#define ZIMSqlDataTypeFloat						@"FLOAT"
#define ZIMSqlDataTypeInt						@"INT"
#define ZIMSqlDataTypeInt2						@"INT2"
#define ZIMSqlDataTypeInt8						@"INT8"
#define ZIMSqlDataTypeInteger					@"INTEGER"
#define ZIMSqlDataTypeMediumInt					@"MEDIUMINT"
#define ZIMSqlDataTypeNumeric					@"NUMERIC"
#define ZIMSqlDataTypeReal						@"REAL"
#define ZIMSqlDataTypeSmallInt					@"SMALLINT"
#define ZIMSqlDataTypeText						@"TEXT"
#define ZIMSqlDataTypeTimestamp					@"TIMESTAMP"
#define ZIMSqlDataTypeTinyInt					@"TINYINT"
#define ZIMSqlDataTypeUnsignedBigInt			@"UNSIGNED BIG INT"
#define ZIMSqlDataTypeVariant					@"VARIANT"
NSString *ZIMSqlDataTypeChar(NSInteger x);
NSString *ZIMSqlDataTypeCharacter(NSInteger x);
NSString *ZIMSqlDataTypeDecimal(NSInteger x, NSInteger y);
NSString *ZIMSqlDataTypeNativeCharacter(NSInteger x);
NSString *ZIMSqlDataTypeNChar(NSInteger x);
NSString *ZIMSqlDataTypeNVarChar(NSInteger x);
NSString *ZIMSqlDataTypeVarChar(NSInteger x);
NSString *ZIMSqlDataTypeVaryingCharacter(NSInteger x);

/*!
 @class				ZIMSqlStatement
 @discussion		This class represents an SQL statements.
 @updated			2011-03-26
 @see				http://souptonuts.sourceforge.net/readme_sqlite_tutorial.html
 */
@interface ZIMSqlStatement : NSObject {

}

@end
