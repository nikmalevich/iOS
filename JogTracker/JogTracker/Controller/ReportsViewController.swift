import UIKit

class ReportsViewController: UIViewController {
    @IBOutlet weak var reportsTableView: UITableView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    private let reuseCellIdentifier = "reportCellIdentifier"
    private let dateFormatter = DateFormatter()
    var token: String?
    private var allReports = [ReportWeek]()
    private var visibleReports = [ReportWeek]()
    private var fromIndexReport = 0
    private var toIndexReport = 0
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Unable to load data", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportsTableView.register(UINib(nibName: "ReportTableViewCell", bundle: nil), forCellReuseIdentifier: reuseCellIdentifier)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let url = URL(string: "https://jogtracker.herokuapp.com/api/v1/data/sync"), let token = token else {
            showErrorAlert()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let jogsTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard error == nil, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showErrorAlert()
                }
                
                return
            }
            guard response.statusCode >= 200, response.statusCode < 300, let data = data else {
                DispatchQueue.main.async {
                    self.showErrorAlert()
                }
                
                return
            }
            guard var jogs = try? JSONDecoder().decode(GetJogResponse.self, from: data).response.jogs else {
                DispatchQueue.main.async {
                    self.showErrorAlert()
                }
                
                return
            }
            
            jogs.sort(by: { $0.date <= $1.date })
            
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            var numJog = 0
            var totalTime = 0
            var totalDistance: Double = 0
            
            for (index, jog) in jogs.enumerated() {
                numJog += 1
                totalTime += jog.time
                totalDistance += jog.distance
                
                if index != 0 {
                    let prevDate = Date(timeIntervalSince1970: jogs[index - 1].date)
                    let curDate = Date(timeIntervalSince1970: jog.date)
                    let prevWeek = calendar.component(.weekOfYear, from: prevDate)
                    let curWeek = calendar.component(.weekOfYear, from: curDate)
                    
                    if prevWeek != curWeek {
                        guard let startDate = prevDate.startOfWeek, let endDate = prevDate.endOfWeek else { return }
                        
                        self.allReports.append(ReportWeek(startDate: startDate, endDate: endDate, averageSpeed: totalDistance / Double(totalTime), averageTime: Double(totalTime / numJog), totalDistance: totalDistance))
                    }
                }
            }
            
            self.toIndexReport = self.allReports.count - 1
            self.changeVisibleReports()
            
            DispatchQueue.main.async { [weak self] in
                guard let minDate = self?.allReports[0].startDate, let maxDate = self?.allReports.last?.endDate else { return }
                
                let localeMinDate = Date(timeIntervalSince1970: minDate.timeIntervalSince1970 - 86400)
                let localeMaxDate = Date(timeIntervalSince1970: maxDate.timeIntervalSince1970 - 86400)
                
                self?.reportsTableView.reloadData()
                self?.fromDatePicker.date = localeMinDate
                self?.toDatePicker.date = localeMaxDate
                self?.fromDatePicker.maximumDate = self?.toDatePicker.date
                self?.toDatePicker.minimumDate = self?.fromDatePicker.date
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            jogsTask.resume()
        }
    }
    
    @IBAction func filterDateChanged(_ sender: UIDatePicker) {
        fromDatePicker.maximumDate = toDatePicker.date
        toDatePicker.minimumDate = fromDatePicker.date
        
        let localeFromDate = Date(timeIntervalSince1970: fromDatePicker.date.timeIntervalSince1970 + 86400)
        let localeToDate = Date(timeIntervalSince1970: toDatePicker.date.timeIntervalSince1970 + 86400)
        var newFromIndex = 0
        var newToIndex = allReports.count - 1
        
        for (index, report) in allReports.enumerated() {
            if report.startDate < localeFromDate {
                newFromIndex = index + 1
            }
            
            if report.endDate > localeToDate {
                newToIndex = index - 1
                
                break
            }
        }
        
        fromIndexReport = newFromIndex
        toIndexReport = newToIndex
        
        changeVisibleReports()
    }
    
    private func changeVisibleReports() {
        if fromIndexReport < allReports.count && toIndexReport >= 0 && fromIndexReport <= toIndexReport {
            visibleReports = Array(allReports[fromIndexReport...toIndexReport])
        } else {
            visibleReports = [ReportWeek]()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.reportsTableView.reloadData()
        }
    }
}

extension ReportsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleReports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as? ReportTableViewCell else { return UITableViewCell() }
        
        let report = visibleReports[indexPath.row]
        let localeStartDate = Date(timeIntervalSince1970: report.startDate.timeIntervalSince1970 - 86400)
        let localeEndDate = Date(timeIntervalSince1970: report.endDate.timeIntervalSince1970 - 86400)
        
        cell.weekLabel.text = "Week \(indexPath.row + 1): (\(dateFormatter.string(from: localeStartDate)) / \(dateFormatter.string(from: localeEndDate)))"
        cell.speedLabel.text = "\(round(report.averageSpeed * 10) / 10) km/m"
        cell.timeLabel.text = "\(round(report.averageTime * 10) / 10) min/jog"
        cell.distanceLabel.text = "\(round(report.totalDistance * 10) / 10) km"
        
        return cell
    }
    
    
}
