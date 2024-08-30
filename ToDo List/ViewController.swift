//
//  ViewController.swift
//  ToDo List
//
//  Created by Tanisha on 29/07/24.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UITextField!
    @IBOutlet weak var reArrange: UIButton!
    
    var tasks = [String]()
    var completedTasks = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        
        loadTitle()
        
        if !UserDefaults().bool(forKey: "setup"){
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        }
        updateTasks()
    }
    func loadTitle() {
            if let savedTitle = UserDefaults.standard.string(forKey: "title") {
                titleView.text = savedTitle
            }
        }
        
        // Save title to UserDefaults
        func saveTitle(_ title: String) {
            UserDefaults.standard.set(title, forKey: "title")
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == titleView {
                    if let title = textField.text {
                        saveTitle(title)
                    }
                } else if let index = textField.tag as? Int {
                    tasks[index] = textField.text ?? ""
                    UserDefaults().set(tasks[index], forKey: "task_\(index + 1)")
                }
        }
    func updateTasks(){
        tasks.removeAll()
        completedTasks.removeAll()
        
        guard let count = UserDefaults().value(forKey: "count") as? Int else{
            return
        }
        for x in 0..<count{
            if let task = UserDefaults().value(forKey: "task_\(x+1)") as? String {
                tasks.append(task)
                let isCompleted = UserDefaults().bool(forKey: "completed_\(x+1)")
                completedTasks.append(isCompleted)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func rearrangeTapped(_ sender: UIButton) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            reArrange.setTitle("Done", for: .normal)
        } else {
            reArrange.setTitle("", for: .normal)
        }
    }

    func saveTaskCompletionState() {
            for (index, isCompleted) in completedTasks.enumerated() {
                UserDefaults().set(isCompleted, forKey: "completed_\(index+1)")
            }
        }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
            let movedTask = tasks.remove(at: fromIndexPath.row)
            tasks.insert(movedTask, at: to.row)
            
            let movedCompletionState = completedTasks.remove(at: fromIndexPath.row)
            completedTasks.insert(movedCompletionState, at: to.row)
            
            // Update UserDefaults
            for (index, task) in tasks.enumerated() {
                UserDefaults().set(task, forKey: "task_\(index+1)")
                UserDefaults().set(completedTasks[index], forKey: "completed_\(index+1)")
            }
        }
    

    func deleteTask(at position: Int) {
        guard position < tasks.count else { return }
        tasks.remove(at: position)
        completedTasks.remove(at: position)
        
        // Shift tasks in UserDefaults
        for (index, task) in tasks.enumerated() {
                UserDefaults.standard.set(task, forKey: "task_\(index + 1)")
                UserDefaults.standard.set(completedTasks[index], forKey: "completed_\(index + 1)")
                // No timer data here
            }
            
            // Remove any leftover data from UserDefaults
            let count = UserDefaults.standard.integer(forKey: "count")
            for i in tasks.count..<count {
                UserDefaults.standard.removeObject(forKey: "task_\(i + 1)")
                UserDefaults.standard.removeObject(forKey: "completed_\(i + 1)")
                // No timer data here
            }
            
            // Update the count in UserDefaults
            UserDefaults.standard.set(tasks.count, forKey: "count")
            
            // Reload tableView
            tableView.reloadData()
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
            
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
               alert.addTextField { textField in
                   textField.placeholder = ""
               }
               
               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                   if let textField = alert.textFields?.first, let task = textField.text, !task.isEmpty {
                       self?.addTask(task)
                   }
               }))
               
               present(alert, animated: true, completion: nil)
            
        }
    
    func addTask(_ task: String) {
            let count = UserDefaults().integer(forKey: "count") + 1
            UserDefaults().set(count, forKey: "count")
            UserDefaults().set(task, forKey: "task_\(count)")
            UserDefaults().set(false, forKey: "completed_\(count)") // Default to not completed
            
            tasks.append(task)
            completedTasks.append(false)
            tableView.reloadData()
        }
    }

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
                // Trigger the delete function
                self?.deleteTask(at: indexPath.row)
                completionHandler(true)
            }
            
            deleteAction.backgroundColor = .red
        
          let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] (_, _, completionHandler) in
                    guard let taskToShare = self?.tasks[indexPath.row] else {
                        completionHandler(false)
                        return
                    }
                    
                    // Create activity view controller for sharing
                    let activityViewController = UIActivityViewController(activityItems: [taskToShare], applicationActivities: nil)
                    self?.present(activityViewController, animated: true, completion: nil)
                    
                    completionHandler(true)
                }
                shareAction.backgroundColor = .systemBlue
            
            let configuration = UISwipeActionsConfiguration(actions: [shareAction, deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            
            return configuration
        }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.configure(with: tasks[indexPath.row], isCompleted: completedTasks[indexPath.row])
        cell.taskData.tag = indexPath.row
        cell.taskData.delegate = self
        cell.radioButton.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
        cell.radioButton.tag = indexPath.row
        return cell
    
}
    
@objc func radioButtonTapped(_ sender: UIButton) {
       let index = sender.tag
       completedTasks[index].toggle()
       
       saveTaskCompletionState()
       tableView.reloadData()
   }
}

