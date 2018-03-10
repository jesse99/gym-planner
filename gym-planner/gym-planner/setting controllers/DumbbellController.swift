import UIKit

class DumbbellController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func initialize(_ exercise: Exercise, _ setting: VariableWeightSetting, _ breadcrumb: String) {
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Dumbbell"

        self.available = defaultDumbbells()
        switch setting.apparatus {
        case .dumbbells1(weights: let weights, magnets: _):
            self.used = weights
        case .dumbbells2(weights: let weights, magnets: _):
            self.used = weights
        default:
            frontend.assert(false, "expected a dumbbell")
            abort()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func unwindToDumbbell(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func donePressed(_ sender: Any) {
        switch setting.apparatus {
        case .dumbbells1(weights: _, magnets: let oldMagnets):
            setting.apparatus = .dumbbells1(weights: used, magnets: oldMagnets)
            
        case .dumbbells2(weights: _, magnets: let oldMagnets):
            setting.apparatus = .dumbbells2(weights: used, magnets: oldMagnets)
        default:
            frontend.assert(false, "DumbbellController was called without a dumbbell")
            abort()
        }

        self.performSegue(withIdentifier: "unwindToVariableWeightID", sender: self)
    }
    
    @IBAction func magnetsPressed(_ sender: Any) {
        var usedMagnets: [Double]
        switch setting.apparatus {
        case .dumbbells1(weights: _, magnets: let magnets):
            usedMagnets = magnets

        case .dumbbells2(weights: _, magnets: let magnets):
            usedMagnets = magnets

        default:
            frontend.assert(false, "DumbbellController was called without a dumbbell")
            abort()
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "WeightsID") as! WeightsController
        view.initialize(
            available: availableMagnets(),
            used: usedMagnets,
            emptyOK: true,
            {self.updateMagnets($0)},
            breadcrumbLabel.text! + " • Magnets",
            "unwindToDumbbellID")
        present(view, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return available.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let index = (path as NSIndexPath).item
        let weight = available[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DumbbellCellID")!
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
    
    private func updateMagnets(_ newMagnets: [Double]) {
        switch setting.apparatus {
        case .dumbbells1(weights: let oldWeights, magnets: _):
            setting.apparatus = .dumbbells1(weights: oldWeights, magnets: newMagnets)
            
        case .dumbbells2(weights: let oldWeights, magnets: _):
            setting.apparatus = .dumbbells2(weights: oldWeights, magnets: newMagnets)
        default:
            frontend.assert(false, "DumbbellController was called without a dumbbell")
            abort()
        }
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var doneButton: UIBarButtonItem!
    
    private var setting: VariableWeightSetting!
    private var available: [Double]!
    private var used: [Double]!
    private var breadcrumb = ""
}
