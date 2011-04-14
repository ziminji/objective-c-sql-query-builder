# Objective-C SQL Query Builder

This Objective-C based project is divided up into three parts.  The first part consists of a set of Objective-C
classes that handle communications with an SQLite database.  Inside the SRC folder, these Objective-C classes are
further subdivided into three folders.  The DAO folder contains an SQLite wrapper class that easily manages the
database connection.  The SQL folder contains a collection of SQL builder classes that can be used to construct
well-formed SQL statements for SQLite via a plethora of convenience methods similar to those found in LINQ.  And,
the ORM folder contains an assortment of classes that can control and manipulate data within an SQLite database
via the Data Mapper and Active Record design patterns.  The second part consists of an easy-to-use API, which
both documents and diagrams each class.  The third part consists of a BASH script that can be used to generate
the necessary ORM models using the SQLite's database schema.

All classes are designed to be used in iPhone/iOS applications.

## Motivation

The goal of this project is to make these classes the "de facto" standard for communicating with SQLite databases on
iPhone/iOS devices.

After looking at other Objective-C SQLite projects, it was obvious that there was a need for a lightweight Objective-C
library that offers more than just a set of SQLite wrapper classes.  It was even more apparent that classes needed to be
written very cleanly and with clear naming conventions similar to those in LINQ.  With the abundance of third-party
libraries for Objective-C, developers are craving libraries that are simple to learn and are intuitive.  Therefore, the
classes in this repository are written with these observations in mind.

## Features

The following is a short-list of some of the features:

* Implements a very simple, but powerful, Data Access Object (DAO) that wraps the sqlite3 C based functions.
* Automatically places the SQLite database in the "Document" directory.
* Provides multi-threading support in the DAO to deal with asynchronous SQLite calls;
* Executes an SQL statement with one line of code.
* Has a large collection of SQL builder classes with methods that mimic their SQL equivalent.
* Helps ensure that SQL is well-formed.
* Supports all major Objective-C datatypes, including NSNull, NSNumber, NSString, NSData, and NSDate.
* Sanitizes data.
* Handles most complex queries.
* Works with raw SQL.
* Offers Object Relational Mapping (ORM) with composite primary keys.
* Can auto-generate models (i.e. Active Records) for each table in the SQLite database via a BASH script.
* Requires only those classes that are needed.  Great for mobile development.
* Classes are easily extendible.
* Has clear API documentation generated via [Doxygen](http://www.stack.nl/~dimitri/doxygen/).

## Getting Started

Using these classes in an Xcode project is easy to do.  Here is how:

1. Download the source code via Github as a tarball (i.e. .tar.gz).
2. Navigate to the tarball in Finder.
3. Unarchive the tarball by double-clicking it in a Finder window.
4. Open an Xcode project.
5. Right-click on the "Classes" folder and click on the "Add >> Existing Files..." option.
6. Highlight the files, then click the "Add" button.
7. Check "Copy items into destination group's folder (if needed)".
8. Select "Default" for the "Reference Type".
9. Choose "Recursively create groups for any added folders".
10. Click "Add".

### Required Files

A lot of work has gone into making the classes in this repository as independent as possible; however, a few
dependencies just can't be avoided.  To make life easier, the following SDK import files have been created to
make the implementation process as painless as possible:

* ZIMDaoSDK.h
* ZIMSqlSDK.h
* ZIMOrmSDK.h

Based on which SDK is needed, only those classes listed (i.e. imported) in the SDK import file are needed to be
added to the respective Xcode project.

### Required Frameworks

To use these classes in an Xcode project, add the following framework:

* libsqlite3.dylib

### Documentation

All classes are heavily documented using [HeaderDoc](http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1).  You can get familiar with each class by simply looking at the API or by opening its
respective ".h" file.  You can also find more information on this repository's Wiki.

### Tutorials / Examples

Checkout this repository's Wiki for a handful of examples.  There, you will find examples on how to make an SQLite
database connection using the Data Access Object (DAO) and how to build Create, Read, Update, and Delete (CRUD)
statements.

## Reporting Bugs & Making Recommendations

Help debug the Objective-C classes in repository by reporting any bugs.  The more detailed the report the better.  If
you have a bug-fix or a unit-test, please create an issue under the "Issues" tab of this repository and someone will
follow-up with it as soon as possible.

Likewise, if you would like to make a recommendation on how to improve these classes, take the time to send a message
so that it can be considered for an upcoming release.  Or, if you would like to contribute to the development of this
repository, go ahead and create a fork.

You can also email any bug-fixes, unit-tests, or recommendations to oss@ziminji.com.

### Known Issues

Usually, code is not posted to this repository unless it works; however, there are times when some code may get posted
even though it still contains some bugs.  When this occurs, every attempt will be made to list these known bugs in this
README (if they are not already listed under the "Issues" tab).

At the current time, there are no known bugs.  However, the Object Relational Modeling (ORM) is still in development.

### Updates

This project is updated frequently with bug-fixes and new features.  Be sure to add this repository to your watch list
so that you can be notified when such updates are made.

## Future Development

This project is under heavy development.  There are development plans to add:

* A default configuration file for the Data Access Object (DAO);
* More SQL builder classes;
* The ability to handle foreign keys via SQL builder classes and Active Record;
* Lazy loading;
* A module to handle pagination;
* A set of utility classes;
* Unit-tests;
* Additional tutorials and examples.

## License (Apache v2.0)

Copyright 2011 Ziminji

Licensed under the Apache License, Version 2.0 (the "License"); you may not use these files except in compliance with the
License. You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
