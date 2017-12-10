import UIKit
import os.log

class IntensityController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: IntensitySetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Options"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        if setting != nil {
            intensityTextbox.text = setting.intensity
        }
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        intensityTextbox.resignFirstResponder()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            setting.intensity = intensityTextbox.text ?? ""
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.saveExercise(exercise.name)
        }
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var intensityTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: IntensitySetting!
    private var breadcrumb = ""
}



