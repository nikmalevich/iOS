//
//  MyTaskViewController.swift
//  TimeTracker
//
//  Created by Admin on 20/05/2020.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class MyTaskViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var curMyTask: Task?
    private var timer: Timer?
    private let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = curMyTask?.name
        descriptionLabel.text = curMyTask?.description
        
        switch curMyTask?.status {
        case .notStarted:
            statusLabel.text = "Уже пора начинать!🛌"
        case .performed:
            statusLabel.text = "Идет работа!👨🏼‍💻"
        case .completed:
            statusLabel.text = "Выполнено!✔️"
        case .none:
            statusLabel.text = ""
        }
        
        guard let start = curMyTask?.start else {
            timeLabel.isHidden = true
            actionButton.setTitle("Начать", for: .normal)
            
            return
        }
        
        guard let finish = curMyTask?.finish else {
            startTimer(start: start)
            
            return
        }
        
        stopTimer(start: start, finish: finish)
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        guard let task = curMyTask else { return }
        
        var newTask: Task
        
        if sender.titleLabel?.text == "Начать" {
            newTask = Task(uid: task.uid, name: task.name, description: task.description, projectName: task.projectName, status: .performed, deadline: task.deadline, start: Date())
            
            guard let start = newTask.start else { return }
            
            startTimer(start: start)
        } else {
            newTask = Task(uid: task.uid, name: task.name, description: task.description, projectName: task.projectName, status: .completed, deadline: task.deadline, start: task.start!, finish: Date())
            
            guard let start = newTask.start, let finish = newTask.finish else { return }
            
            stopTimer(start: start, finish: finish)
        }
        
        curMyTask = newTask
        
        guard let taskData = try? FirebaseEncoder().encode(newTask) else { return }
        
        ref.child("tasks").child(task.uid).setValue(taskData)
    }
    
    private func startTimer(start: Date) {
        statusLabel.text = "Идет работа!👨🏼‍💻"
        timeLabel.isHidden = false
        actionButton.setTitle("Закончить", for: .normal)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            let minutes = Int((Date().timeIntervalSince1970 - start.timeIntervalSince1970) / 60)
            
            self?.setTime(minutes)
        }
    }
    
    private func stopTimer(start: Date, finish: Date) {
        timer?.invalidate()
        timer = nil
        
        statusLabel.text = "Выполнено!✔️"
        timeLabel.isHidden = false
        actionButton.isHidden = true
        
        let minutes = Int((finish.timeIntervalSince1970 - start.timeIntervalSince1970) / 60)
        
        setTime(minutes)
    }
    
    private func setTime(_ minutes: Int) {
        let hours = Int(minutes / 60)
        let clockMinutes = minutes % 60
        
        if hours < 10 && clockMinutes < 10 {
            timeLabel.text = "⏱0\(hours):0\(clockMinutes)"
        } else if hours < 10 {
            timeLabel.text = "⏱0\(hours):\(clockMinutes)"
        } else if clockMinutes < 10 {
            timeLabel.text = "⏱\(hours):0\(clockMinutes)"
        } else {
            timeLabel.text = "⏱\(hours):\(clockMinutes)"
        }
    }
    
}
