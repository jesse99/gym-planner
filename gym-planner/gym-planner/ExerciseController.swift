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

        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
    }
    
    @objc func leavingForeground() {
        //savePosition()
    }

    private func updateUI() {
        if !exercise.plan.finished() {
            let current = exercise.plan.current()    // TODO: plan can be nil
            titleLabel.text = current.title
            subtitleLabel.text = current.subtitle
            amountLabel.text = current.amount
            detailsLabel.text = current.details

            nextButton.setTitle("Next", for: .normal)

        } else {
            //titleLabel.text = "All Done"
            nextButton.setTitle("All Done", for: .normal)
        }
        
        previousLabel.text = exercise.plan.prevLabel()
        historyLabel.text = exercise.plan.historyLabel()

        resetButton.isEnabled = !exercise.plan.atStart()
        startTimerButton.isEnabled = exercise.plan.restSecs().secs > 0

        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        startTimerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        let font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.font = font.makeBold()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
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
    }
    
    @IBAction func unwindToExercise(_ segue: UIStoryboardSegue) {
        //restorePosition()
        exercise.plan.refresh()
        updateUI()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        //dismissTooltip()
        stopTimer()
        
        if exercise.plan.finished() {
            self.performSegue(withIdentifier: unwindTo, sender: self)
        } else {
            let results = exercise.plan.completions()
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
        }
    }
    
    private func handleNext(_ action: String) {
        if exercise.plan.finished() {
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
            startTimer(force: false)    // TODO: do we really need a force argument?
            startedTimer = true
        }
    }
    
    @IBAction func startTimerPressed(_ sender: Any) {
        if timer != nil {
            stopTimer()
        } else {
            startTime = Date()
            startTimer(force: true)
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        //dismissTooltip()
        
        exercise.plan.reset()
        self.startedTimer = false
        stopTimer()
        updateUI()
    }
    
    @IBAction func notesPressed(_ sender: Any) {
//        savePosition()
//        dismissTooltip()
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let view = storyboard.instantiateViewController(withIdentifier: "ShowNoteControllerID") as! ShowNoteController
//        view.initialize("unwindToWeightedWorkoutID", exercise.formalName, breadcrumbLabel.text!)
//        present(view, animated: true, completion: nil)
    }
    
    @IBAction func optionsPressed(_ sender: Any) {
//        dismissTooltip()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch exercise.settings {
        case .derivedWeight(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "DerivedWeightID") as! DerivedWeightController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .fixedWeight(_):
            break   // TODO: implement this
            
        case .variableReps(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "VariableRepsID") as! VariableRepsController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
            
        case .variableWeight(let setting):
            let view = storyboard.instantiateViewController(withIdentifier: "VariableWeightID") as! VariableWeightController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .timed(_):
            break   // TODO: implement this
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
    
    private func stopTimer() {
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
    }
    
    // Note that this can't be private (or the selector doesn't work).
    @objc func timerFired(_ sender: AnyObject) {
        if UIApplication.shared.applicationState == .active {
            let secs = Double(exercise.plan.restSecs().secs) - Date().timeIntervalSince(startTime)
            if updateTimerLabel(secsLabel, secs) {
                // We don't want to run the timer too long since it chews up the battery.
                stopTimer()
            }
        }
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
                AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
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
    
    private var timer: Timer? = nil
    private var startTime = Date()

    private var workout: Workout!
    private var exercise: Exercise!
    private var unwindTo: String!
    
    private var startedTimer = false
    private var breadcrumb = ""
}

