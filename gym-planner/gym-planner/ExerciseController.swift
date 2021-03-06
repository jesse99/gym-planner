import AVFoundation // for vibrate
import UIKit
import UserNotifications
import os.log

class ExerciseController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

//        detailsLabel.backgroundColor = targetColor(.background)
//        previousLabel.backgroundColor = detailsLabel.backgroundColor
//        historyLabel.backgroundColor = detailsLabel.backgroundColor
//        view.backgroundColor = detailsLabel.backgroundColor
    }
    
    func initialize(_ workout: Workout, _ exercise: Exercise, _ breadcrumb: String, _ unwindTo: String) {
        self.workout = workout
        self.exercise = exercise    // note that the plan has been started already
        self.unwindTo = unwindTo
        self.breadcrumb = "\(breadcrumb) • \(exercise.name)"

        self.startedTimer = false
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(breadcrumb, forKey: "breadcrumb")
        coder.encode(unwindTo, forKey: "unwindTo")
        coder.encode(workout.name, forKey: "workout.name")
        coder.encode(exercise.name, forKey: "exercise.name")
        
        coder.encode(startTime, forKey: "startTime")
        coder.encode(timer != nil, forKey: "timerRunning")
        coder.encode(startedTimer, forKey: "startedTimer")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        print("decode state")
        let app = UIApplication.shared.delegate as! AppDelegate
        breadcrumb = coder.decodeObject(forKey: "breadcrumb") as! String
        unwindTo = coder.decodeObject(forKey: "unwindTo") as! String
        
        var name = coder.decodeObject(forKey: "workout.name") as! String
        if let w = app.program.findWorkout(name) {
            workout = w
        } else {
            os_log("couldn't load workout '%@' for program '%@'", type: .error, name, app.program.name)
        }
        
        name = coder.decodeObject(forKey: "exercise.name") as! String
        if let e = app.program.findExercise(name) {
            exercise = e
        } else {
            os_log("couldn't load exercise '%@' for program '%@'", type: .error, name, app.program.name)
        }

        if let date = coder.decodeObject(forKey: "startTime") as? Date {
            startTime = date
            startedTimer = coder.decodeBool(forKey: "startedTimer")
            let timerRunning = coder.decodeBool(forKey: "timerRunning")
            
            if startedTimer && timerRunning && exercise.plan.restSecs().secs > 0 {
                startTimer(force: true)
            }
        }
        
        // When plans load they can reset to waiting if it's been too long so we need to re-start
        // the plan if that happened.
        if case .waiting = exercise.plan.state {
            let newPlan = exercise.plan.start(workout, name)
            frontend.assert(newPlan == nil, "newPlan should have been nil") // because we got here via starting the plan
        }

        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
    }
    
    @objc func leavingForeground() {
        //savePosition()
    }

    private func updateUI() {
        let current = exercise.plan.current()
        titleLabel.text = current.title
        subtitleLabel.text = current.subtitle
        amountLabel.text = current.amount
        detailsLabel.text = current.details
        
        if let name = current.color {
            view.backgroundColor = UIColor.fromName(name)
        } else {
            view.backgroundColor = originalColor
        }

        if case .finished = exercise.plan.state {
            nextButton.setTitle("All Done", for: .normal)
            startTimerButton.isHidden = false
        } else {
            nextButton.setTitle(current.buttonName, for: .normal)
            startTimerButton.isHidden = !current.showStartButton
        }
        
        if exercise.prevExercise != nil || exercise.nextExercise != nil {
            progressionButton.title = "Progression"
        } else {
            progressionButton.title = ""
        }

        let (label, color) = exercise.plan.prevLabel()
        previousLabel.text = label
        previousLabel.textColor = color
        historyLabel.text = exercise.plan.historyLabel()

        if case .underway = exercise.plan.state {
            resetButton.isEnabled = true
        } else {
            resetButton.isEnabled = false
        }
        startTimerButton.isEnabled = exercise.plan.restSecs().secs > 0

        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        startTimerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        let font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.font = font.makeBold()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        originalColor = view.backgroundColor
        
        updateUI()
        notesButton.isEnabled = exercise.formalName != ""
        secsLabel.isHidden = timer == nil

        // Not sure why this didn't take in the scene editor. Did see a comment saying setting
        // the text of a button will reset the font but we're not doing that.
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        startTimerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(ExerciseController.leavingForeground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        var shown = false
//        if !exercise.hasBaseExercise()
//        {
//            if setting.getMaxWeight(exercise) <= 0.0
//            {
//                shown = showTooltip(superview: view, forItem: optionsButton, "You can skip this by typing in the weight you want to use. You can also adjust how quickly weights jump up each time by toggling the available weights.", .bottom, id: "short_cut_max_lifts")
//            }
//        }
//
//        if !shown
//        {
//            shown = showTooltip(superview: view, forItem: exitButton, "The Exit button will suspend the current exercise so that you can resume it later.", .bottom, id: "exit_button")
//        }
//
//        if !shown
//        {
//            shown = showTooltip(superview: view, forItem: resetButton, "The Reset button will restart the current exercise from the beginning.", .bottom, id: "reset_button")
//        }
//
//        if !shown
//        {
//            _ = showTooltip(superview: view, forView: nextButton, "Pressing the background starts and stops the timer (but doesn't start the exercise).", .top, id: "table_presses")
//        }

        switch exercise.plan.state {
        case .started, .underway:
            // This is for HIIT where we want to auto-start.
            if exercise.plan.current().buttonName.isEmpty {
                startTimer(force: false)
            }
        default:
            break
        }
    }
    
    @IBAction func unwindToExercise(_ segue: UIStoryboardSegue) {
        //restorePosition()
        exercise.plan.refresh()
        updateUI()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.saveExercise(exercise.name)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        //dismissTooltip()
        if timer != nil {
            stopTimer(manual: (sender as? Plan) == nil)
        }
        
        if case .finished = exercise.plan.state {
            self.performSegue(withIdentifier: unwindTo, sender: self)
        } else {
            switch exercise.plan.completions() {
            case .normal(let results):
                if results.count == 1 {
                    results[0].callback()
                    handleNext("default")
                } else {
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                    
                    for result in results {
                        let action = UIAlertAction(title: result.title, style: .default) {_ in result.callback(); self.handleNext(result.title)}
                        alert.addAction(action)
                        if result.isDefault {
                            alert.preferredAction = action
                        }
                    }
                    
                    self.present(alert, animated: true, completion: nil)
                }

            case .cardio(let callback):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "CardioResultID") as! CardioResultController
                view.initialize(exercise, callback, breadcrumbLabel.text!)
                present(view, animated: true, completion: nil)
            }
        }
    }
    
    private func handleNext(_ action: String) {
        if case .finished = exercise.plan.state {
            updateUI()
            maybeStartTimer()
        } else {
            os_log("%@: %@/%@", type: .info, action, exercise.plan.current().amount, exercise.plan.current().details)
            fadeOut {self.updateUI(); self.maybeStartTimer()}
        }
    }
    
    private func maybeStartTimer() {
        let rest = exercise.plan.restSecs()
        if rest.autoStart && rest.secs > 0 {
            startTimer(force: false)
            startedTimer = true
        }
    }
    
    @IBAction func startTimerPressed(_ sender: Any) {
        if timer != nil {
            stopTimer(manual: true)
        } else {
            startTime = Date()
            startTimer(force: true)
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        //dismissTooltip()
        
        stopTimer(manual: true)
        exercise.plan.reset()
        self.startedTimer = false
        updateUI()
    }
    
    @IBAction func notesPressed(_ sender: Any) {
//        savePosition()
//        dismissTooltip()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "NotesID") as! NotesController
        view.initialize(exercise, breadcrumbLabel.text!)
        present(view, animated: true, completion: nil)
    }
    
    @IBAction func progressionPressed(_ sender: Any) {
        func getProgression() -> [String] {
            var progression: [String] = []
            
            var name = exercise.name
            while true {
                if let e = frontend.findExercise(name) {
                    progression.insert(name, at: 0)
                    if let newName = e.prevExercise {
                        name = newName
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
            
            name = exercise.name
            while true {
                if let e = frontend.findExercise(name) {
                    if let newName = e.nextExercise {
                        progression.append(newName)
                        name = newName
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
            
            return progression
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let progression = getProgression()
        for (i, name) in progression.enumerated() {
            let action = UIAlertAction(title: "\(i+1) \(name)", style: .default) {_ in self.changeProgression(name)}
            alert.addAction(action)
            
            if name == exercise.name {
                alert.preferredAction = action
            }
        }
        
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func changeProgression(_ toName: String) {
        print("changing progression to \(toName)")

        let app = UIApplication.shared.delegate as! AppDelegate
        for workout in app.program.workouts {
            for (i, name) in workout.exercises.enumerated() {
                if name == exercise.name {
                    workout.exercises[i] = toName
                }
            }
        }
        
        breadcrumb = breadcrumb.replacingOccurrences(of: exercise.name, with: toName)
        exercise = frontend.findExercise(toName)!
        
        if let newPlan = exercise.plan.start(workout, toName) {
            let newName = exercise.name + "-" + newPlan.planName
            let newExercise = exercise.withPlan(newName, newPlan)
            app.program.setExercise(newExercise)
            
            if let newerPlan = newPlan.start(workout, newName) {
                breadcrumbLabel.text = "Plan \(exercise.plan.planName) started plan \(newPlan.planName) which started \(newerPlan.planName)"

            } else {
                switch newPlan.state {
                case .error(let mesg):
                    breadcrumbLabel.text = mesg
                default:
                    breadcrumb = breadcrumb.replacingOccurrences(of: toName, with: newName)
                    exercise = newExercise
                }
            }

        } else {
            switch exercise.plan.state {
            case .error(let mesg):
                breadcrumbLabel.text = mesg
            default:
                breadcrumbLabel.text = breadcrumb
            }
        }
        frontend.saveExercise(exercise.name)

        resetPressed(self)
    }
    
    @IBAction func optionsPressed(_ sender: Any) {
//        dismissTooltip()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch exercise.settings {
        case .derivedWeight(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "DerivedWeightID") as! DerivedWeightController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .fixedWeight(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "FixedWeightID") as! FixedWeightController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .variableReps(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "VariableRepsID") as! VariableRepsController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .variableWeight(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "VariableWeightID") as! VariableWeightController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .intensity(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "IntensityID") as! IntensityController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .hiit(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "HIITID") as! HIITController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
        }
    }
    
    private func startTimer(force: Bool) {
        let restSecs = exercise.plan.restSecs().secs
        if timer == nil && (restSecs > 0 || force) {
            let secs = Double(restSecs) - Date().timeIntervalSince(startTime)
            if !force || secs <= 0.0 || secs >= Double(restSecs) {
                startTime = Date()
            }
            
            secsLabel.text = ""
            //secsLabel.backgroundColor = grayColor(211, 0.7)
            secsLabel.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(ExerciseController.timerFired(_:)), userInfo: nil, repeats: true)
            
            let app = UIApplication.shared.delegate as! AppDelegate
            if app.notificationsAreEnabled {
                app.scheduleTimerNotification(Date(timeInterval: Double(restSecs), since: startTime))
            }
            
            nextButton.isHidden = true
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        startTimerButton.setTitle("Stop Timer", for: UIControlState())
        startTimerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    private func stopTimer(manual: Bool) {
        if let t = timer {
            secsLabel.isHidden = true
            t.invalidate()
            timer = nil
            nextButton.isHidden = false
            
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
        startTimerButton.setTitle("Start Timer", for: UIControlState())
        startTimerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        if manual {
            _ = autoAdvanced(manual: true)
        }
    }
    
    // Note that this can't be private (or the selector doesn't work).
    @objc func timerFired(_ sender: AnyObject) {
        if UIApplication.shared.applicationState == .active {
            let secs = Double(exercise.plan.restSecs().secs) - Date().timeIntervalSince(startTime)
            
            if secs <= 0.0 && autoAdvanced(manual: false) {
                return
            } else if updateTimerLabel(secsLabel, secs) {
                // We don't want to run the timer too long since it chews up the battery.
                stopTimer(manual: false)
            }
        }
    }
    
    private func autoAdvanced(manual: Bool) -> Bool {
        switch exercise.plan.state {
        case .started, .underway:
            // This is for HIIT where we want to auto-advance when the timer elapses.
            if exercise.plan.current().buttonName.isEmpty{
                if !manual {
                    AudioServicesPlayAlertSound(exercise.plan.restSound())
                }
                nextPressed(exercise.plan)
                return true
            }
        default:
            break
        }
        return false
    }
    
    // Returns true if the timer has run so long that it should be forcibly stopped.
    func updateTimerLabel(_ label: UILabel, _ secs: Double) -> Bool {
        if secs >= 0.0 {
            label.text = secsToShortDurationName(secs)
            label.textColor = UIColor.black
            return false
        } else {
            if secs < -2 {
                label.text = "+" + secsToShortDurationName(-secs)
            } else {
                label.text = "Done!"
            }
            let color = newColor(0, 100, 0) // DarkGreen
            if label.textColor != color {
                AudioServicesPlayAlertSound(exercise.plan.restSound())
                label.textColor = color
            }
            
            return -secs > 2*60
        }
    }
    
    private var currentAnimator: NSObject? = nil
    
    func animationDuration() -> Double {
        var duration = 1.0
        if UIDevice.current.name == "Jesse’s MacBook Pro" {
            duration /= 5
        }
        return duration
    }
    
    private func fadeOut(_ callback: @escaping () -> Void) {
        if #available(iOS 10.0, *) {
            let timing = UICubicTimingParameters(animationCurve: .easeIn)
            let animator = UIViewPropertyAnimator(duration: animationDuration(), timingParameters: timing)
            animator.addAnimations {self.nextButton.alpha = 0.0; self.titleLabel.alpha = 0.0; self.subtitleLabel.alpha = 0.0; self.amountLabel.alpha = 0.0; self.detailsLabel.alpha = 0.0}
            animator.addCompletion {_ in callback(); self.fadeIn()}
            animator.startAnimation()
            
            currentAnimator = animator  // prevent GC
        } else {
            callback()
        }
    }
    
    private func fadeIn() {
        if #available(iOS 10.0, *) {
            let timing = UICubicTimingParameters(animationCurve: .easeOut)
            let animator = UIViewPropertyAnimator(duration: animationDuration(), timingParameters: timing)
            animator.addAnimations {self.nextButton.alpha = 1.0; self.titleLabel.alpha = 1.0; self.subtitleLabel.alpha = 1.0; self.amountLabel.alpha = 1.0; self.detailsLabel.alpha = 1.0}
            animator.startAnimation()
            
            currentAnimator = animator  // prevent GC
        }
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!
    @IBOutlet private var secsLabel: UILabel!
    @IBOutlet private var previousLabel: UILabel!
    @IBOutlet private var historyLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var startTimerButton: UIButton!
    @IBOutlet private var resetButton: UIBarButtonItem!
    @IBOutlet private var notesButton: UIBarButtonItem!
    @IBOutlet private var progressionButton: UIBarButtonItem!
    
    private var timer: Timer? = nil
    private var startTime = Date()
    private var originalColor: UIColor? = nil

    private var workout: Workout!
    private var exercise: Exercise!
    private var unwindTo: String!
    
    private var startedTimer = false
    private var breadcrumb = ""
}

