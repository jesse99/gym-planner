import UIKit

class HistoryTabController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        reset()
        
//        tableView.backgroundColor = targetColor(.background)
//        view.backgroundColor = tableView.backgroundColor
    }

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        dismissTooltip()
        reset()
    }
    
    @IBAction func unwindToHistory(_ segue:UIStoryboardSegue) {
        reset()
    }
    
//    func onBackColorChanged()
//    {
//        view.backgroundColor = targetColor(.background)
//        tableView.backgroundColor = view.backgroundColor
//        view.setNeedsDisplay()
//    }
    
    private func reset() {
        let app = UIApplication.shared.delegate as! AppDelegate
        exerciseNames = app.program.exercises.map {$0.name}
        exerciseNames.sort()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseNames.isEmpty ? 1 : exerciseNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellID")!
        
        cell.backgroundColor = tableView.backgroundColor
        if exerciseNames.isEmpty {
            cell.textLabel!.text = "No Results"
            cell.textLabel?.textColor = UIColor.gray
        } else {
            cell.textLabel!.text = exerciseNames[(path as NSIndexPath).item]
            cell.textLabel?.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        if !exerciseNames.isEmpty {
            let name = exerciseNames[(path as NSIndexPath).item]
            showDetails(name)   // TODO: pop an alert and ask for charts or details, maybe email too
        }
    }
    
    private func showDetails(_ name: String) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let view = storyboard.instantiateViewController(withIdentifier: "LiftHistoryID") as! ExerciseHistoryController
//        view.initialize(name, "History")
//        present(view, animated: true, completion: nil)
    }
    
    @IBOutlet private var tableView: UITableView!

    private var exerciseNames: [String] = []
}
