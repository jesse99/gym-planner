import UIKit

class EditWeightedHistoryController: UIViewController {
    func initialize(_ exercise: Exercise, _ result: WeightedResult, _ breadcrumb: String) {
        self.exercise = exercise
        self.result = result
        self.missed = result.missed
        self.breadcrumb = "\(breadcrumb) • Edit"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        dismissTooltip()

        breadcrumbLabel.text = breadcrumb
        weightTextbox.text = Weight.friendlyStr(result.getWeight())
        primaryLabel.text = result.primary ? "primary" : ""
        updateMissed()
    }
    
    //    func onBackColorChanged()
    //    {
    //        view.backgroundColor = targetColor(.background)
    //        view.setNeedsDisplay()
    //    }
        
    @IBAction func donePressed(_ sender: Any) {
        let weight = Double(weightTextbox.text!)!
        switch findApparatus(exercise.name) {
        case .right(let apparatus):
            let info = Weight(weight, apparatus).closest()
            result.changeWeight(info)

        case .left(_):
            let info = Weight.Info(weight: weight, text: Weight.friendlyUnitsStr(weight, plural: true), plates: "")
            result.changeWeight(info)
        }
        result.missed = missed
        frontend.saveExercise(exercise.name)

        self.performSegue(withIdentifier: "unwindToWeightedHistoryID", sender: self)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToWeightedHistoryID", sender: self)
    }
    
    @IBAction func pressedMissed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        var action = UIAlertAction(title: "Finished OK", style: .default) {_ in
            self.missed = false
            self.updateMissed()
        }
        alert.addAction(action)
        if !missed {
            alert.preferredAction = action
        }
        
        action = UIAlertAction(title: "Missed a rep", style: .default) {_ in
            self.missed = true
            self.updateMissed()
        }
        alert.addAction(action)
        if missed {
            alert.preferredAction = action
        }

        action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapped(_ sender: Any) {
        weightTextbox.resignFirstResponder()
    }
    
    private func updateMissed() {
        if missed {
            missedButton.setTitle("Missed a rep ^", for: UIControlState())
        } else {
            missedButton.setTitle("Finished OK ^", for: UIControlState())
        }
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var missedButton: UIButton!
    @IBOutlet private var weightTextbox: UITextField!
    @IBOutlet private var primaryLabel: UILabel!
    
    private var exercise: Exercise!
    private var result: WeightedResult!
    private var missed = false
    private var breadcrumb = ""
}



