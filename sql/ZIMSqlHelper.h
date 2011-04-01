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

/*!
 @class					ZIMSqlHelper
 @discussion			This class contains a set of methods to help process input.
 @updated				2011-04-01
 */
@interface ZIMSqlHelper : NSObject {

}
/*!
 @method				prepareConnector:
 @discussion			This method will prepare a connector for an SQL statement.
 @param connector		The connector to be prepared.
 @return				The prepared field.
 @updated				2011-04-01
 */
+ (NSString *) prepareConnector: (NSString *)connector;
/*!
 @method				prepareEncloser:
 @discussion			This method will prepare an encloser for an SQL statement.
 @param encloser		The encloser to be prepared.
 @return				The prepared encloser.
 @updated				2011-04-01
 */
+ (NSString *) prepareEncloser: (NSString *)encloser;
/*!
 @method				prepareField:
 @discussion			This method will prepare a field for an SQL statement.
 @param field			The field to be prepared.
 @return				The prepared field.
 @updated				2011-04-01
 */
+ (NSString *) prepareField: (NSString *)field;
/*!
 @method				prepareValue:
 @discussion			This method will prepare a value for an SQL statement.
 @param value			The value to be prepared.
 @return				The prepared value.
 @updated				2011-04-01
 */
+ (NSString *) prepareValue: (id)value;

@end
