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
            let name = exerciseNames[(path as NSIndexPath).item]
            cell.textLabel!.text = name
            
            let app = UIApplication.shared.delegate as! AppDelegate
            if let exercise = app.program.exercises.first(where: {$0.name == name}) {
                cell.textLabel?.textColor = exercise.plan.getHistory().isEmpty ? UIColor.gray : UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.gray
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        if !exerciseNames.isEmpty {
            let name = exerciseNames[(path as NSIndexPath).item]
            
            let app = UIApplication.shared.delegate as! AppDelegate
            if let exercise = app.program.exercises.first(where: {$0.name == name}) {
                // TODO: pop an alert and ask for charts or details, maybe email too
                let history = exercise.plan.getHistory()
                if let weighted = history as? [WeightedResult] {
                    showWeighted(exercise, weighted)
                } else {
                    showBase(exercise, history)
                }
            }
        }
    }
    
    // Note that we don't expose all the different weird things plans put into their history:
    // if a user really wants to edit one of those things they'll have to delete the result
    // and redo the exercise.
    private func showBase(_ exercise: Exercise, _ history: [BaseResult]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "BaseHistoryID") as! BaseHistoryController
        view.initialize(exercise, "History")
        present(view, animated: true, completion: nil)
    }
    
    private func showWeighted(_ exercise: Exercise, _ history: [WeightedResult]) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let view = storyboard.instantiateViewController(withIdentifier: "LiftHistoryID") as! ExerciseHistoryController
//        view.initialize(name, "History")
//        present(view, animated: true, completion: nil)
    }
    
    @IBOutlet private var tableView: UITableView!

    private var exerciseNames: [String] = []
}
