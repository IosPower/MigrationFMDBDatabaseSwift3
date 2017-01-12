//
//  ViewController.swift
//  FMDBExampleSwift3
//

import UIKit

class ViewController: UIViewController {
    
    var cellObj : empDetailTableCell = empDetailTableCell()
    
    var database: FMDatabase!
    
    var arrayEmp: NSArray = NSArray()
    
    @IBOutlet weak var tblEmpDetail: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblEmpDetail.estimatedRowHeight = 110.0
        tblEmpDetail.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchDetailFromDB()
    }
    
    func fetchDetailFromDB() {
        let array: NSMutableArray = DBHelper.shared.getData_From_Database(query: "select * from \(TblNameInDB.Employee)" as NSString)
        print(array)
        arrayEmp = array.mutableCopy() as! NSArray
        tblEmpDetail.reloadData()
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController
        self.present(addViewController!, animated: true, completion: nil)
    }
    
    func deleteData(dic: NSDictionary) {
        let id = dic.object(forKey: "emp_ID")
        var query = ""
        query += "DELETE from \(TblNameInDB.Employee) WHERE \(ParameterDB.objParamDB.EMP_empID) = \(id!) "
        if DBHelper.shared.execute_Database_Query(query: query as NSString){
            print("Deleted")
        }
        
        // Delete with query
        /*
         let check = DBHelper.shared.deleteWhere(whereClause: "\(ParameterDB.objParamDB.EMP_empID) = \(id!)" as NSString , tablename: "\(TblNameInDB.Employee)")
         if check == true {
         print("check success")
         }
         */
        
        fetchDetailFromDB()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- UITableViewDataSource Methods
extension ViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayEmp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellObj = tblEmpDetail.dequeueReusableCell(withIdentifier: "cell") as! empDetailTableCell
        if let dicData: NSDictionary = arrayEmp[indexPath.row] as? NSDictionary{
            cellObj.empName.text = dicData.object(forKey: "emp_Name") as! String?
            cellObj.empGender.text = dicData.object(forKey: "emp_Gender") as! String?
            cellObj.empSalary.text = dicData.object(forKey: "emp_Salary") as! String?
        }
        return cellObj
    }
}
//MARK:- UITableViewDelegate Methods
extension ViewController: UITableViewDelegate, UIGestureRecognizerDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController
        if let dicData: NSDictionary = arrayEmp[indexPath.row] as? NSDictionary{
            addViewController?.dicData = dicData
        }
        self.present(addViewController!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            print(indexPath.row)
            if let dicData: NSDictionary = arrayEmp[indexPath.row] as? NSDictionary{
                deleteData(dic: dicData)
            }
        }
    }
}
