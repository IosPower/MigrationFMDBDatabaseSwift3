# MigrationFMDBDatabaseSwift3
Database Migration using FMDB Database in swift 3


1)  Don’t Forget to create DBversion Table in Database.
      first time insert version number in DBversion Table.

2)   In  DBHelper Class

  var DBVersion : Int = 1 // default first time

  Create empty file and give name DBVersion_2.sql for version 2
  write query in DBVersion_2.sql 
  var DBVersion : Int = 2 // for version 2

  empty file and give name DBVersion_2.sql for version 3
  write query in DBVersion_3.sql 
  var DBVersion : Int = 3 // for version 3 
