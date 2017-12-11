import UIKit
import os.log

class HIITIntensityController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: HIITSetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Intensity"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        if setting != nil {
            warmupTextbox.text = setting.warmupIntensity
            highTextbox.text = setting.highIntensity
            lowTextbox.text = setting.lowIntensity
            cooldownTextbox.text = setting.cooldownIntensity
        }
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        warmupTextbox.resignFirstResponder()
        highTextbox.resignFirstResponder()
        lowTextbox.resignFirstResponder()
        cooldownTextbox.resignFirstResponder()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.warmupIntensity = warmupTextbox?.text ?? ""
            setting.highIntensity = highTextbox?.text ?? ""
            setting.lowIntensity = lowTextbox?.text ?? ""
            setting.cooldownIntensity = cooldownTextbox?.text ?? ""
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.saveExercise(exercise.name)
        }
        
        self.performSegue(withIdentifier: "unwindToHIITID", sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    
    @IBOutlet private var warmupTextbox: UITextField!
    @IBOutlet private var highTextbox: UITextField!
    @IBOutlet private var lowTextbox: UITextField!
    @IBOutlet private var cooldownTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: HIITSetting!
    private var breadcrumb = ""
}





