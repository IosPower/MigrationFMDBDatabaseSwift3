//
//  ParameterDB.swift
//  FMDBExampleSwift3
//
import UIKit

class ParameterDB: NSObject {
    static let objParamDB : ParameterDB = ParameterDB()
    /// Table Employee Parameters
    let EMP_empID  = "emp_ID"
    let EMP_empName  = "emp_Name"
    let EMP_empgender  = "emp_gender"
    let EMP_empsalary  = "emp_salary"
    
    /// Table DBVersion Parameters
    let DB_Id  = "Id"
    let DB_Version  = "Version"
}

enum TblNameInDB: String {
    case Employee = "Employee"
    case DBVersion = "DBVersion"
}
