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

#import "ZIMSqlPreparedStatement.h"
#import "ZIMSqlTokenizer.h"

@implementation ZIMSqlPreparedStatement

- (id) initWithSqlStatement: (NSString *)sql {
	if ((self = [super init])) {
		_tokens = [[NSMutableArray alloc] init];
		_indicies = [[NSMutableArray alloc] init];
		ZIMSqlTokenizer *tokenizer = [[ZIMSqlTokenizer alloc] initWithSqlStatement: sql];
		NSString *lookback = @"";
		for (NSDictionary *tuple in tokenizer) {
			NSString *token = [tuple objectForKey: @"token"];
			NSString *type = [tuple objectForKey: @"type"];
		    if ([type isEqualToString: ZIMSqlTokenKeyword]) {
				[_tokens addObject: [token uppercaseString]];
			}
			else if ([type isEqualToString: ZIMSqlTokenIdentifier]) {
				[_tokens addObject: [ZIMSqlExpression prepareIdentifier: token]];
			}
			else if ([type isEqualToString: ZIMSqlTokenParameter]) {
				[_indicies addObject: [NSNumber numberWithInteger: [_tokens count]]];
				[_tokens addObject: token];
			}
			else if ([type isEqualToString: ZIMSqlTokenWhitespace]) {
				if (![lookback isEqualToString: ZIMSqlTokenWhitespace]) {
					[_tokens addObject: @" "];
				}
			}
			else if ([type isEqualToString: ZIMSqlTokenTerminal]) {
				[_tokens addObject: token];
				lookback = type;
				break;
			}
			else {
				[_tokens addObject: token];
			}
			lookback = type;
		}
		if (![lookback isEqualToString: ZIMSqlTokenTerminal]) {
			[_tokens addObject: @";"];
		}
	}
	return self;
}

- (void) setIdentifier: (id)identifier atIndex: (NSUInteger)index {
	[_tokens replaceObjectAtIndex: [[_indicies objectAtIndex: index] integerValue] withObject: [ZIMSqlExpression prepareIdentifier: identifier]];
}

- (void) setValue: (id)value atIndex: (NSUInteger)index {
	[_tokens replaceObjectAtIndex: [[_indicies objectAtIndex: index] integerValue] withObject: [ZIMSqlExpression prepareValue: value]];
}

- (NSString *) statement {
	NSMutableString *sql = [[NSMutableString alloc] init];
	for (NSString *token in _tokens) {
		[sql appendString: token];
	}
	return sql;
}

+ (NSString *) preparedStatement: (NSString *)sql withValues: (id)values, ... {
	ZIMSqlPreparedStatement *pstmt = [[ZIMSqlPreparedStatement alloc] initWithSqlStatement: sql];

	va_list args;
	va_start(args, values);
	int index = 0;
	for (NSObject *value = values; value != nil; value = va_arg(args, NSObject *)) {
		[pstmt setValue: value atIndex: index];
		index++;
	}
	va_end(args);

	sql = [pstmt statement];

	return sql;
}

@end
