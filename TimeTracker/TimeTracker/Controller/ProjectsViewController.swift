import UIKit
import Firebase
import CodableFirebase

class ProjectsViewController: UIViewController {
    @IBOutlet weak var projectsTableView: UITableView!
    
    private let ref = Database.database().reference()
    private var userEmail = Auth.auth().currentUser?.email
    internal let reuseIdentifier = "projectCellIdentifier"
    internal var projects = [Project]()
    private var projectsUID = [String]()
    private var uidSelectedProject: String?
    private var nameSelectedProject: String?
    internal var isPM = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let doteIndex = userEmail?.firstIndex(of: ".") else { return }
        guard let newUserEmail = userEmail?.prefix(upTo: doteIndex) else { return }
        
        userEmail = String(newUserEmail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getProjects()
    }
    
    @IBAction func addProjectTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "projectSegue", sender: nil)
    }
    
    
    @IBAction func unwindToProjectsVC(segue: UIStoryboardSegue) {
        guard let controller = segue.source as? ProjectViewController else {
            return
        }
        
        guard let email = userEmail, let name = controller.nameField.text, let description = controller.descriptionTextView.text else {
            return
        }
        
        let newProject = Project(name: name, description: description)
        
        self.projects.append(newProject)
        self.projectsUID.append(newProject.uid)
        
        guard let projectData = try? FirebaseEncoder().encode(newProject) else { return }
        
        ref.child("users").child(email).child("projects").setValue(self.projectsUID)
        ref.child("projects").child(newProject.uid).setValue(projectData)
        
        projectsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? ProjectTasksViewController else { return }
        
        controller.curUIDProject = uidSelectedProject
        controller.curNameProject = nameSelectedProject
    }
    
    private func getProjects() {
        guard let email = userEmail else {
            return
        }
        
        ref.child("users").child(email).child("isPM").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let value = snapshot.value else { return }
            guard let isPM = try? FirebaseDecoder().decode(Bool.self, from: value) else { return }
            
            self?.isPM = isPM
            
            if isPM {
                self?.ref.child("users").child(email).child("projects").observe(.value) { [weak self] (snapshot1) in
                    guard let value1 = snapshot1.value else { return }
                    guard let projectsUID = try? FirebaseDecoder().decode([String].self, from: value1) else { return }
                
                    self?.projectsUID = projectsUID
                    
                    var projects = [Project]()
                    
                        for projectUID in projectsUID {
                            self?.ref.child("projects").child(projectUID).observe(.value) { [weak self] (snapshot2) in
                                guard let value2 = snapshot2.value else { return }
                            
                                guard let project = try? FirebaseDecoder().decode(Project.self, from: value2) else { return }
                            
                                projects.append(project)
                            
                                if projectUID == self?.projectsUID.last {
                                    self?.projects = projects
                                
                                    self?.projectsTableView.reloadData()
                                }
                            }
                        }
                }
            } else {
                self?.navigationItem.rightBarButtonItem?.isEnabled = false
                self?.navigationItem.rightBarButtonItem?.tintColor = .clear
                
                self?.ref.child("users").child(email).child("myProjects").observe(.value) { [weak self] (snapshot1) in
                    guard let value1 = snapshot1.value else { return }
                    guard let projectsUID = try? FirebaseDecoder().decode([String].self, from: value1) else { return }
                    
                    self?.projectsUID = projectsUID
                    
                    var projects = [Project]()
                    
                        for projectUID in projectsUID {
                            self?.ref.child("projects").child(projectUID).observe(.value) { [weak self] (snapshot2) in
                                guard let value2 = snapshot2.value else { return }
                            
                                guard let project = try? FirebaseDecoder().decode(Project.self, from: value2) else { return }
                            
                                projects.append(project)
                            
                                if projectUID == self?.projectsUID.last {
                                    self?.projects = projects
                                
                                    self?.projectsTableView.reloadData()
                                }
                            }
                        }
                }
            }
        }
    }

}

extension ProjectsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = projects[indexPath.row].name
        cell.detailTextLabel?.text = projects[indexPath.row].description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPM {
            uidSelectedProject = projects[indexPath.row].uid
            nameSelectedProject = projects[indexPath.row].name
        
            performSegue(withIdentifier: "projectTasksSegue", sender: nil)
        }
    }
    
    
}
