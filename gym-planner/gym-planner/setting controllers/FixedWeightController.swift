import UIKit
import os.log

class FixedWeightController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: FixedWeightSetting, _ breadcrumb: String) {
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
            case .fixedWeight(let setting): self.setting = setting
            default: os_log("%@ isn't using fixed weight", type: .error, name)
            }
        } else {
            os_log("couldn't load exercise '%@' for program '%@'", type: .error, name, app.program.name)
        }
        
        super.decodeRestorableState(with: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
        if setting != nil {
            restTextbox.text = secsToStr(setting.restSecs)
            weightTextbox.text = Weight.friendlyStr(setting.weight)
        }
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        if setting != nil {
            restTextbox.resignFirstResponder()
            weightTextbox.resignFirstResponder()
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.weight = Double(weightTextbox.text!)! // TODO: use something like toWeight
            
            if let text = restTextbox.text, let value = strToSecs(text) {
                setting.restSecs = value
            }
        }
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var restTextbox: UITextField!
    @IBOutlet private var weightTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: FixedWeightSetting!
    private var breadcrumb = ""
}


