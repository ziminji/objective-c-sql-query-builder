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

#import "ZIMSqlTokenizer.h"

@implementation ZIMSqlTokenizer

static NSSet *_keywords = nil;

- (id) initWithSqlStatement: (NSString *)sql {
	if ((self = [super init])) {
		_tuples = [[NSMutableArray alloc] init];

		const char *statement = [sql UTF8String];
		int position = 0;
		int length = strlen(statement) - 1;
		
		char whitespace[] = " \t";
		char eol[] = "\r\n\f";
		char quote[] = "`\"";
		char hexadecimal[] = "0123456789abcdefABCDEF";
		
		while (position <= length) {
			char ch = statement[position];
			if (ch == '|') { // "operator" token
				int lookahead = position + 1;
				if ((lookahead <= length) && (statement[lookahead] == '|')) {
					lookahead++;
					int size = lookahead - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%s", token);
				}
				else {
					char token = ch;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%c", token);
				}
				position = lookahead;
			}
			else if ((ch == '!') || (ch == '=')) { // "operator" token
				int lookahead = position + 1;
				if ((lookahead <= length) && (statement[lookahead] == '=')) {
					lookahead++;
					int size = lookahead - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%s", token);
				}
				else {
					char token = ch;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%c", token);
				}
				position = lookahead;
			}
			else if ((ch == '<') || (ch == '>')) { // "operator" token
				int lookahead = position + 1;
				char next = statement[lookahead];
				if ((next == '=') || (next == ch) || ((next == '>') && (ch == '<'))) {
					lookahead++;
					int size = lookahead - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%s", token);
				}
				else {
					char token = ch;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%c", token);
				}
				position = lookahead;
			}
			else if ((strchr(whitespace, ch) != NULL) || (strchr(eol, ch) != NULL)) { // "whitespace" token
				int start = position;
				char next;
				do {
					position++;
					next = statement[position];
				} while((next != '\0') && ((strchr(whitespace, next) != NULL) || (strchr(eol, next) != NULL)));
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenWhitespace, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else if (ch == '#') { // "whitespace" token (i.e. MySQL-style comment)
				int start = position;
				do {
					position++;
				} while((position < length) && (strchr(eol, statement[position]) == NULL));
				position++;
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenWhitespace, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else if (ch == '-') { // "whitespace" token (i.e. SQL-style comment) or "operator" token
				int lookahead = position + 1;
				if ((lookahead > length) || (statement[lookahead] != '-')) {
					char token = ch;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%c", token);
				}
				else {
					while ((lookahead <= length) && (strchr(eol, statement[lookahead]) == NULL)) {
						lookahead++;
					}
					lookahead++;
					int size = lookahead - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenWhitespace, @"type", nil]];
					//NSLog(@"%s", token);
				}
				position = lookahead;
			}
			else if (ch == '/') { // "whitespace" token (i.e. C-style comment) or "operator" token
				int lookahead = position + 1;
				if ((lookahead > length) || (statement[lookahead] != '*')) {
					char token = ch;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", ZIMSqlTokenOperator, @"type", nil]];
					//NSLog(@"%c", token);
				}			
				else {
					lookahead += 2;
					while ((lookahead <= length) && !((statement[lookahead - 1] == '*') && (statement[lookahead] == '/'))) {
						lookahead++;
					}
					lookahead++;
					int size = MIN(lookahead, length + 1) - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenWhitespace, @"type", nil]];
					//NSLog(@"%s", token);
				}
				position = lookahead;
			}
			else if (ch == '[') { // "identifier" token (Microsoft-style)
				int start = position;
				do {
					position++;
				} while((position < length) && (statement[position] != ']'));
				position++;
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenIdentifier, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else if (strchr(quote, ch) != NULL) { // "identifier" token (SQL-style)
				int start = position;
				do {
					position++;
				} while((position < length) && (statement[position] != ch));
				position++;
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenIdentifier, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else if (ch == '\'') { // "literal" token
				int lookahead = position + 1;
				while (lookahead <= length) {
					if (statement[lookahead] == '\'') {
						if ((lookahead == length) || (statement[lookahead + 1] != '\'')) {
							lookahead++;
							break;
						}
						lookahead++;
					}
					lookahead++;
				}
				int size = lookahead - position;
				char token[size + 1];
				strncpy(token, statement + position, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenLiteral, @"type", nil]];
				position = lookahead;
				//NSLog(@"%s", token);
			}
			else if ((ch >= '0') && (ch <= '9')) { // "integer" token, "real" token, or "hexadecimal" token
				NSString *type;
				int start = position;
				char next;
				if (ch == '0') {
					position++;
					next = statement[position];
					if ((next == 'x') || (next == 'X')) {
						do {
							position++;
							next = statement[position];
						} while (strchr(hexadecimal, next) != NULL);
						type = ZIMSqlTokenHexadecimal;
					}
					else if (next == '.') {
						do {
							position++;
							next = statement[position];
						} while ((next >= '0') && (next <= '9'));
						type = ZIMSqlTokenReal;
					}
					else {
						type = ZIMSqlTokenInteger;
					}
				}
				else {
					do {
						position++;
						next = statement[position];
					} while ((next >= '0') && (next <= '9'));
					if (next == '.') {
						do {
							position++;
							next = statement[position];
						} while ((next >= '0') && (next <= '9'));
						type = ZIMSqlTokenReal;
					}
					else {
						type = ZIMSqlTokenInteger;
					}
				}
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", type, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else if ((ch >= 'x') || (ch >= 'X')) {
				int lookahead = position + 1;
				if (lookahead == '\'') { // "hexadecimal" token
					lookahead++;
					while (lookahead <= length) {
						if (statement[lookahead] == '\'') {
							if ((lookahead == length) || (statement[lookahead + 1] != '\'')) {
								lookahead++;
								break;
							}
							lookahead++;
						}
						lookahead++;
					}
					int size = lookahead - position;
					char token[size + 1];
					strncpy(token, statement + position, size);
					token[size] = '\0';
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenHexadecimal, @"type", nil]]; // TODO validate hexadecimal literal
					position = lookahead;
					//NSLog(@"%s", token);
				}
				else {
					int start = position;
					char next;
					do {
						position++;
						next = statement[position];
					} while((position <= length) && (((next >= 'a') && (next <= 'z')) || ((next >= 'A') && (next <= 'Z')) || (next == '_') || ((next >= '0') && (next <= '9'))));
					int size = position - start;
					char token[size + 1];
					strncpy(token, statement + start, size);
					token[size] = '\0';
					NSString *identifier = [NSString stringWithFormat: @"%s", token];
					NSString *type = ([ZIMSqlTokenizer isKeyword: identifier]) ? ZIMSqlTokenKeyword : ZIMSqlTokenIdentifier;
					[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: identifier, @"token", type, @"type", nil]];
					//NSLog(@"%s", token);
				}
			}
			else if (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || (ch == '_')) { // "keyword" token or "identifier" token
				int start = position;
				char next;
				do {
					position++;
					next = statement[position];
				} while((position <= length) && (((next >= 'a') && (next <= 'z')) || ((next >= 'A') && (next <= 'Z')) || (next == '_') || ((next >= '0') && (next <= '9'))));
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				NSString *identifier = [NSString stringWithFormat: @"%s", token];
				NSString *type = ([ZIMSqlTokenizer isKeyword: identifier]) ? ZIMSqlTokenKeyword : ZIMSqlTokenIdentifier;
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: identifier, @"token", type, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else { // miscellaneous token
				NSString *token = [NSString stringWithFormat: @"%c", ch];
				NSString *type;
				switch (ch) {
					case '+':
					case '*':
					case '%':
					case '&':
					case '~':
						type = ZIMSqlTokenOperator;
						break;
					case '?':
						type = ZIMSqlTokenParameter;
						break;
					case ';':
						type = ZIMSqlTokenTerminal;
						break;
					default:
						type = token;
						break;
				}
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: token, @"token", type, @"type", nil]];
				position++;
				//NSLog(@"%c", token);
			}
		}		
	}
	return self;
}

- (id) objectAtIndex: (NSUInteger)index {
	return [_tuples objectAtIndex: index];
}

- (NSUInteger) count {
	return [_tuples count];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	for (NSDictionary *tuple in _tuples) {
		[sql appendString: [tuple objectForKey: @"token"]];
	}	
	return sql;
}

/*
 * @see http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 * @see http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
 * @see http://stackoverflow.com/questions/7815326/automatic-reference-counting-error-with-fast-enumeration
 */
- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *)state objects: (id __unsafe_unretained *)buffer count: (NSUInteger)bufferSize {
	NSUInteger arrayIndex = (NSUInteger)state->state;
	NSUInteger arraySize = [_tuples count];
	NSUInteger bufferIndex = 0;

	while ((arrayIndex < arraySize) && (bufferIndex < bufferSize)) {
		buffer[bufferIndex] = [_tuples objectAtIndex: arrayIndex];
		arrayIndex++;
		bufferIndex++;
	}

	state->state = (unsigned long)arrayIndex;
	state->itemsPtr = buffer;
	state->mutationsPtr = &state->extra[0];

	return bufferIndex;
}

+ (BOOL) isKeyword: (NSString *)token {
	if (_keywords == nil) {
		_keywords = [NSSet setWithObjects: @"ABORT", @"ABS", @"ACTION", @"ADD", @"AFTER", @"ALL", @"ALTER", @"ANALYZE",
			@"AND", @"AS", @"ASC", @"ATTACH", @"AUTOINCREMENT", @"AVG", @"BEFORE", @"BEGIN", @"BETWEEN", @"BY", @"CASCADE",
			@"CASE", @"CAST", @"CHANGES", @"CHECK", @"COALESCE", @"COLLATE", @"COLUMN", @"COMMIT", @"CONFLICT", @"CONSTRAINT",
			@"COUNT", @"CREATE", @"CROSS", @"CURRENT_DATE", @"CURRENT_TIME", @"CURRENT_TIMESTAMP", @"DATABASE", @"DATE",
			@"DATETIME", @"DEFAULT", @"DEFERRABLE", @"DEFERRED", @"DELETE", @"DESC", @"DETACH", @"DISTINCT", @"DROP", @"EACH",
			@"ELSE", @"END", @"ESCAPE", @"EXCEPT", @"EXCLUSIVE", @"EXISTS", @"EXPLAIN", @"FAIL", @"FOR", @"FOREIGN", @"FROM",
			@"FULL", @"GLOB", @"GROUP", @"GROUP_CONCAT", @"HAVING", @"HEX", @"IF", @"IFNULL", @"IGNORE", @"IMMEDIATE", @"IN",
			@"INDEX", @"INDEXED", @"INITIALLY", @"INNER", @"INSERT", @"INSTEAD", @"INTERSECT", @"INTO", @"IS", @"ISNULL",
			@"JOIN", @"JULIANDAY", @"KEY", @"LAST_INSERT_ROWID", @"LEFT", @"LENGTH", @"LIKE", @"LIMIT", @"LOAD_EXTENSION",
			@"LOWER", @"LTRIM", @"MATCH", @"MAX", @"MIN", @"NATURAL", @"NO", @"NOT", @"NOTNULL", @"NULL", @"NULLIF", @"OF",
			@"OFFSET", @"ON", @"OR", @"ORDER", @"OUTER", @"PLAN", @"PRAGMA", @"PRIMARY", @"QUERY", @"QUOTE", @"RAISE",
			@"RANDOM", @"RANDOMBLOB", @"REFERENCES", @"REGEXP", @"REINDEX", @"RELEASE", @"RENAME", @"REPLACE", @"RESTRICT",
			@"RIGHT", @"ROLLBACK", @"ROUND", @"ROW", @"RTRIM", @"SAVEPOINT", @"SELECT", @"SET", @"SOUNDEX", @"SQLITE_COMPILEOPTION_GET",
			@"SQLITE_COMPILEOPTION_USED", @"SQLITE_SOURCE_ID", @"SQLITE_VERSION", @"STRFTIME", @"SUBSTR", @"SUM", @"TABLE", @"TEMP",
			@"TEMPORARY", @"THEN", @"TIME", @"TO", @"TOTAL", @"TOTAL_CHANGES", @"TRANSACTION", @"TRIGGER", @"TRIM", @"TYPEOF",
			@"UNION", @"UNIQUE", @"UPDATE", @"UPPER", @"USING", @"VACUUM", @"VALUES", @"VIEW", @"VIRTUAL", @"WHEN",
			@"WHERE", @"ZEROBLOB", nil
		];
	}
	return [_keywords containsObject: [token uppercaseString]];
}

@end
