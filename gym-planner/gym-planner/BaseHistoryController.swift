import UIKit

class BaseHistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()

        //        tableView.backgroundColor = targetColor(.background)
        //        view.backgroundColor = tableView.backgroundColor
    }
    
    func initialize(_ exercise: Exercise, _ breadcrumb: String)
    {
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
    
    @IBAction func donePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHistoryID", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercise.plan.getHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseHistoryCellID")!
        cell.backgroundColor = tableView.backgroundColor
        
        let items = exercise.plan.getHistory()
        let index = items.count - path.item - 1
        cell.textLabel!.text = items[index].title

        let date = DateFormatter.localizedString(from: items[index].date, dateStyle: .medium, timeStyle: .short)
        cell.detailTextLabel!.text = "\(index): \(date)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt path: IndexPath) {
        if editingStyle == .delete {
            let items = exercise.plan.getHistory()
            let index = items.count - path.item - 1
            exercise.plan.deleteHistory(index)
            tableView.reloadData()
        }
    }
        
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var breadcrumbLabel: UILabel!

    private var exercise: Exercise!
    private var breadcrumb = ""
}

