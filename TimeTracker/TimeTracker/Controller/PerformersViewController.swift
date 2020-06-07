import UIKit
import Firebase
import CodableFirebase

class PerformersViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    var curUIDProject: String?
    var curUIDTask: String?
    private let ref = Database.database().reference()
    private var userTasksUID = [String]()
    private var userProjectsUID = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func appointButtonTapped(_ sender: UIButton) {
        guard var email = emailField.text else { return }
        guard let doteIndex = email.firstIndex(of: ".") else { return }
        
        email = String(email.prefix(upTo: doteIndex))
        
        guard email != "", !email.contains("$"), !email.contains("["), !email.contains("]"), !email.contains("#") else { return }
        
        getUserTasksUID(email: email)
        getUserProjectsUID(email: email)
        
        showDoneAlert(email: email)
    }
    
    private func getUserTasksUID(email: String) {
        var isFirst = false
        
        ref.child("users").child(email).child("tasks").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let value = snapshot.value else { return }
            
            guard let tasksUID = try? FirebaseDecoder().decode([String].self, from: value) else {
                isFirst = true
                
                return
            }
            
            self?.userTasksUID = tasksUID
        }
        
        while isFirst || !self.userTasksUID.isEmpty {}
    }
    
    private func getUserProjectsUID(email: String) {
        var isFirst = false
        
        ref.child("users").child(email).child("myProjects").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let value = snapshot.value else { return }
            
            guard let projectsUID = try? FirebaseDecoder().decode([String].self, from: value) else {
                isFirst = true
                
                return
            }
            
            self?.userProjectsUID = projectsUID
        }
        
        while isFirst || !self.userProjectsUID.isEmpty {}
    }
    
    private func showDoneAlert(email: String) {
        let alert = UIAlertController(title: "Подтверждение", message: "Вы уверены, что хотите назначить?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Подтверждаю", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            guard let uidTask = self.curUIDTask, let uidProject = self.curUIDProject else { return }
            
            if !self.userTasksUID.contains(uidTask) {
                self.userTasksUID.append(uidTask)
            }
            
            if !self.userProjectsUID.contains(uidProject) {
                self.userProjectsUID.append(uidProject)
            }
            
            let userTasksUIDData = try? FirebaseEncoder().encode(self.userTasksUID)
            let userProjectsUIDData = try? FirebaseEncoder().encode(self.userProjectsUID)
            
            self.ref.child("users").child(email).child("tasks").setValue(userTasksUIDData)
            self.ref.child("users").child(email).child("myProjects").setValue(userProjectsUIDData)
        })
        
        present(alert, animated: true, completion: nil)
    }
}
