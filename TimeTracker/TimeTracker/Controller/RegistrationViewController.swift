import UIKit
import Firebase
import CodableFirebase

class RegistrationViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var isPMSwitch: UISwitch!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var pmLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var isDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        if logInButton.titleLabel?.text == "Войти" {
            repeatPasswordField.isHidden = true
            isPMSwitch.isHidden = true
            pmLabel.isHidden = true
            infoLabel.isHidden = true
            logInButton.setTitle("Зарегистрироваться", for: .normal)
        } else {
            repeatPasswordField.isHidden = false
            isPMSwitch.isHidden = false
            pmLabel.isHidden = false
            infoLabel.isHidden = false
            logInButton.titleLabel?.text = "Войти"
            logInButton.setTitle("Войти", for: .normal)
        }
    }
    
    @IBAction func unwindToRegistrationVC(segue: UIStoryboardSegue) {
        isDone = false
        emailField.text = ""
        passwordField.text = ""
        repeatPasswordField.text = ""
        repeatPasswordField.isHidden = false
        isPMSwitch.isOn = false
        isPMSwitch.isHidden = false
        logInButton.setTitle("Войти", for: .normal)
        pmLabel.isHidden = false
        infoLabel.isHidden = false
    }
    
    
    private func showErrorAlert() {
        isDone = false
        
        let alert = UIAlertController(title: "Ошибка", message: "Данные введены неверно", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] action in
            self?.emailField.text = ""
            self?.passwordField.text = ""
            self?.repeatPasswordField.text = ""
        })
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !isDone else { return true }
        
        isDone = true
        
        guard let email = emailField.text, let password = passwordField.text else {
            showErrorAlert()
            
            return true
        }
        
        if logInButton.titleLabel?.text == "Войти" {
            guard email != "", password != "", password == repeatPasswordField.text, !email.contains("$"), !email.contains("["), !email.contains("]"), !email.contains("#") else {
                showErrorAlert()
                
                return true
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
                guard let self = self else {
                    return
                }
                
                guard result != nil, error == nil else {
                    self.showErrorAlert()
                    
                    return
                }
                    
                let newUser = User(isPM: self.isPMSwitch.isOn)
                let userData = try? FirebaseEncoder().encode(newUser)
                
                guard let doteIndex = email.firstIndex(of: ".") else {
                    self.showErrorAlert()
                    
                    return
                }
            
                let ref = Database.database().reference().child("users")
                ref.child(String(email.prefix(upTo: doteIndex))).setValue(userData)
                
                self.performSegue(withIdentifier: "logInSegue", sender: nil)
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                guard error == nil else {
                    self?.showErrorAlert()
                    
                    return
                }
                
                self?.performSegue(withIdentifier: "logInSegue", sender: nil)
            }
        }
        
        return true
    }
}
