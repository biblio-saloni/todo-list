//
//  TaskViewController.swift
//  ToDo List
//
//  Created by Incture on 29/07/24.
//

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var task: String?
    var currentPosition: Int!
//    weak var delegate: TaskDeletionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.text = task
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteTask))
    }
    @objc func deleteTask() {
           guard let position = currentPosition else { return }
//           delegate?.diddeleteTask(at: position)
           navigationController?.popViewController(animated: true)
       }
        
}

