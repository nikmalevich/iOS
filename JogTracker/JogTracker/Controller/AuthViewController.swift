import UIKit

class AuthViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    
    private let segueIdentifier = "authSegue"
    private var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Unable to log in", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] action in
            self?.loginTextField.text = ""
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        guard let login = loginTextField.text else { return }

        var urlComponents = URLComponents(string: "https://jogtracker.herokuapp.com/api/v1/auth/uuidLogin")
        urlComponents?.queryItems = [
            URLQueryItem(name: "uuid", value: login)
        ]
        
        guard let url = urlComponents?.url else {
            showErrorAlert()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let loginTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            guard response.statusCode >= 200, response.statusCode < 300, let data = data else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            guard let token = try? JSONDecoder().decode(LoginResponse.self, from: data).response.token else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            
            self?.token = token
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            loginTask.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier, let controller = segue.destination as? ContainerViewController else { return }
        
        controller.token = token
    }
    
}
