import UIKit

class ContainerViewController: UIViewController {
    
    private var jogsViewController: JogsViewController?
    private var menuViewController: MenuViewController?
    private var feedbackViewController: FeedbackViewController?
    private var reportsViewController: ReportsViewController?
    var token: String?
    private var isMenuHidden = true
    private var jogsNavigationItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jogsNavigationItem = navigationItem.rightBarButtonItem
        
        guard let jogsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "jogsViewController") as? JogsViewController else { return }
        guard let feedbackVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedbackViewController") as? FeedbackViewController else { return }
        guard let reportsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reportsViewController") as? ReportsViewController else { return }
        
        jogsVC.token = token
        reportsVC.token = token
        jogsViewController = jogsVC
        feedbackViewController = feedbackVC
        reportsViewController = reportsVC
        
        view.addSubview(reportsVC.view)
        view.addSubview(feedbackVC.view)
        view.addSubview(jogsVC.view)
        addChild(reportsVC)
        addChild(feedbackVC)
        addChild(jogsVC)
    }
    
    @IBAction func addNewJogButtonTapped(_ sender: UIBarButtonItem) {
        jogsViewController?.addNewJogButtonTapped()
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Unable to send feedback", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] action in
            self?.feedbackViewController?.textView.text = ""
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showDoneAlert() {
        let alert = UIAlertController(title: "Done", message: "Feedback has been sent", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] action in
            self?.feedbackViewController?.textView.text = ""
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func sendFeedbackButtonTapped() {
        guard let topic = feedbackViewController?.curTopic, let text = feedbackViewController?.textView.text, let token = token else { return }
        
        var urlComponents = URLComponents(string: "https://jogtracker.herokuapp.com/api/v1/feedback/send")
        urlComponents?.queryItems = [
            URLQueryItem(name: "topic_id", value: String(topic)),
            URLQueryItem(name: "text", value: text)
        ]
        
        guard let url = urlComponents?.url else {
            showErrorAlert()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let loginTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            guard response.statusCode >= 200, response.statusCode < 300 else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.showDoneAlert()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            loginTask.resume()
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        feedbackViewController?.textView.endEditing(true)
        
        if menuViewController == nil {
            guard let menuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuViewController") as? MenuViewController else { return }
            
            menuVC.menuItemTapped = { [weak self] (numItem: Int) in
                self?.menuMove(isMenuHidden: self?.isMenuHidden)
                
                guard let jogsVC = self?.jogsViewController else { return }
                guard let feedbackVC = self?.feedbackViewController else { return }
                
                switch numItem {
                case 0:
                    jogsVC.view.isHidden = false
                    self?.navigationItem.title = "Jogs"
                    self?.navigationItem.rightBarButtonItem = self?.jogsNavigationItem
                case 1:
                    jogsVC.view.isHidden = true
                    self?.navigationItem.title = "Feedback"
                    self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: nil, action: #selector(self?.sendFeedbackButtonTapped))
                case 2:
                    jogsVC.view.isHidden = true
                    feedbackVC.view.isHidden = true
                    self?.navigationItem.title = "Report"
                    self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                default:
                    print(1)
                }
            }
            
            menuViewController = menuVC
            
            view.insertSubview(menuVC.view, at: 0)
            addChild(menuVC)
        }
        
        menuMove(isMenuHidden: isMenuHidden)
    }
    
    private func menuMove(isMenuHidden: Bool?) {
        UIView.animate(withDuration: 0.5,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: { [weak self] in
                    guard let jogsVC = self?.jogsViewController else { return }
                    guard let feedbackVC = self?.feedbackViewController else { return }
                    guard let reportsVC = self?.reportsViewController else { return }
                    guard let isMenuHidden = self?.isMenuHidden else { return }
                    
                    if isMenuHidden {
                        jogsVC.view.frame.origin.x = jogsVC.view.frame.width / 3
                        feedbackVC.view.frame.origin.x = feedbackVC.view.frame.width / 3
                        reportsVC.view.frame.origin.x = reportsVC.view.frame.width / 3
                    } else {
                        jogsVC.view.frame.origin.x = 0
                        feedbackVC.view.frame.origin.x = 0
                        reportsVC.view.frame.origin.x = 0
                    }
        }, completion: nil)
        
        self.isMenuHidden = !self.isMenuHidden
    }
    

}
