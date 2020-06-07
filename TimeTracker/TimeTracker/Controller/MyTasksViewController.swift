//
//  MyTasksViewController.swift
//  TimeTracker
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class MyTasksViewController: UIViewController {
    @IBOutlet weak var myTasksTableView: UITableView!
    
    private let ref = Database.database().reference()
    private var userEmail = Auth.auth().currentUser?.email
    internal let reuseIdentifier = "myTaskCellIdentifier"
    internal var selectedMyTask: Task?
    internal var notStartedTasks = [Task]()
    internal var performedTasks = [Task]()
    internal var completedTasks = [Task]()
    internal var overdueTasks = [Task]()
    private let sortFunc: ((Task, Task) -> Bool) = { (first, second) -> Bool in
        if first.deadline < Date() {
            return false
        } else if second.deadline < Date() {
            return true
        } else {
            return first.deadline < second.deadline
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let doteIndex = userEmail?.firstIndex(of: ".") else { return }
        guard let newUserEmail = userEmail?.prefix(upTo: doteIndex) else { return }
        
        userEmail = String(newUserEmail)
        
        myTasksTableView.register(UINib(nibName: "MyTaskTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTasks()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? MyTaskViewController else { return }
        
        controller.curMyTask = selectedMyTask
    }
    
    private func getTasks() {
        guard let email = userEmail else { return }
        
        ref.child("users").child(email).child("tasks").observe(.value) { [weak self] (snapshot1) in
            guard let value1 = snapshot1.value else { return }
            
            guard let myTasksUID = try? FirebaseDecoder().decode([String].self, from: value1) else { return }
            
            var notStartedTasks = [Task]()
            var performedTasks = [Task]()
            var completedTasks = [Task]()
            var overdueTasks = [Task]()
            
            for myTaskUID in myTasksUID {
                self?.ref.child("tasks").child(myTaskUID).observe(.value) { [weak self] (snapshot2) in
                    guard let value2 = snapshot2.value else { return }
                    guard let task = try? FirebaseDecoder().decode(Task.self, from: value2) else { return }
                    
                    if task.deadline < Date() {
                        overdueTasks.append(task)
                    } else if task.start == nil {
                        notStartedTasks.append(task)
                    } else if task.finish == nil {
                        performedTasks.append(task)
                    } else {
                        completedTasks.append(task)
                    }
                    
                    if myTaskUID == myTasksUID.last {
                        self?.notStartedTasks = notStartedTasks
                        self?.performedTasks = performedTasks
                        self?.completedTasks = completedTasks
                        self?.overdueTasks = overdueTasks
                        
                        guard let sortFunc = self?.sortFunc else { return }
                        
                        self?.notStartedTasks.sort(by: sortFunc)
                        self?.performedTasks.sort(by: sortFunc)
                        self?.completedTasks.sort(by: sortFunc)
                        self?.overdueTasks.sort(by: sortFunc)
                        
                        self?.myTasksTableView.reloadData()
                    }
                }
            }
        }
    }

}

extension MyTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return notStartedTasks.count
        case 1:
            return performedTasks.count
        case 2:
            return completedTasks.count
        default:
            return overdueTasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        
        switch section {
        case 0:
            label.backgroundColor = .red
            label.text = "Не начаты"
        case 1:
            label.backgroundColor = .yellow
            label.text = "Выполняются"
        case 2:
            label.backgroundColor = .green
            label.text = "Выполнены"
        default:
            label.backgroundColor = .gray
            label.text = "Просрочены"
        }
        
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? MyTaskTableViewCell else { return UITableViewCell() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        var task: Task
        
        if indexPath.section == 0 {
            task = notStartedTasks[indexPath.row]
        } else if indexPath.section == 1 {
            task = performedTasks[indexPath.row]
        } else if indexPath.section == 2 {
            task = completedTasks[indexPath.row]
        } else {
            task = overdueTasks[indexPath.row]
            
            cell.backgroundColor = .darkGray
        }
        
        cell.taskLabel.text = task.name
        cell.projectLabel.text = task.projectName
        cell.deadlineLabel.text = dateFormatter.string(from: task.deadline)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedMyTask = notStartedTasks[indexPath.row]
        } else if indexPath.section == 1 {
            selectedMyTask = performedTasks[indexPath.row]
        } else if indexPath.section == 2 {
            selectedMyTask = completedTasks[indexPath.row]
        } else {
            selectedMyTask = overdueTasks[indexPath.row]
        }
        
        performSegue(withIdentifier: "myTaskSegue", sender: nil)
    }
    
}
