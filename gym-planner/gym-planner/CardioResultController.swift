import UIKit
import os.log

class CardioResultController: UIViewController {
    func initialize(_ exercise: Exercise, _ callback: @escaping CardioCompletion, _ breadcrumb: String) {
        self.exercise = exercise
        self.callback = callback
        self.breadcrumb = "\(breadcrumb) • Result"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        minsTextbox.text = ""
        caloriesTextbox.text = ""

        doneButton.isEnabled = false
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        minsTextbox.resignFirstResponder()
        caloriesTextbox.resignFirstResponder()
    }
    
    @IBAction func minsEdited(_ sender: Any) {
        let mins = Int(minsTextbox?.text ?? "-1") ?? -1
        doneButton.isEnabled = mins >= 0
    }
    
    @IBAction func donePressed(_ sender: Any) {
        let mins = Int(minsTextbox?.text ?? "0") ?? 0
        let calories = Int(caloriesTextbox?.text ?? "0") ?? 0
        callback(mins, calories)
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.saveExercise(exercise.name)
        
        self.performSegue(withIdentifier: "unwindToExerciseID", sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var minsTextbox: UITextField!
    @IBOutlet private var caloriesTextbox: UITextField!
    @IBOutlet private var doneButton: UIBarButtonItem!
    
    private var callback: CardioCompletion!
    private var exercise: Exercise!
    private var breadcrumb = ""
}



