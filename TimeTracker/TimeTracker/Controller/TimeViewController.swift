import UIKit
import Firebase
import CodableFirebase

class TimeViewController: UIViewController {
    @IBOutlet weak var timeTableView: UITableView!
    
    private let ref = Database.database().reference()
    private var userEmail = Auth.auth().currentUser?.email
    internal let reuseIdentifier = "timeCellIdentifier"
    private var hoursProject = [String : TimeInterval]()
    private var indexProject = [Int : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let doteIndex = userEmail?.firstIndex(of: ".") else { return }
        guard let newUserEmail = userEmail?.prefix(upTo: doteIndex) else { return }
        
        userEmail = String(newUserEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getHours()
    }
    
    func getHours() {
        guard let email = userEmail else { return }
        
        ref.child("users").child(email).child("tasks").observeSingleEvent(of: .value) { [weak self] (snapshot1) in
            guard let value1 = snapshot1.value else { return }
            guard let tasksID = try? FirebaseDecoder().decode([String].self, from: value1) else { return }
            
            var hoursProject = [String : TimeInterval]()
            var indexProject = [Int : String]()
            var index = 0
            
            for taskID in tasksID {
                self?.ref.child("tasks").child(taskID).observeSingleEvent(of: .value) { [weak self] (snapshot2) in
                    guard let value2 = snapshot2.value else {
                        if taskID == tasksID.last {
                            self?.hoursProject = hoursProject
                            self?.indexProject = indexProject
                            
                            self?.timeTableView.reloadData()
                        }
                        
                        return
                    }
                    
                    guard let task = try? FirebaseDecoder().decode(Task.self, from: value2) else {
                        if taskID == tasksID.last {
                            self?.hoursProject = hoursProject
                            self?.indexProject = indexProject
                            
                            self?.timeTableView.reloadData()
                        }
                        
                        return
                    }
                
                    guard let start = task.start, let finish = task.finish else {
                        if taskID == tasksID.last {
                            self?.hoursProject = hoursProject
                            self?.indexProject = indexProject
                            
                            self?.timeTableView.reloadData()
                        }
                        
                        return
                    }
                    
                    let timeInterval = finish.timeIntervalSince1970 - start.timeIntervalSince1970
                    
                    guard let oldHours = hoursProject[task.projectName] else {
                        hoursProject[task.projectName] = timeInterval
                        indexProject[index] = task.projectName
                        
                        if taskID == tasksID.last {
                            self?.hoursProject = hoursProject
                            self?.indexProject = indexProject
                            
                            self?.timeTableView.reloadData()
                        }
                        
                        index += 1
                        
                        return
                    }
                    
                    hoursProject[task.projectName] = oldHours + timeInterval
                    
                    if taskID == tasksID.last {
                        self?.hoursProject = hoursProject
                        self?.indexProject = indexProject

                        self?.timeTableView.reloadData()
                    }
                }
            }
            
            
        }
    }

}

extension TimeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hoursProject.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        guard let projectName = indexProject[indexPath.row] else { return UITableViewCell() }
        guard let projectHours = hoursProject[projectName] else { return UITableViewCell() }
        
        cell.textLabel?.text = projectName
        cell.detailTextLabel?.text = "💰: \(Int(projectHours / 3600))"
        
        return cell
    }
    
    
}
