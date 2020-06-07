import UIKit

class JogsViewController: UIViewController {
    @IBOutlet weak var jogsTableView: UITableView!
    
    var token: String?
    private var jogs = [GetJog]()
    private let reuseCellIdentifier = "jogCellIdetifier"
    private let segueIdentifier = "jogSegue"
    private let dateFormatter  = DateFormatter()
    private var curJog: GetJog?
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Unable to load data", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        jogsTableView.register(UINib(nibName: "JogTableViewCell", bundle: nil), forCellReuseIdentifier: reuseCellIdentifier)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let url = URL(string: "https://jogtracker.herokuapp.com/api/v1/data/sync"), let token = token else {
            showErrorAlert()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let jogsTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
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
            guard let jogs = try? JSONDecoder().decode(GetJogResponse.self, from: data).response.jogs else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            
            self?.jogs = jogs
            
            DispatchQueue.main.async { [weak self] in
                self?.jogsTableView.reloadData()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            jogsTask.resume()
        }
    }
    
    func addNewJogButtonTapped() {
        curJog = nil
        
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    @IBAction func unwindToJogsVC(segue: UIStoryboardSegue) {
        guard let controller = segue.source as? JogViewController else { return }
        guard let distanceString = controller.distanceTextField.text, let timeString = controller.timeTextField.text, let token = token else { return }
        
        let date = controller.datePicker.date
        
        guard let editJog = controller.jog else {
            var urlComponents = URLComponents(string: "https://jogtracker.herokuapp.com/api/v1/data/jog")
            urlComponents?.queryItems = [
                URLQueryItem(name: "date", value: dateFormatter.string(from: date)),
                URLQueryItem(name: "distance", value: distanceString),
                URLQueryItem(name: "time", value: timeString)
            ]

            guard let url = urlComponents?.url else {
                showErrorAlert()
                
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let newJogTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
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
                guard let newJog = try? JSONDecoder().decode(PostJogResponse.self, from: data).response else {
                    DispatchQueue.main.async {
                        self?.showErrorAlert()
                    }
                    
                    return
                }
                
                let jog = GetJog(postJog: newJog)
                
                self?.jogs.insert(jog, at: 0)
                
                let indexPath = IndexPath(row: 0, section: 0)
                
                DispatchQueue.main.async { [weak self] in
                    self?.jogsTableView.beginUpdates()
                    self?.jogsTableView.insertRows(at: [indexPath], with: .automatic)
                    self?.jogsTableView.endUpdates()
                }
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                newJogTask.resume()
            }
            
            return
        }
        
        var urlComponents = URLComponents(string: "https://jogtracker.herokuapp.com/api/v1/data/jog")
        urlComponents?.queryItems = [
            URLQueryItem(name: "date", value: dateFormatter.string(from: date)),
            URLQueryItem(name: "distance", value: distanceString),
            URLQueryItem(name: "time", value: timeString),
            URLQueryItem(name: "jog_id", value: String(editJog.id)),
            URLQueryItem(name: "user_id", value: String(editJog.userID))
        ]

        guard let url = urlComponents?.url else {
            showErrorAlert()
            
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")

        let editJogTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
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
            guard let newJog = try? JSONDecoder().decode(PostJogResponse.self, from: data).response, let index = self?.jogs.firstIndex(of: editJog) else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
                
                return
            }
            
            let jog = GetJog(postJog: newJog)

            self?.jogs[index] = jog

            let indexPath = IndexPath(row: index, section: 0)

            DispatchQueue.main.async { [weak self] in
                self?.jogsTableView.beginUpdates()
                self?.jogsTableView.reloadRows(at: [indexPath], with: .automatic)
                self?.jogsTableView.endUpdates()
            }
        }

        DispatchQueue.global(qos: .userInteractive).async {
            editJogTask.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? JogViewController else { return }
        
        controller.jog = curJog
    }
}

extension JogsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = jogsTableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as? JogTableViewCell else { return UITableViewCell() }
        
        let jog = jogs[indexPath.row]
        
        cell.dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: jog.date))
        cell.distanceLabel.text = "\(jog.distance) km"
        cell.timeLabel.text = "\(jog.time) min"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curJog = jogs[indexPath.row]
        
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}
