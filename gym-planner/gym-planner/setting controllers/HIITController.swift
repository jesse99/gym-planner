import UIKit
import os.log

class HIITController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: HIITSetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Options"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        if setting != nil {
            numCyclesTextbox.text = String(setting.numCycles)

            warmupTextbox.text = secsToStr(setting.warmupSecs)
            highTextbox.text = secsToStr(setting.highSecs)
            lowTextbox.text = secsToStr(setting.lowSecs)
            cooldownTextbox.text = secsToStr(setting.cooldownSecs)
        }
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        numCyclesTextbox.resignFirstResponder()

        warmupTextbox.resignFirstResponder()
        highTextbox.resignFirstResponder()
        lowTextbox.resignFirstResponder()
        cooldownTextbox.resignFirstResponder()
    }
    
    @IBAction func textEdited(_ sender: Any) {
        let numCycles = Int(numCyclesTextbox?.text ?? "0") ?? 0
        let highSecs = strToSecs(highTextbox?.text ?? "0") ?? 0
        let lowSecs = strToSecs(lowTextbox?.text ?? "0") ?? 0
        
        // Warmup and cooldown are optional
        doneButton.isEnabled = numCycles > 0 && highSecs > 0 && lowSecs > 0
    }
    
    @IBAction func intensityPressed(_ sender: Any) {
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.warmupSecs = strToSecs(warmupTextbox?.text ?? "0") ?? 0
            setting.cooldownSecs = strToSecs(cooldownTextbox?.text ?? "0") ?? 0

            if let text = numCyclesTextbox.text, let value = Int(text) {
                setting.numCycles = value
            }
            if let text = highTextbox.text, let value = strToSecs(text) {
                setting.highSecs = value
            }
            if let text = lowTextbox.text, let value = strToSecs(text) {
                setting.lowSecs = value
            }
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.saveExercise(exercise.name)
        }
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var numCyclesTextbox: UITextField!
    @IBOutlet private var doneButton: UIBarButtonItem!
    
    @IBOutlet private var warmupTextbox: UITextField!
    @IBOutlet private var highTextbox: UITextField!
    @IBOutlet private var lowTextbox: UITextField!
    @IBOutlet private var cooldownTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: HIITSetting!
    private var breadcrumb = ""
}




