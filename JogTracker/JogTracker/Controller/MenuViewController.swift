import UIKit

class MenuViewController: UIViewController {
    
    private let menuItems = ["Jogs", "Feedback", "Report"]
    private let reuseCellIdentifier = "menuCellIdentifier"
    var menuItemTapped: ((_ numItem: Int) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menuItemTapped?(indexPath.row)
    }
    
    
}
