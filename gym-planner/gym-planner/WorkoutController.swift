import UIKit
import os.log

struct StringError: Error {
    let message: String
}

// When a new view is created the sequence of events is:
//    initialize
//    viewDidLoad
//    viewWillAppear
// When view restoration kicks in the sequence is:
//    viewDidLoad
//    decode state
//    viewWillAppear
class WorkoutController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func initialize(_ workout: Workout, _ breadcrumb: String) {
        print("initialize")
        self.workout = workout
        self.breadcrumb = "\(breadcrumb) • \(workout.name)"
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //tableView.backgroundColor = targetColor(.background)
        view.backgroundColor = tableView.backgroundColor
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(workout.name, forKey: "workout.name")
        coder.encode(breadcrumb, forKey: "breadcrumb")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        print("decode state")
        breadcrumb = coder.decodeObject(forKey: "breadcrumb") as! String
        
        let name = coder.decodeObject(forKey: "workout.name") as! String
        let app = UIApplication.shared.delegate as! AppDelegate
        if let w = app.program.findWorkout(name) {
            workout = w
        } else {
            os_log("couldn't load workout '%@' for program '%@'", type: .error, name, app.program.name)
            workout = app.program.workouts[0]
        }
        
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
    }
    
    @objc func enteringForeground() {
        // Enough time may have passed that we need to redo our labels.
        print("enteringForeground")
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewDidAppear(animated)

        breadcrumbLabel.text = breadcrumb
        
//        var shown = showTooltip(superview: view, forItem: optionsButton, " Use options to deactivate exercises you'd prefer not to do.", .bottom, id: "deactivate_exercises")
        
//        if !shown
//        {
//            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
//            if let cell = cell, filtered.any({(exerciseName) -> Bool in return doneToday(exerciseName)})
//            {
//                shown = showTooltip(superview: view, forView: cell, "Exercises that you have done today are dimmed (although you can do them twice or open them up to change their options).", .top, id: "completed_exercise")
//            }
//        }
//
//        if !shown
//        {
//            if !workout.optional.isEmpty
//            {
//                let id = "\(presults.program.name)_\(workout.name)_activate"
//                _ = showTooltip(superview: view, forItem: optionsButton, "Use options to activate optional exercises.", .bottom, id: id)
//            }
//        }
    }
    
    @IBAction func unwindToWorkout(_ segue:UIStoryboardSegue)
    {
        tableView.reloadData()
    }
        
    @IBAction func skipPressed(_ sender: Any) {
//        let alert = UIAlertController(title: "Are you sure you want to skip this workout?", message: "Note that this will only affect the appearence of the main screen.", preferredStyle: .actionSheet)
//
//        var action = UIAlertAction(title: "Yes", style: .destructive) {_ in self.doSkip()}
//        alert.addAction(action)
//
//        action = UIAlertAction(title: "No", style: .default, handler: nil)
//        alert.addAction(action)
//
//        self.present(alert, animated: true, completion: nil)
    }

//    private func doSkip()
//    {
//        presults.skipWorkout(workout.name)
//        self.performSegue(withIdentifier: "unwindToWorkoutsID", sender: self)
//    }

    @IBAction func optionsPressed(_ sender: Any) {
//        dismissTooltip()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "WorkoutOptionsID") as! WorkoutOptionsController
        view.initialize(workout, breadcrumbLabel.text!)
        present(view, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filtered = workout.exercises.filter {!workout.optional.contains($0)}
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCellID")!
        cell.backgroundColor = tableView.backgroundColor
        
        let filtered = workout.exercises.filter {!workout.optional.contains($0)}
        let index = (path as NSIndexPath).item
        let name = filtered[index]
        let app = UIApplication.shared.delegate as! AppDelegate
        if let exercise = app.program.findExercise(name) {
            if case .underway = exercise.plan.state, exercise.plan.on(workout) {
                cell.textLabel!.text = exercise.plan.label()
                cell.detailTextLabel!.text = exercise.plan.sublabel()
                cell.textLabel?.setColor(.red)
                cell.detailTextLabel?.setColor(.red)    // TODO: use targetColor

            } else {
                let cloned = exercise.plan.clone()
                if cloned.start(workout, name) == nil {
                    if case let .error(err) = cloned.state {
                        cell.textLabel!.text = name
                        cell.detailTextLabel!.text = err
                        cell.textLabel?.setColor(.black)
                        cell.detailTextLabel?.setColor(.black)

                    } else {
                        cell.textLabel!.text = cloned.label()
                        cell.detailTextLabel!.text = cloned.sublabel()
                        let calendar = Calendar.current
                        if let completed = exercise.completed[workout.name], calendar.isDate(completed, inSameDayAs: Date()) {
                            cell.textLabel?.setColor(.lightGray)
                            cell.detailTextLabel?.setColor(.lightGray)
                        } else {
                            cell.textLabel?.setColor(.black)
                            cell.detailTextLabel?.setColor(.black)
                        }
                    }

                } else {
                    cell.textLabel!.text = cloned.label()
                    cell.detailTextLabel!.text = "Not completed"
                    cell.textLabel?.setColor(.black)
                    cell.detailTextLabel?.setColor(.black)
                }
            }
        } else {
            cell.textLabel!.text = name
            cell.detailTextLabel!.text = "Couldn't find exercise '\(name)'"
            cell.textLabel?.setColor(.black)
            cell.detailTextLabel?.setColor(.black)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        var err = ""
        
        let index = (path as NSIndexPath).item
        let filtered = workout.exercises.filter {!workout.optional.contains($0)}
        let name = filtered[index]
        let app = UIApplication.shared.delegate as! AppDelegate
        if let exercise = app.program.findExercise(name) {
            if case .underway = exercise.plan.state, exercise.plan.on(workout) {
                presentExercise(exercise)

            } else {
                // If we're started but not underway we want to re-start to ensure that we pickup
                // on any changes from a base exercise.
                if let newPlan = exercise.plan.start(workout, name) {
                    let newName = exercise.name + "-" + newPlan.planName
                    let newExercise = exercise.withPlan(newName, newPlan)
                    app.program.setExercise(newExercise)
                    
                    if let newerPlan = newPlan.start(workout, newName) {
                        err = "Plan \(exercise.plan.planName) started plan \(newPlan.planName) which started \(newerPlan.planName)"
                    } else {
                        switch newPlan.state {
                        case .error(let mesg):
                            err = mesg
                        default:
                            presentExercise(newExercise)
                        }
                    }

                } else {
                    switch exercise.plan.state {
                    case .error(let mesg):
                        err = mesg
                    default:
                        presentExercise(exercise)
                    }
                }
            }
        }
        
        if !err.isEmpty {
            let alert = UIAlertController.init(title: "Can't start \(name).", message: err, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentExercise(_ exercise: Exercise) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "ExerciseID") as! ExerciseController
        view.initialize(workout, exercise, breadcrumbLabel.text!, "unwindToWorkoutID")
        self.present(view, animated: true, completion: nil)
    }
    
//    private func isSkipped(_ workout: Workout, _ exerciseName: String) -> Bool
//    {
//        if let exercise = presults.program.exercises[exerciseName] as? WeightedExercise
//        {
//            switch exercise.routine
//            {
//            case .normal(_, _, _):
//                break
//
//            case .meso(let name, let offset, _):
//                if let (cycle, _, _) = WeightedWorkoutController.getRpeCycle(workout, name, offset, exerciseName)
//                {
//                    if case .skip = cycle.method
//                    {
//                        return true
//                    }
//                }
//            }
//        }
//
//        return false
//    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var breadcrumbLabel: UILabel! // TODO: this should be a BreadcrumbView
    @IBOutlet private var optionsButton: UIBarButtonItem!

    private var workout: Workout!
    private var breadcrumb: String!
}

