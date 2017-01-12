//
//  empDetailTableCell.swift
//  FMDBExampleSwift3


import UIKit

class empDetailTableCell: UITableViewCell {
    @IBOutlet weak var empName: UILabel!
    @IBOutlet weak var empGender: UILabel!
    @IBOutlet weak var empSalary: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
