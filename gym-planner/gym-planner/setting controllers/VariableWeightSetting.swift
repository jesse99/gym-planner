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

        if setting != nil {
            restTextbox.text = secsToStr(setting.restSecs)
            weightTextbox.text = Weight.friendlyStr(setting.weight)
        }
    }
    
    @IBAction func unwindToVariableWeight(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        if setting != nil {
            restTextbox.resignFirstResponder()
            weightTextbox.resignFirstResponder()
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.changeWeight(Double(weightTextbox.text!)!)  // TODO: use something like toWeight
            
            if let text = restTextbox.text, let value = strToSecs(text) {
                setting.restSecs = value
            }
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.saveExercise(exercise.name)
        }
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBAction func apparatusPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: _):
            let view = storyboard.instantiateViewController(withIdentifier: "BarbellID") as! BarbellController
            view.initialize(exercise, setting, breadcrumbLabel.text!)
            present(view, animated: true, completion: nil)
            
        case .dumbbells(weights: _, magnets: _):
            break   // TODO:
        }
    }
    
    @IBOutlet var breadcrumbLabel: UILabel!
    @IBOutlet var restTextbox: UITextField!
    @IBOutlet var weightTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var breadcrumb = ""
}



