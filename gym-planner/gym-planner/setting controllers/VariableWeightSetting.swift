import UIKit
import os.log

class VariableWeightController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: VariableWeightSetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Options"
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(breadcrumb, forKey: "breadcrumb")
        coder.encode(exercise.name, forKey: "exercise.name")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        let app = UIApplication.shared.delegate as! AppDelegate
        breadcrumb = coder.decodeObject(forKey: "breadcrumb") as! String
        
        let name = coder.decodeObject(forKey: "exercise.name") as! String
        if let e = app.program.findExercise(name) {
            exercise = e
            switch exercise.settings {
            case .variableWeight(let setting): self.setting = setting
            default: os_log("%@ isn't using derived weight", type: .error, name)
            }
        } else {
            os_log("couldn't load exercise '%@' for program '%@'", type: .error, name, app.program.name)
        }
        
        super.decodeRestorableState(with: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb

        if UIDevice.current.name != "Jesse’s MacBook Pro" {
            setDateButton.isEnabled = false
            setDateButton.title = ""
        }
        
        if setting != nil {
            restTextbox.text = secsToStr(setting.restSecs)
            weightTextbox.text = Weight.friendlyStr(setting.weight)
            
            if let reps = setting.reps {
                repsLabel.isHidden = false
                repsTextbox.isHidden = false
                repsTextbox.text = "\(reps)"
            } else {
                repsLabel.isHidden = true
                repsTextbox.isHidden = true
            }
            doneButton.isEnabled = true
        }
    }
    
    @IBAction func unwindToVariableWeight(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        if setting != nil {
            restTextbox.resignFirstResponder()
            weightTextbox.resignFirstResponder()
            repsTextbox.resignFirstResponder()
        }
    }
    
    // TODO: setting the weight to zero should startup the NRepsMax plan. This kind of works but you
    // have to reset the exercise, exit it, and then re-enter it.
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.changeWeight(Double(weightTextbox.text!)!)  // TODO: use something like toWeight
            
            if let text = restTextbox.text, let value = strToSecs(text) {
                setting.restSecs = value
            }

            if !repsLabel.isHidden {
                let reps = Int(repsTextbox?.text ?? "0") ?? 0
                setting.reps = reps
            } else {
                setting.reps = nil
            }
            
            if let week = weekOffset {
                let calendar = Calendar.current
                let date = calendar.date(byAdding: .weekOfYear, value: week, to: Date())
                setting.forceDate(date!)
            }
        }
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBAction func adjustPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        var action = UIAlertAction(title: "+ 20%", style: .default) {_ in
            self.adjustWeight(0.2)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "+ 15%", style: .default) {_ in
            self.adjustWeight(0.15)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "+ 10%", style: .default) {_ in
            self.adjustWeight(0.1)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "+ 5%", style: .default) {_ in
            self.adjustWeight(0.05)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "0%", style: .default) {_ in
            self.adjustWeight(0.0)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "- 5%", style: .default) {_ in
            self.adjustWeight(-0.05)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "- 10%", style: .default) {_ in
            self.adjustWeight(-0.1)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "- 15%", style: .default) {_ in
            self.adjustWeight(-0.15)
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "- 20%", style: .default) {_ in
            self.adjustWeight(-0.2)
        }
        alert.addAction(action)

        action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func adjustWeight(_ percent: Double) {
        let newWeight = setting.weight + setting.weight*percent
        let info = Weight.init(newWeight, setting.apparatus).closest()
        weightTextbox.text = Weight.friendlyStr(info.weight)
    }
    
    @IBAction func setDatePressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        var action = UIAlertAction(title: "One Week Ago", style: .default) {_ in
            self.weekOffset = -1
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "Two Weeks Ago", style: .default) {_ in
            self.weekOffset = -2
        }
        alert.addAction(action)
        
        action = UIAlertAction(title: "Three Weeks Ago", style: .default) {_ in
            self.weekOffset = -3
        }
        alert.addAction(action)

        action = UIAlertAction(title: "Four Weeks Ago", style: .default) {_ in
            self.weekOffset = -4
        }
        alert.addAction(action)

        action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func apparatusPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _):
            let view = storyboard.instantiateViewController(withIdentifier: "BarbellID") as! BarbellController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
            
        case .dumbbells1(weights: _, magnets: _):
            let view = storyboard.instantiateViewController(withIdentifier: "DumbbellControllerID") as! DumbbellController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .dumbbells2(weights: _, magnets: _):
            let view = storyboard.instantiateViewController(withIdentifier: "DumbbellControllerID") as! DumbbellController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .pairedPlates(plates: _):
            let view = storyboard.instantiateViewController(withIdentifier: "SinglePlatesControllerID") as! SinglePlatesController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
            
        case .singlePlates(plates: _):
            let view = storyboard.instantiateViewController(withIdentifier: "SinglePlatesControllerID") as! SinglePlatesController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)

        case .machine(range1: _, range2: _, extra: _):
            let view = storyboard.instantiateViewController(withIdentifier: "MachineID") as! MachineController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
        }
    }
    
    @IBAction func repsChanged(_ sender: Any) {
        let reps = Int(repsTextbox?.text ?? "0") ?? 0
        doneButton.isEnabled = reps > 0
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var restTextbox: UITextField!
    @IBOutlet private var weightTextbox: UITextField!
    @IBOutlet private var repsLabel: UILabel!
    @IBOutlet private var repsTextbox: UITextField!
    @IBOutlet private var doneButton: UIBarButtonItem!
    @IBOutlet private var setDateButton: UIBarButtonItem!
    
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var breadcrumb = ""
    private var weekOffset: Int? = nil
}
