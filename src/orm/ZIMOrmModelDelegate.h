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
@class ZIMOrmModel;

/*!
 @class					ZIMOrmModelDelegate
 @discussion			This protocol specifies the methods that a delegate of ZIMOrmModel should
						implement.
 @updated				2011-07-31
 */
@protocol ZIMOrmModelDelegate <NSObject>

@optional
/*!
 @method				modelWillBeginDeletingRecord:
 @discussion			This method is called when a model begins deleting a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-07-31
 */
- (void) modelWillBeginDeletingRecord: (ZIMOrmModel *)model;
/*!
 @method				modelDidFinishDeletingRecord:
 @discussion			This method is called when a model finishes deleting a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-07-31
 */
- (void) modelDidFinishDeletingRecord: (ZIMOrmModel *)model;
/*!
 @method				modelWillBeginLoadingRecord:
 @discussion			This method is called when a model begins loading a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-11-02
 */
- (void) modelWillBeginLoadingRecord: (ZIMOrmModel *)model;
/*!
 @method				modelDidFinishLoadingRecord:
 @discussion			This method is called when a model finishes loading a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-11-02
 */
- (void) modelDidFinishLoadingRecord: (ZIMOrmModel *)model;
/*!
 @method				modelWillBeginSavingRecord:
 @discussion			This method is called when a model begins saving a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-07-31
 */
- (void) modelWillBeginSavingRecord: (ZIMOrmModel *)model;
/*!
 @method				modelDidFinishSavingRecord:
 @discussion			This method is called when a model finishes saving a record from the database.
 @param model			The model that is executing the command.
 @updated				2011-07-31
 */
- (void) modelDidFinishSavingRecord: (ZIMOrmModel *)model;

@end
