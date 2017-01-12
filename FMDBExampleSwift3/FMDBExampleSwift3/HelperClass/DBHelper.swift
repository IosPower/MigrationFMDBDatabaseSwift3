//
//  DBHelper.swift
//  FMDBExampleSwift3


import UIKit

class DBHelper: NSObject {
    
    //Shared Object
    static let shared: DBHelper = DBHelper()
    
    var database: FMDatabase!
    
    var queuefmdb: FMDatabaseQueue! //
    
    var pathToDatabase: String!
    
    let databaseFileName = "database.sqlite"
    
    var DBVersion : Int = 1
    
    //MARK:- Create Database
    func createDatabase() -> Bool {
        var created = false
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        let databaseFile = Bundle.main.path(forResource: "database", ofType: "sqlite")
        
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        
        print(pathToDatabase)
        
        let fm = FileManager.default
        if !fm.fileExists(atPath: pathToDatabase) {
            do {
                try fm.copyItem(atPath: databaseFile!, toPath: pathToDatabase)
                created = true
            } catch  {
                print("not copy")
            }
        }
        
        if FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            queuefmdb = FMDatabaseQueue(path: pathToDatabase)//
            insertFirstTimeDBVersion(database: database)
        }
        
        return created
    }
    
    func insertFirstTimeDBVersion(database: FMDatabase) {
        var DBVersion = -1;
        let array: NSMutableArray = DBHelper.shared.getData_From_Database(query: "SELECT Version FROM \(TblNameInDB.DBVersion)" as NSString)
        print(array)
        
        if array.count > 0 {
            let dic: NSDictionary = array[0] as! NSDictionary
            if let version = Int(dic["Version"] as! String)
            {
                DBVersion = version
            }
        }
        
        if DBVersion < 0 {
            var query = ""
            query += "insert into \(TblNameInDB.DBVersion) ('Id','Version') values(1, 1);"
            if self.execute_Database_Query(query: query as NSString){
                print("Insert DBVersion Query First Time")
            }
        }
    }
    
    //MARK:- Database Version On Application Upgrade
    func updateDatabaseOnApplicationUpgrade() -> Bool {
        var check: Bool = false
        if openDatabase() {
            do {
                print(database)
                var dbVersion = -1;
                let rs = try database.executeQuery("SELECT Version FROM \(TblNameInDB.DBVersion)", values: nil)
                
                while rs.next() {
                    dbVersion = Int(rs.string(forColumnIndex: 0))!
                }
                if dbVersion < self.DBVersion {
                    for version in (dbVersion+1)...self.DBVersion {
                        let sqlFilePath = Bundle.main.path(forResource: "DBVersion_\(version)", ofType: "sql");
                        if FileManager.default.fileExists(atPath: sqlFilePath!) {
                            let sqlFileContent = try String(contentsOfFile: sqlFilePath!, encoding: String.Encoding.utf8)
                            let queryList = sqlFileContent.components(separatedBy: ";\n")
                            for queryNumber in 0..<queryList.count {
                                let sqlQuery = queryList[queryNumber].replacingOccurrences(of: ";", with: "")
                                if (database?.executeStatements(sqlQuery))!
                                {
                                    print("DBVersion.sql query Successfull")
                                }
                            }}}
                    
                    if (database?.executeStatements("Update \(TblNameInDB.DBVersion) set Version = \(self.DBVersion)"))! {
                        check = true
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return check
    }
    
    //MARK:- Open Database
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        if database != nil {
            if database.open() {
                return true
            }
        }
        return false
    }
    
    //MARK:- Insert Array in Database
    func insertIntoDatabase(tableName:String,tableData:NSArray)-> Bool {
        var ans: Bool = false
        var querry : String = ""
        
        for dicArray in tableData {
            let dicData : NSDictionary = dicArray as! NSDictionary
            let index = tableData.index(of: dicArray)
            
            var keys : String = "("
            var values : String = "("
            var countRow : Int = 0
            var strValue : String = ""
            
            for (key, value) in dicData {
                //'
                strValue = self.Remove_Null_From_String(str: value as? NSString) as String
                strValue = strValue.replacingOccurrences(of: "'", with: "''")
                
                if countRow < (dicData.count - 1) {
                    keys += "\(key),"
                    values += "'\(strValue)',"
                }else{
                    keys += "\(key)"
                    values += "'\(strValue)'"
                }
                countRow += 1;
            }
            
            keys += ")"
            values += ")"
            querry += "INSERT OR REPLACE INTO \(tableName) \(keys) values\(values)"
            print(querry)
            
            if tableData.count > 1 && index < tableData.count - 1 {
                querry = querry.appendingFormat("; ")
            }
        }

        if execute_Database_Query(query: querry as NSString) {
            print("Successfully INSERT Data into \(tableName)")
            ans = true
            
        }else{
            print("Could not INSERT data into \(tableName)")
            ans = false
        }

        return ans
    }
    
    //MARK:- Update Array in Database
    func updateTableData(tableName:String,tableData:NSArray,whereClause:String?)-> Bool{
        var ans: Bool = false
        var querry      : String = ""
        for dicArray in tableData {
            let dicData : NSDictionary = dicArray as! NSDictionary
            var countRow    : Int = 0
            var updateValue : String = ""
            
            for (key, value) in dicData {
                let  strValue = self.Remove_Null_From_String(str: value as? NSString) as String
                if countRow < (dicData.count - 1) {
                    if strValue == "" {
                        updateValue += "\(key) = '', "
                    }else{
                        updateValue += "\(key) = '\(strValue)', "
                    }
                }else{
                    if strValue == "" {
                        updateValue += "\(key) = '' "
                    }else{
                        updateValue += "\(key) = '\(strValue)' "
                    }
                }
                countRow += 1;
            }
            
            if whereClause != nil {
                querry += "UPDATE \(tableName) SET \(updateValue) \(whereClause!)"
            }
            else{
                querry += "UPDATE \(tableName) SET \(updateValue)"
            }
            
            let index = tableData.index(of: dicArray)
            
            if tableData.count > 1 && index < tableData.count - 1 {
                querry = querry.appendingFormat("; ")
            }
        }
        print(querry)
        if execute_Database_Query(query: querry as NSString) {
            print("Successfully UPDATE Data into \(tableName)")
            ans = true
        }else{
            print("Could not UPDATE data into \(tableName)")
            ans = false
        }
        return ans
    }
    
    //MARK:- Delete Method
    func deleteWhere(whereClause:NSString, tablename:NSString)-> Bool {
        let sqlQuery : NSString = NSString.init(format: "DELETE FROM %@ WHERE %@", tablename, whereClause)
        if execute_Database_Query(query: sqlQuery) {
            print("Successfully deleted Data into \(tablename)")
            return  true
        }else{
            print("Could not deleted data into \(tablename)")
            return  false
        }
    }
    //Delete All Rows
    func deleteAllRowsForTable(tablename:NSString)-> Bool{
        let sqlQuery : NSString = NSString.init(format: "DELETE FROM %@", tablename)
        if execute_Database_Query(query: sqlQuery) {
            print("Successfully deleted Data into \(tablename)")
            return  true
        }else{
            print("Could not deleted data into \(tablename)")
            return  false
        }
    }
    
    //MARK:- Execute_Database_Query
    func execute_Database_Query(query: NSString) -> Bool {
        var check: Bool = false
        let query = query.replacingOccurrences(of: "'", with: "\'")
        queuefmdb.inDatabase { (db) in
            db?.beginTransaction()
            
            let success: Bool = (db?.executeStatements(query, withResultBlock: { (dictionary: [AnyHashable : Any]?) -> Int32 in
                return 0
            }))!
            
            if success == true{
                print("Success")
                check  = true
            }
            else{
                print("false")
            }
            
            do{
                try db?.executeQuery("VACUUM", values: nil)
            }
            catch{
            }
            
            db?.commit()
            db?.closeOpenResultSets()
        }
        return check
    }
    
    //MARK:- Fetch Data From Database
    func getData_From_Database(query: NSString) -> NSMutableArray {
        let arrayData = NSMutableArray()
        let query = query.replacingOccurrences(of: "'", with: "\'")
        queuefmdb.inDatabase { (db) in
            db?.beginTransaction()
            let success: Bool = (db?.executeStatements(query, withResultBlock: { (dictionary: [AnyHashable : Any]?) -> Int32 in
                if let dic = dictionary{
                    arrayData.add(dic)
                }
                return 0
            }))!
            
            if success == true{
                print("Success")
            }
            else{
                print("false")
            }
            
            do{
                try db?.executeQuery("VACUUM", values: nil)
            }
            catch{
            }
            
            db?.commit()
            db?.closeOpenResultSets()
        }
        return arrayData
    }
        //-------------------***------------------//
    //MARK:- Create Table Programmicaly
    func createTables() -> Bool {
        var createdTables : Bool = false
        if openDatabase(){
            var createEmployeeTableQuery  = ""
            
            createEmployeeTableQuery += "create table \(TblNameInDB.Employee) (\(ParameterDB.objParamDB.EMP_empID) integer primary key autoincrement not null, \(ParameterDB.objParamDB.EMP_empName) text not null, \(ParameterDB.objParamDB.EMP_empgender) text not null, \(ParameterDB.objParamDB.EMP_empsalary) integer not null);"
            
            // you can make multiple table query append here
            
            if !database.executeStatements(createEmployeeTableQuery) {
                print("Failed to Create Tables into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            createdTables = true
        }
        database.close()
        return createdTables
    }
    func Remove_Null_From_String(str: NSString?)-> NSString{
        var strResult: NSString? = nil
        guard let strString = str else {
            return ""
        }
        if strString.length < 0 ||  strString == "(null)" || strString == "<null>"{
            strResult = ""
        }
        else{
            strResult = str
        }
        return strResult!
    }
}
