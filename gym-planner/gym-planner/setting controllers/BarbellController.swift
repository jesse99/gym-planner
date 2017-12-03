import UIKit
import os.log

class BarbellController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: VariableWeightSetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Barbell"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: let bar, collar: let collar, plates: _, bumpers: _, magnets: _, warmupsWithBar: _):
                collarTextbox.text = Weight.friendlyStr(collar)
                barTextbox.text = Weight.friendlyStr(bar)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    @IBAction func unwindToBarbell(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        if setting != nil {
            collarTextbox.resignFirstResponder()
            barTextbox.resignFirstResponder()
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: let oldPlates, bumpers: let oldBumpers, magnets: let oldMagnets, warmupsWithBar: let oldWarmups):
                setting.apparatus = .barbell(
                    bar: Double(barTextbox.text!)!,
                    collar: Double(collarTextbox.text!)!,
                    plates: oldPlates,
                    bumpers: oldBumpers,
                    magnets: oldMagnets,
                    warmupsWithBar: oldWarmups)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
        
        self.performSegue(withIdentifier: "unwindToVariableWeightID", sender: self)
    }
    
    @IBAction func platesPressed(_ sender: Any) {
        // TODO
    }
    
    @IBAction func bumpersPressed(_ sender: Any) {
        // TODO
    }
    
    @IBAction func magnetsPressed(_ sender: Any) {
        // TODO
    }
    
    @IBOutlet var breadcrumbLabel: UILabel!
    @IBOutlet var collarTextbox: UITextField!
    @IBOutlet var barTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var breadcrumb = ""
}




