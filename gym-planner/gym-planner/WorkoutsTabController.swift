import UIKit

class WorkoutsTabController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.numberOfLines = 0 // default is to only allow 1 line
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //tableView.backgroundColor = targetColor(.background)
        statusLabel.backgroundColor = tableView.backgroundColor
        view.backgroundColor = tableView.backgroundColor
        view.setNeedsDisplay()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(WorkoutsTabController.enteringForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
    }
    
    @objc func enteringForeground() {
        // Enough time may have passed that we need to redo our labels.
        //presults.updateCardio()   // TODO
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //dismissTooltip()  // TODO
        statusLabel.text = WorkoutsTabController.getWorkoutSummary()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        var shown = false // TODO: tooltips
//        if let bar = tabBarController, let items = bar.tabBar.items {
//            shown = showTooltip(superview: nil, forItem: items[ProgramsTabIndex], "Select a program to follow.", .bottom, id: "select_program")
//        }
        
//        let text = "Workouts are normally meant to be done within a single day with a day or two of rest between workouts. The workout that should be done next is highlighted."
//        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
//        if let missingIndex = findFirstMissingWorkout() {
//            let path = IndexPath(row: missingIndex, section: 0)
//            tableView.scrollToRow(at: path, at: .middle, animated: true)
//
//            if let cell = cell, !shown {
//                shown = showTooltip(superview: view, forView: cell, text, .top, id: "completed_workout")
//            }
//        } else {
//            if let oldestIndex = findOldestWorkout() {
//                let path = IndexPath(row: oldestIndex, section: 0)
//                tableView.scrollToRow(at: path, at: .middle, animated: true)
//                if let cell = cell, !shown {
//                    shown = showTooltip(superview: view, forView: cell, text, .top, id: "completed_workout")
//                }
//            }
//        }
        
//        let app = UIApplication.shared.delegate as! AppDelegate
//        if !shown && presults.numWorkouts >= 3*4 && !app.product.purchased(ID: EditProgramProductID) {
//            if let bar = tabBarController, let items = bar.tabBar.items {
//                shown = showTooltip(superview: nil, forItem: items[ProgramsTabIndex], "You can change every facet of your program using edit. For example you can add or replace exercises or add new workouts for cardio or stretching.", .bottom, id: "can_edit")
//            }
//        }
//
//        if !shown && UserDefaults.standard.object(forKey: "pressed-review") == nil {
//            let mesg = "Please consider writing an app review. Even just a few sentences would help to make the app more popular and better supported."
//            if presults.numWorkouts >= 60 {
//                if let bar = tabBarController, let items = bar.tabBar.items {
//                    shown = showTooltip(superview: nil, forItem: items[MoreTabIndex], mesg, .bottom, id: "please_review_60")
//                    supressTooltip(id: "please_review_30")
//                    supressTooltip(id: "please_review_10")
//                }
//            } else if presults.numWorkouts >= 30 {
//                if let bar = tabBarController, let items = bar.tabBar.items {
//                    shown = showTooltip(superview: nil, forItem: items[MoreTabIndex], mesg, .bottom, id: "please_review_30")
//                    supressTooltip(id: "please_review_10")
//                }
//            } else if presults.numWorkouts >= 10 {
//                if let bar = tabBarController, let items = bar.tabBar.items {
//                    shown = showTooltip(superview: nil, forItem: items[MoreTabIndex], mesg, .bottom, id: "please_review_10")
//                }
//            }
//        }
    }
    
    @IBAction func unwindToWorkouts(_ segue:UIStoryboardSegue) {
        tableView.reloadData()
        statusLabel.text = WorkoutsTabController.getWorkoutSummary()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.program.workouts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        //dismissTooltip()
        let index = path.item
        let app = UIApplication.shared.delegate as! AppDelegate
        let workout = app.program.workouts[index]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "WorkoutID") as! WorkoutController
        view.initialize(workout, "Workouts")
        present(view, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutsCellID")!
        cell.backgroundColor = tableView.backgroundColor
        
        let index = path.item
        let app = UIApplication.shared.delegate as! AppDelegate
        let workout = app.program.workouts[index]
        cell.textLabel!.text = workout.name
        cell.detailTextLabel!.text = ""

//        if !hasActiveExercise(workout) { // TODO
//            cell.detailTextLabel!.text = "inactive"
//        } else if allCardio(workout) {
//            // Cardio is typically spread out through the week so we don't care
//            // so much about when it was last performed.
//            cell.detailTextLabel!.text = getCardioDetails(workout)
//        }
//        else if let date = presults.workoutDates[workout.name] {
//            cell.detailTextLabel!.text = "last workout was \(date.daysName())"
//
//            //            let suffix = String(format: " (%.1f hours ago)", NSDate().hoursSinceDate(date))
//            //            cell.detailTextLabel!.text = cell.detailTextLabel!.text! + suffix
//        } else {
//            cell.detailTextLabel!.text = "not completed"
//        }
//
//        if let currentIndex = findCurrentWorkout() {
//            // Highlight the workout the user is performing.
//            let color = currentIndex == (path as NSIndexPath).item ? targetColor(.selectionText) : UIColor.black
//            cell.textLabel!.setColor(color)
//            cell.detailTextLabel!.setColor(color)
//
//            if currentIndex == (path as NSIndexPath).item {
//                if exercisesAllCompleted(program.workouts[currentIndex]) {
//                    cell.detailTextLabel!.text = "finished today"
//                } else {
//                    cell.detailTextLabel!.text = "in progress"
//                }
//            }
//        }
//        else if let missingIndex = findFirstMissingWorkout() {
//            // Highlight the first workout that hasn't been completed.
//            let color = missingIndex == (path as NSIndexPath).item ? targetColor(.selectionText) : UIColor.black
//            cell.textLabel!.setColor(color)
//            cell.detailTextLabel!.setColor(color)
//        } else {
//            // If all the workouts have been completed then highlight the oldest day.
//            if let oldestIndex = findOldestWorkout() {
//                let color = oldestIndex == (path as NSIndexPath).item ? targetColor(.selectionText) : UIColor.black
//                cell.textLabel!.setColor(color)
//                cell.detailTextLabel!.setColor(color)
//            } else {
//                cell.textLabel!.setColor(UIColor.black)
//                cell.detailTextLabel!.setColor(UIColor.black)
//            }
//        }
        
        return cell
    }
    
//    private func exercisesAllCompleted(_ workout: Workout) -> Bool {
//        let calendar = Calendar.current
//        for exerciseName in workout.exercises {
//            if presults.isActive(workout, exerciseName) {
//                if let result = presults.results[exerciseName]?.last {
//                    if !calendar.isDate(result.date, inSameDayAs: Date()) {
//                        return false
//                    }
//                } else {
//                    return false
//                }
//            }
//        }
//        return true
//    }
    
//    private func anyExerciseCompleted(_ workout: Workout) -> Bool {
//        let calendar = Calendar.current
//        for exerciseName in workout.exercises {
//            if presults.isActive(workout, exerciseName) {
//                if let result = presults.results[exerciseName]?.last {
//                    if calendar.isDate(result.date, inSameDayAs: Date()) {
//                        return true
//                    }
//                }
//            }
//        }
//        return false
//    }
    
//    private func findFirstMissingWorkout() -> Int? {
//        for (i, workout) in program.workouts.enumerated() {
//            if presults.workoutDates[workout.name] == nil && !allCardio(workout) && hasActiveExercise(workout) {
//                return i
//            }
//        }
//        return nil
//    }
    
//    private func findCurrentWorkout() -> Int? {
//        var newestDate = Date.distantPast
//        var newestIndex: Int? = nil
//
//        let calendar = Calendar.current
//        for (i, workout) in program.workouts.enumerated() {
//            if let date = presults.workoutDates[workout.name], calendar.isDate(date, inSameDayAs: Date()) && date.timeIntervalSince1970 >= newestDate.timeIntervalSince1970 && anyExerciseCompleted(workout) {    // anyExerciseCompleted so skips work as expected
//                newestDate = date
//                newestIndex = i
//            }
//        }
//        return newestIndex
//    }
    
//    private func findOldestWorkout() -> Int? {
//        var oldestDate = Date()
//        var oldestIndex: Int? = nil
//        for (i, workout) in program.workouts.enumerated() {
//            if let date = presults.workoutDates[workout.name], !allCardio(workout) && hasActiveExercise(workout) {
//                if date.timeIntervalSince1970 < oldestDate.timeIntervalSince1970 {
//                    oldestDate = date as Date
//                    oldestIndex = i
//                }
//            }
//        }
//        return oldestIndex
//    }
    
//    private func hasActiveExercise(_ workout: Workout) -> Bool {
//        for exerciseName in workout.exercises + workout.optional {
//            if presults.isActive(workout, exerciseName) {
//                return true
//            }
//        }
//
//        return false
//    }
    
//    private func allCardio(_ workout: Workout) -> Bool {
//        for exerciseName in workout.exercises {
//            if let exercise = presults.program.exercises[exerciseName], exercise.type != .cardio {
//                return false
//            }
//        }
//
//        return true
//    }
    
//    private func getCardioDetails(_ workout: Workout) -> String {
//        var mins = 0
//        for exerciseName in workout.exercises {
//            let exercise = presults.program.exercises[exerciseName] as! CardioExercise
//            mins += exercise.minsRemaining(exerciseName)
//        }
//        return CardioExercise.minsToStr(mins)
//    }
    
    // Returns a string like: "You’ve been running the Ripptoe Masters program for 3 months, and have
    // worked out 84 days."
    static internal func getWorkoutSummary() -> String {
        // TODO: return an attributed string (program name in italics)
        // TODO: or underline?
//        if results.numWorkouts > 0 {
//            let elapsed = results.dateStarted.longDurationName()
//            let count = results.numWorkouts == 1 ? "1 day" : "\(results.numWorkouts) days"
//            return "You’ve been running the \(results.program.name) program for \(elapsed) and have worked out \(count)."
//        } else {
//            return "You are running the \(results.program.name) program."
//        }
        return ""
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var statusLabel: UILabel!
}
