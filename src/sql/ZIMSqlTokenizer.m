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

#import "ZIMSqlTokenizer.h"

@implementation ZIMSqlTokenizer

- (id) initWithSqlStatement: (NSString *)sql {
	if (self = [super init]) {
		_tuples = [[NSMutableArray alloc] init];

		const char *statement = [sql UTF8String];
		int position = 0;
		int length = strlen(statement) - 1;
		
		char whitespace[] = " \t";
		char eol[] = "\r\n\f";
		char quote[] = "`\"";
		
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
					while ((lookahead <= length) && (statement[lookahead - 1] != '*') && (statement[lookahead] != '/')) {
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
				int counter = 0;
				while (lookahead <= length) {
					if (statement[lookahead] == '\'') {
						if ((counter % 2) == 0) {
							lookahead++;
							break;
						}
						counter++;
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
						} while ((next >= '0') && (next <= '9'));
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
			else if (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || (ch == '_')) { // "identifier" token
				int start = position;
				do {
					position++;
				} while((position < length) && !(((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || (ch == '_') || ((ch >= '0') && (ch <= '9'))));
				int size = position - start;
				char token[size + 1];
				strncpy(token, statement + start, size);
				token[size] = '\0';
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%s", token], @"token", ZIMSqlTokenIdentifier, @"type", nil]];
				//NSLog(@"%s", token);
			}
			else { // miscellaneous token
				NSString *type;
				char token = ch;
				switch (token) {
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
						type = [NSString stringWithFormat: @"%c", token];
						break;
				}
				[_tuples addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat: @"%c", token], @"token", type, @"type", nil]];
				position++;
				//NSLog(@"%c", token);
			}
		}		
	}
	return self;
}

- (void) dealloc {
	[_tuples release];
	[super dealloc];
}

- (id) objectAtIndex: (NSUInteger)index {
	return [_tuples objectAtIndex: index];
}

- (NSUInteger) count {
	return [_tuples count];
}

/*
 * @see http://cocoawithlove.com/2008/05/implementing-countbyenumeratingwithstat.html
 * @see http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
 */
- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *)state objects: (id *)stackbuf count: (NSUInteger)length {
	NSUInteger currentState = (NSUInteger)state->state;
	NSUInteger arrayCount = [_tuples count];
	NSUInteger batchCount = 0;

	while ((currentState < arrayCount) && (batchCount < length)) {
		stackbuf[batchCount] = [_tuples objectAtIndex: currentState];
		currentState++;
		batchCount++;
	}

	state->state = (unsigned long)currentState;
	state->itemsPtr = stackbuf;
	state->mutationsPtr = (unsigned long *)self;
	
	return batchCount;
}

@end
