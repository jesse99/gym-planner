import UIKit

class SinglePlatesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func initialize(_ exercise: Exercise, _ setting: VariableWeightSetting, _ breadcrumb: String) {
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Single Plates"
        
        self.available = availablePlates()
        switch setting.apparatus {
        case .singlePlates(plates: let weights):
            self.used = weights
        default:
            frontend.assert(false, "expected single plates")
            abort()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func donePressed(_ sender: Any) {
        setting.apparatus = .singlePlates(plates: used)
        self.performSegue(withIdentifier: "unwindToVariableWeightID", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return available.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let index = (path as NSIndexPath).item
        let weight = available[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePlatesCellID")!
        cell.textLabel!.text = Weight.friendlyStr(weight)
        cell.accessoryType = used.contains(weight) ? .checkmark : .none
        cell.backgroundColor = tableView.backgroundColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        let index = (path as NSIndexPath).item
        let weight = available[index]
        
        if let i = used.index(of: weight) {
            used.remove(at: i)
        } else {
            used.append(weight)
            used.sort()
        }
        
        tableView.reloadRows(at: [path], with: .fade)
        doneButton.isEnabled = !used.isEmpty
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var doneButton: UIBarButtonItem!
    
    private var setting: VariableWeightSetting!
    private var available: [Double]!
    private var used: [Double]!
    private var breadcrumb = ""
}

