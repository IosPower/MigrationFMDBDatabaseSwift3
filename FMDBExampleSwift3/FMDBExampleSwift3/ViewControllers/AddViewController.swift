//


import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtgender: UITextField!
    @IBOutlet weak var txtsalary: UITextField!
    @IBOutlet weak var btnSaveOrUpdate: UIButton!
    
    var  dicData: NSDictionary?
    var empID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dicData != nil{
            txtName.text = dicData?.object(forKey: "emp_Name") as! String?
            txtgender.text = dicData?.object(forKey: "emp_Gender") as! String?
            txtsalary.text = dicData?.object(forKey: "emp_Salary") as! String?
            empID = Int(dicData?["emp_ID"] as! String)
            print(empID)
            
            btnSaveOrUpdate.setTitle("Update", for: UIControlState.normal)
        }
        else{
            btnSaveOrUpdate.setTitle("Save", for: UIControlState.normal)
        }
        txtFieldPadding(textfield:txtsalary)
        txtFieldPadding(textfield:txtName)
        txtFieldPadding(textfield:txtgender)
    }
    
    func txtFieldPadding(textfield: UITextField) {
        let label = UILabel(frame: CGRect(x :0,y :0,width :5,height: 10))
        label.text = " "
        textfield.leftViewMode = .always
        textfield.leftView = label
    }
    
    //MARK:- Button Actions
    @IBAction func btnSave(_ sender: Any) {
        if !(txtName.text?.isEmpty)! && !(txtgender.text?.isEmpty)! && !(txtsalary.text?.isEmpty)! {
            if btnSaveOrUpdate.titleLabel?.text == "Save" {
                saveEmployeeData()
            }
            else{
                updateData()
            }
        }
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Save Data
    func saveEmployeeData(){
        
        var query = ""
        query += "insert into \(TblNameInDB.Employee) (\(ParameterDB.objParamDB.EMP_empName), \(ParameterDB.objParamDB.EMP_empgender), \(ParameterDB.objParamDB.EMP_empsalary)) values('\(txtName.text!)', '\(txtgender.text!)', '\(txtsalary.text!)');"
        
        if DBHelper.shared.execute_Database_Query(query: query as NSString){
            print("inserted")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Or insert Whole Array or dic into DB
        /*
         let dic10 = ["emp_Name":"aamj","emp_Salary":"15000","emp_Gender":"M"]
         let dic11 = ["emp_Name":"bb","emp_Salary":"19000","emp_Gender":"M"]
         let dic12 = ["emp_Name":"cc","emp_Salary":"20000","emp_Gender":"M"]
        
         let array = [dic10]
         let che6 = DBHelper.shared.insertIntoDatabase(tableName: "\(TblNameInDB.Employee)", tableData: array as NSArray)
         if che6 == true {
         print("che6 success")
         }
        */
        
    }
    //MARK:- UpdateData
    func updateData() {
        var query = ""
        
        query += "UPDATE \(TblNameInDB.Employee) SET \(ParameterDB.objParamDB.EMP_empName) = '\(txtName.text!)', \(ParameterDB.objParamDB.EMP_empgender) = '\(txtgender.text!)', \(ParameterDB.objParamDB.EMP_empsalary) = '\(txtsalary.text!)' WHERE \(ParameterDB.objParamDB.EMP_empID) = \(empID!) "
        
        if DBHelper.shared.execute_Database_Query(query: query as NSString){
            print("Updated")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss(animated: true, completion: nil)
            }
        }

        // Or Update Whole Array or dic into DB // pass dic in array
        /*
         let dic = ["emp_Name":"auj","emp_Salary":"444444","emp_Gender":"M"]
         
         let che1 =  DBHelper.shared.updateTableData(tableName: "\(TblNameInDB.Employee)", tableData: [dic] , whereClause: "where \(ParameterDB.objParamDB.EMP_empID) = \(empID!)")
         
         if che1 == true {
         print("che1 success")
         }
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
