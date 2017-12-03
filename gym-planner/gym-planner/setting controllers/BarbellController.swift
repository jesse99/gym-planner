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
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: let plates, bumpers: _, magnets: _, warmupsWithBar: _):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "WeightsID") as! WeightsController
                view.initialize(
                    available: availablePlates(),
                    used: plates,
                    emptyOK: false,
                    {self.updatePlates($0)},
                    breadcrumbLabel.text! + " • Plates",
                    "unwindToBarbellID")
                present(view, animated: true, completion: nil)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    @IBAction func bumpersPressed(_ sender: Any) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: _, bumpers: let bumpers, magnets: _, warmupsWithBar: _):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "WeightsID") as! WeightsController
                view.initialize(
                    available: availableBumpers(),
                    used: bumpers,
                    emptyOK: true,
                    {self.updateBumpers($0)},
                    breadcrumbLabel.text! + " • Bumpers",
                    "unwindToBarbellID")
                present(view, animated: true, completion: nil)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    @IBAction func magnetsPressed(_ sender: Any) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: let magnets, warmupsWithBar: _):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let view = storyboard.instantiateViewController(withIdentifier: "WeightsID") as! WeightsController
                view.initialize(
                    available: availableMagnets(),
                    used: magnets,
                    emptyOK: true,
                    {self.updateMagnets($0)},
                    breadcrumbLabel.text! + " • Magnets",
                    "unwindToBarbellID")
                present(view, animated: true, completion: nil)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    private func updatePlates(_ newPlates: [Double]) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: let oldBar, collar: let oldCollar, plates: _, bumpers: let oldBumpers, magnets: let oldMagnets, warmupsWithBar: let oldWarmups):
                setting.apparatus = .barbell(
                    bar: oldBar,
                    collar: oldCollar,
                    plates: newPlates,
                    bumpers: oldBumpers,
                    magnets: oldMagnets,
                    warmupsWithBar: oldWarmups)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    private func updateBumpers(_ newBumpers: [Double]) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: let oldBar, collar: let oldCollar, plates: let oldPlates, bumpers: _, magnets: let oldMagnets, warmupsWithBar: let oldWarmups):
                setting.apparatus = .barbell(
                    bar: oldBar,
                    collar: oldCollar,
                    plates: oldPlates,
                    bumpers: newBumpers,
                    magnets: oldMagnets,
                    warmupsWithBar: oldWarmups)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    private func updateMagnets(_ newMagnets: [Double]) {
        if setting != nil {
            switch setting.apparatus {
            case .barbell(bar: let oldBar, collar: let oldCollar, plates: let oldPlates, bumpers: let oldBumpers, magnets: _, warmupsWithBar: let oldWarmups):
                setting.apparatus = .barbell(
                    bar: oldBar,
                    collar: oldCollar,
                    plates: oldPlates,
                    bumpers: oldBumpers,
                    magnets: newMagnets,
                    warmupsWithBar: oldWarmups)
            default:
                frontend.assert(false, "BarbellController was called without a barbell")
            }
        }
    }
    
    @IBOutlet var breadcrumbLabel: UILabel!
    @IBOutlet var collarTextbox: UITextField!
    @IBOutlet var barTextbox: UITextField!
    
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var breadcrumb = ""
}




