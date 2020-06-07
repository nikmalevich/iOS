import UIKit
import Firebase
import CodableFirebase

class ProjectTasksViewController: UIViewController {
    @IBOutlet weak var tasksTableView: UITableView!
    
    internal let reuseIdentifier = "taskCellIdentifier"
    var curUIDProject: String?
    var curNameProject: String?
    private var uidSelectedTask: String?
    private let ref = Database.database().reference()
    private var tasks = [Task]()
    private var tasksUID = [String]()
    internal var notStartedTasks = [Task]()
    internal var performedTasks = [Task]()
    internal var completedTasks = [Task]()
    internal var overdueTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTasks()
    }
    
    @IBAction func addTaskTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "taskSegue", sender: nil)
    }
    
    @IBAction func unwindToProjectTasksVC(segue: UIStoryboardSegue) {
        guard let controller = segue.source as? TaskViewController else { return }
        
        guard let name = controller.nameField.text, let description = controller.descriptionTextView.text, let nameProject = curNameProject, let uidProject = curUIDProject else { return }
        
        let newTask = Task(name: name, description: description, projectName: nameProject, deadline: controller.deadlineDatePicker.date)
        
        self.tasks.append(newTask)
        self.tasksUID.append(newTask.uid)
        self.notStartedTasks.append(newTask)
        
        guard let taskData = try? FirebaseEncoder().encode(newTask) else { return }
        
        ref.child("projects").child(uidProject).child("tasks").setValue(self.tasksUID)
        ref.child("tasks").child(newTask.uid).setValue(taskData)
        
        tasksTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? PerformersViewController else { return }
        
        controller.curUIDTask = uidSelectedTask
        controller.curUIDProject = curUIDProject
    }
    
    private func getTasks() {
        guard let uidProject = curUIDProject else { return }
        
        ref.child("projects").child(uidProject).child("tasks").observe(.value) { [weak self] (snapshot1) in
            guard let value1 = snapshot1.value else { return }
            
            guard let tasksUID = try? FirebaseDecoder().decode([String].self, from: value1) else { return }
            
            self?.tasksUID = tasksUID
            
            var tasks = [Task]()
            var notStartedTasks = [Task]()
            var performedTasks = [Task]()
            var completedTasks = [Task]()
            var overdueTasks = [Task]()
            
            for taskUID in tasksUID {
                self?.ref.child("tasks").child(taskUID).observe(.value) { [weak self] (snapshot2) in
                    guard let value2 = snapshot2.value else { return }
                    
                    guard let task = try? FirebaseDecoder().decode(Task.self, from: value2) else { return }
                    
                    tasks.append(task)
                    
                    if task.deadline < Date() {
                        overdueTasks.append(task)
                    } else if task.start == nil {
                        notStartedTasks.append(task)
                    } else if task.finish == nil {
                        performedTasks.append(task)
                    } else {
                        completedTasks.append(task)
                    }
                    
                    if taskUID == tasksUID.last {
                        self?.tasks = tasks
                        self?.notStartedTasks = notStartedTasks
                        self?.performedTasks = performedTasks
                        self?.completedTasks = completedTasks
                        self?.overdueTasks = overdueTasks
                        
                        self?.tasksTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension ProjectTasksViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        var task: Task
        
        cell.startDateLabel.isHidden = true
        cell.startLabel.isHidden = true
        cell.finishLabel.isHidden = true
        cell.finishDateLabel.isHidden = true
        
        if indexPath.section == 0 {
            task = notStartedTasks[indexPath.row]
        } else if indexPath.section == 1 {
            task = performedTasks[indexPath.row]
            
            guard let start = task.start else { return UITableViewCell() }
            
            cell.startLabel.isHidden = false
            cell.startDateLabel.isHidden = false
            cell.startDateLabel.text = dateFormatter.string(from: start)
        } else if indexPath.section == 2 {
            task = completedTasks[indexPath.row]
            
            guard let start = task.start else { return UITableViewCell() }
            guard let finish = task.finish else { return UITableViewCell() }
            
            cell.startLabel.isHidden = false
            cell.startDateLabel.isHidden = false
            cell.startDateLabel.text = dateFormatter.string(from: start)
            cell.finishLabel.isHidden = false
            cell.finishDateLabel.isHidden = false
            cell.finishDateLabel.text = dateFormatter.string(from: finish)
        } else {
            task = overdueTasks[indexPath.row]
            
            cell.backgroundColor = .darkGray
        }
        
        cell.nameLabel.text = task.name
        cell.descriptionLabel.text = task.description
        cell.deadlineLabel.text = dateFormatter.string(from: task.deadline)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            uidSelectedTask = notStartedTasks[indexPath.row].uid
        } else if indexPath.section == 1 {
            uidSelectedTask = performedTasks[indexPath.row].uid
        } else if indexPath.section == 2 {
            uidSelectedTask = completedTasks[indexPath.row].uid
        } else {
            return
        }
        
        performSegue(withIdentifier: "taskPerformsSegue", sender: nil)
    }
}
