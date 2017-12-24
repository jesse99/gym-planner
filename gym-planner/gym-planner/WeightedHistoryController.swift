import UIKit

// This is just like BaseHistoryController except that it supports selecting (and the accessory
// indicator is different).
class WeightedHistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
        
        //        tableView.backgroundColor = targetColor(.background)
        //        view.backgroundColor = tableView.backgroundColor
    }
    
    func initialize(_ exercise: Exercise, _ breadcrumb: String) {
        self.exercise = exercise
        self.breadcrumb = "\(breadcrumb) • \(exercise.name)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        dismissTooltip()
        tableView.reloadData()
    }
    
    //    func onBackColorChanged()
    //    {
    //        view.backgroundColor = targetColor(.background)
    //        tableView.backgroundColor = view.backgroundColor
    //        view.setNeedsDisplay()
    //    }
    
    @IBAction func unwindToWeightedHistory(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHistoryID", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercise.plan.getHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeightedHistoryCellID")!
        cell.backgroundColor = tableView.backgroundColor
        
        let results = exercise.plan.getHistory()
        let index = results.count - path.item - 1
        cell.textLabel!.text = results[index].title
        
        let date = DateFormatter.localizedString(from: results[index].date, dateStyle: .medium, timeStyle: .short)
        cell.detailTextLabel!.text = "\(index): \(date)"
        
        if let result = results[index] as? WeightedResult {
            cell.textLabel?.textColor = result.missed ? UIColor.red : UIColor.black
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt path: IndexPath) {
        if editingStyle == .delete {
            let results = exercise.plan.getHistory()
            let index = results.count - path.item - 1
            exercise.plan.deleteHistory(index)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        let results = exercise.plan.getHistory()
        let index = results.count - path.item - 1

        if let result = results[index] as? WeightedResult {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewController(withIdentifier: "EditWeightedHistoryID") as! EditWeightedHistoryController
            view.initialize(exercise, result, breadcrumb)
            present(view, animated: true, completion: nil)
        }
    }

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var breadcrumbLabel: UILabel!

    private var exercise: Exercise!
    private var breadcrumb = ""
}


