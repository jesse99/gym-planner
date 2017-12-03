import UIKit

typealias ToggleCallback = (_ used: [Double]) -> Void

/// Used to select which weights to use from an enumerated list.
class WeightsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func initialize(available: [Double], used: [Double], emptyOK: Bool, _ callback: @escaping ToggleCallback, _ breadcrumb: String, _ unwindTo: String) {
        self.available = available
        self.used = used
        self.emptyOK = emptyOK
        self.callback = callback
        self.breadcrumb = "\(breadcrumb)"
        self.unwindTo = unwindTo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func donePressed(_ sender: Any) {
        callback(used)
        self.performSegue(withIdentifier: unwindTo, sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return available.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let index = (path as NSIndexPath).item
        let weight = available[index]

        let cell = tableView.dequeueReusableCell(withIdentifier: "WeightCellID")!
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
        doneButton.isEnabled = emptyOK || !used.isEmpty
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var doneButton: UIBarButtonItem!

    private var available: [Double]!
    private var used: [Double]!
    private var emptyOK: Bool!
    private var callback: ToggleCallback!
    private var breadcrumb = ""
    private var unwindTo: String!
}





