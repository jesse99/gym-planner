import UIKit
import os.log

class MachineController: UIViewController {
    func initialize(_ exercise: Exercise, _ setting: VariableWeightSetting, _ breadcrumb: String) {
        self.exercise = exercise
        self.setting = setting
        self.breadcrumb = "\(breadcrumb) • Machine"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        
        if setting != nil {
            switch setting.apparatus {
            case .machine(range1: let range1, range2: let range2, extra: let extra):
                min1Textbox.text = Weight.friendlyStr(range1.min)
                max1Textbox.text = Weight.friendlyStr(range1.max)
                step1Textbox.text = Weight.friendlyStr(range1.step)

                min2Textbox.text = Weight.friendlyStr(range2.min)
                max2Textbox.text = Weight.friendlyStr(range2.max)
                step2Textbox.text = Weight.friendlyStr(range2.step)
                
                let e = extra.map {Weight.friendlyStr($0)}
                extraTextbox.text = e.joined(separator: ", ")
            default:
                frontend.assert(false, "MachineController was called without a barbell")
            }
        }
        doneButton.isEnabled = true
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        if setting != nil {
            extraTextbox.resignFirstResponder()

            min1Textbox.resignFirstResponder()
            max1Textbox.resignFirstResponder()
            step1Textbox.resignFirstResponder()

            min2Textbox.resignFirstResponder()
            max2Textbox.resignFirstResponder()
            step2Textbox.resignFirstResponder()
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if setting != nil {
            switch setting.apparatus {
            case .machine(range1: _, range2: _, extra: _):
                if let range1 = getRange(minTextbox: min1Textbox, maxTextbox: max1Textbox, stepTextbox: step1Textbox) {
                    if let range2 = getRange(minTextbox: min2Textbox, maxTextbox: max2Textbox, stepTextbox: step2Textbox) {
                        if let extra = getExtra() {
                            setting.apparatus = .machine(range1: range1, range2: range2, extra: extra)
                        }
                    }
                }
            default:
                frontend.assert(false, "MachineController was called without a barbell")
            }
        }
        
        self.performSegue(withIdentifier: "unwindToVariableWeightID", sender: self)
    }
    
    @IBAction func textEdited(_ sender: Any) {
        if let range1 = getRange(minTextbox: min1Textbox, maxTextbox: max1Textbox, stepTextbox: step1Textbox) {
            if getRange(minTextbox: min2Textbox, maxTextbox: max2Textbox, stepTextbox: step2Textbox) != nil {
                if getExtra() != nil {
                    doneButton.isEnabled = range1.step > 0
                    return
                }
            }
        }
        doneButton.isEnabled = false
    }
    
    private func getRange(minTextbox: UITextField, maxTextbox: UITextField, stepTextbox: UITextField) -> MachineRange? {
        if let minText = minTextbox.text, let min = Double(minText) {
            if let maxText = maxTextbox.text, let max = Double(maxText) {
                if let stepText = stepTextbox.text, let step = Double(stepText) {
                    if min <= max && step >= 0.0 {
                        return MachineRange(min: min, max: max, step: step)
                    }
                }
            }
        }
        return nil
    }
    
    private func getExtra() -> [Double]? {
        if var extraText = extraTextbox.text {
            var extra: [Double] = []
            extraText = extraText.replacingOccurrences(of: " ", with: "")
            let parts = extraText.split(separator: ",")
            
            for part in parts {
                if let weight = Double(part) {
                    extra.append(weight)
                } else {
                    return nil
                }
            }
            return extra
        }
        return nil
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var extraTextbox: UITextField!
    @IBOutlet private var doneButton: UIBarButtonItem!
    
    @IBOutlet private var min1Textbox: UITextField!
    @IBOutlet private var max1Textbox: UITextField!
    @IBOutlet private var step1Textbox: UITextField!

    @IBOutlet private var min2Textbox: UITextField!
    @IBOutlet private var max2Textbox: UITextField!
    @IBOutlet private var step2Textbox: UITextField!

    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var breadcrumb = ""
}
