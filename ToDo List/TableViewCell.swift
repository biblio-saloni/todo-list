//
//  TableViewCell.swift
//  ToDo List
//
//  Created by Tanisha on 30/07/24.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var radioButton: UIButton!
    
    @IBOutlet weak var taskData: UITextField!
    
    var isTaskCompleted: Bool = false {
            didSet {
                if isTaskCompleted {
                    taskData.attributedText = NSAttributedString(string: taskData.text ?? "", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
                    radioButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                } else {
                    taskData.attributedText = NSAttributedString(string: taskData.text ?? "", attributes: [:])
                    radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
                }
            }
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        taskData.delegate = self
    }
    func configure(with task: String, isCompleted: Bool) {
            taskData.text = task
            isTaskCompleted = isCompleted
        }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension TableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
        return true
    }
}
