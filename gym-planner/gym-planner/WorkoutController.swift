import UIKit

struct StringError: Error {
    let message: String
}

class DummyPersistence: Persistence {
    func load(_ key: String) throws -> Data {
        throw StringError(message: "Load isn't implemented")
    }
    
    func save(_ key: String, _ data: Data) throws {
    }
}

class WorkoutController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func initialize(_ program: Program, _ workout: Workout, _ breadcrumb: String)
    {
        self.program = program
        self.workout = workout
        self.breadcrumb = "\(breadcrumb) • \(workout.name)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        breadcrumbLabel.text = breadcrumb
        
        //filtered = workout.exercises.filter {presults.isActive(workout, $0) && !isSkipped(workout, $0)}
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        //tableView.backgroundColor = targetColor(.background)
        view.backgroundColor = tableView.backgroundColor
    }
    
    @objc func enteringForeground() {
        // Enough time may have passed that we need to redo our labels.
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
//        filtered = workout.exercises.filter {presults.isActive(workout, $0)}
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
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let view = storyboard.instantiateViewController(withIdentifier: "WorkoutOptionsControllerID") as! WorkoutOptionsController
//        view.initialize(presults.program, workout, breadcrumbLabel.text!)
//        present(view, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
//        return filtered.count
        return workout.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCellID")!
        cell.backgroundColor = tableView.backgroundColor
        
        let index = (path as NSIndexPath).item
//        let name = filtered[index]
        let name = workout.exercises[index]
        if let exercise = program.findExercise(name) {
            if let plan = program.findPlan(exercise.plan) {
                let persist = DummyPersistence()
                switch plan.startup(program, exercise, persist) {
                case .ok:
                    cell.textLabel!.text = plan.label()
                    cell.detailTextLabel!.text = plan.sublabel()
                    cell.detailTextLabel?.setColor(.black)

                case .newPlan(_):
                    cell.textLabel!.text = plan.label()
                    cell.detailTextLabel!.text = "Not completed"
                    cell.detailTextLabel?.setColor(.black)

                case .error(let mesg):
                    cell.textLabel!.text = name
                    cell.detailTextLabel!.text = mesg
                    cell.detailTextLabel?.setColor(.red)
                }
            } else {
                cell.textLabel!.text = name
                cell.detailTextLabel!.text = "Couldn't find plan '\(exercise.plan)'"
                cell.detailTextLabel?.setColor(.red)
            }
        } else {
            cell.textLabel!.text = name
            cell.detailTextLabel!.text = "Couldn't find exercise '\(name)'"
            cell.detailTextLabel?.setColor(.red)
        }
        
//        if !doneToday(exerciseName)
//        {
//            cell.textLabel?.setColor(UIColor.black)
//            cell.detailTextLabel?.setColor(UIColor.black)
//        }
//        else
//        {
//            cell.textLabel?.setColor(UIColor.lightGray)
//            cell.detailTextLabel?.setColor(UIColor.lightGray)
//        }
        
        return cell
    }
    
//    private func doneToday(_ exerciseName: String) -> Bool
//    {
//        func wasDoneToday(_ exerciseName: String) -> Bool
//        {
//            if let result = presults.lastCompleted(exerciseName)
//            {
//                if let date = presults.workoutDates[workout.name]   // this check is useful with mesocycles
//                {
//                    let calendar = Calendar.current
//                    return calendar.isDateInToday(date) && calendar.isDateInToday(result.date)
//                }
//            }
//            return false
//        }
//
//        if let random = presults.program.exercises[exerciseName] as? RandomExercise
//        {
//            for candidate in random.names
//            {
//                if wasDoneToday(candidate)
//                {
//                    return true
//                }
//            }
//            return false
//        }
//        else
//        {
//            return wasDoneToday(exerciseName)
//        }
//    }
    
//    static func presentWorkout(_ origin: UIViewController, _ workout: Workout, _ exerciseName: String, _ breadcrumb: String, _ unwindTo: String)
//    {
//        if let exercise = presults.program.exercises[exerciseName]
//        {
//            switch exercise.type
//            {
//            case .cardio:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "CardioResultID") as! CardioResultController
//                view.initialize(workout, exerciseName, exercise as! CardioExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .timed:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "TimedWorkoutID") as! TimedWorkoutController
//                view.initialize(workout, exerciseName, exercise as! TimedExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .maxReps:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "MaxRepsWorkoutID") as! MaxRepsWorkoutController
//                view.initialize(workout, exerciseName, exercise as! MaxRepsExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .fixedReps:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "FixedRepsWorkoutID") as! FixedRepsWorkoutController
//                view.initialize(workout, exerciseName, exercise as! FixedRepsExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .hiit:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "HiitWorkoutID") as! HiitWorkoutController
//                view.initialize(workout, exerciseName, exercise as! HiitExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .bodyWeight:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "BodyWeightWorkoutID") as! BodyWeightWorkoutController
//                view.initialize(workout, exerciseName, exercise as! BodyWeightExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .weighted:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let view = storyboard.instantiateViewController(withIdentifier: "WeightedWorkoutID") as! WeightedWorkoutController
//                view.initialize(workout, exerciseName, exercise as! WeightedExercise, breadcrumb, unwindTo)
//                origin.present(view, animated: true, completion: nil)
//                
//            case .random:
//                let re = exercise as! RandomExercise
//                if !re.names.isEmpty
//                {
//                    presentWorkout(origin, workout, re.choose(workout), breadcrumb, unwindTo)
//                }
//                else
//                {
//                    let alert = UIAlertController.init(title: "\(exerciseName) is empty.", message: "Edit the exercise using Programs tab.", preferredStyle: .alert)
//                    let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
//                    alert.addAction(action)
//                    origin.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//        else
//        {
//            let alert = UIAlertController.init(title: "There is no exercise named \(exerciseName).", message: "Edit the program using Programs tab.", preferredStyle: .alert)
//            let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
//            alert.addAction(action)
//            origin.present(alert, animated: true, completion: nil)
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        var err = ""
        
        let index = (path as NSIndexPath).item
        //        let name = filtered[index]
        let name = workout.exercises[index]
        if let exercise = program.findExercise(name) {
            if let plan = program.findPlan(exercise.plan) {
                let persist = DummyPersistence()
                switch plan.startup(program, exercise, persist) {
                case .ok:
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view = storyboard.instantiateViewController(withIdentifier: "ExerciseID") as! ExerciseController
                    view.initialize(program, workout, exercise, plan, breadcrumbLabel.text!, "unwindToWorkoutID")
                    self.present(view, animated: true, completion: nil)
                    
                case .newPlan(let p):
                    switch p.startup(program, exercise, persist) {
                    case .ok:
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let view = storyboard.instantiateViewController(withIdentifier: "ExerciseID") as! ExerciseController
                        view.initialize(program, workout, exercise, p, breadcrumbLabel.text!, "unwindToWorkoutID")
                        self.present(view, animated: true, completion: nil)
                    case .newPlan(let q):
                        err = "Plan \(plan.name) started plan \(p.name) which started \(q.name)"
                    case .error(let mesg):
                        err = mesg
                    }
                    
                case .error(let mesg):
                    err = mesg
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
    @IBOutlet var optionsButton: UIBarButtonItem!

    private var program: Program!
    private var workout: Workout!
    private var breadcrumb: String!
}

