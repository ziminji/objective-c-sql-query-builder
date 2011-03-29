# Objective-C SQL Query Builder

This repository contains two sets of Objective-C based classes that handle a SQLite database.  The DAO folder contains
a class that easily manages the database connection.  The SQL folder contains a collection of SQL builder classes that
can be used to construct well-formed SQL statements for SQLite via a plethora of convenience methods similar to those
found in LINQ.

All classes are designed to be used in iPhone/iOS applications.

## Motivation

The goal is to make these classes the "de facto" standard for communicating with SQLite databases on iPhone/iOS devices.

After looking at other Objective-C SQLite projects, it was obvious that there was a need for an Objective-C library that
offers more than just a set of SQLite wrapper classes.  It was even more apparent that classes needed to be written very
cleanly and with clear naming conventions similar to those in LINQ.  With the abundance of third-party libraries for
Objective-C, developers are craving libraries that are simple to learn and are intuitive.  Therefore, the classes in this
repository are written with these observations in mind.

## Features

The following is a short-list of some the features:

* Implements a very simple, but powerful, Data Access Object (DAO) that wraps the sqlite3 C based functions.
* Executes an SQL statement with one line of code.
* Has a large collection of SQL builder classes with methods that mimics their SQL equivalent.
* Helps ensure that SQL is well-formed.
* Sanitizes data.
* Handles most complex queries.
* Works with raw SQL.
* Requires only those classes that are needed.  Great for mobile development.
* Classes are easily extendible.

## Getting Started

Using these class in an Xcode project is easy to do.  Here is how:

1. Download the source code via Github as a tarball (i.e. .tar.gz).
2. Navigate to the tarball in Finder.
3. Unachieve the tarball by double-clicking it in a Finder window.
4. Open an Xcode project.
5. Right-click on the "Classes" folder and click on the "Add >> Existing Files..." option.
6. Highlight the files, then click the "Add" button.
7. Check "Copy items into destination group's folder (if needed)".
8. Select "Default" for the "Reference Type".
9. Choose "Recursively create groups for any added folders".
10. Click "Add".

### Required Frameworks

To use these classes in an Xcode project, add the following framework:

* libsqlite3.dylib

### Documentation

All classes are heavily documented with [HeaderDoc](http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1).  You can get familiar with each class by simply opening its respective ".h" file.  You can also
find more information on this repository's Wiki.

### Examples

Checkout this repository's Wiki for a handful of examples.  There, you will find examples on how to build Create, Read,
Update, and Delete (CRUD) statements.

## Reporting Bugs & Making Recommendations

Help debug the Objective-C classes in repository by reporting any bugs.  The more detailed the report the better.  If
you have a bug-fix or a unit-test, please send a message to this repository's inbox.

Likewise, if you would like to make a recommendation on how to improve these classes, take the time to send a message
so that it can be considered for an upcoming release.  Or, if you would like to contribute to the development of this
repository, go ahead and create a fork.

## Future Development

This project is under heavy development.  There are development plans to add:

* More SQL builder classes;
* Object Relational Modeling (ORM) that will utilize both the Data Mapper and Active Record design patterns;
* Unit-tests;
* Documentation generated via [Doxygen](http://www.stack.nl/~dimitri/doxygen/); and,
* Additional tutorials.

## License (Apache v2.0)

Copyright 2011 Ziminji

Licensed under the Apache License, Version 2.0 (the "License"); you may not use these files except in compliance with the
License. You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
