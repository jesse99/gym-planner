import UIKit

class TagsTabController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        let a = Array(tags.map {tagToString($0)})
        coder.encode(a, forKey: "tags.tags")

        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)

        let a = coder.decodeObject(forKey: "tags.tags") as! [String]
        tags = Set(Array(a.map {stringToTag($0)}))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @IBAction func unwindToTags(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func stagePressed(_ sender: Any) {
        let alert = createAlert("Any Level", [.beginner, .intermediate, .advanced])
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func typePressed(_ sender: Any) {
        let alert = createAlert("Any Type", [.strength, .hypertrophy, .conditioning])
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func daysPressed(_ sender: Any) {
        let alert = createAlert("Any Number of Days", [.threeDays, .fourDays])
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func apparatusPressed(_ sender: Any) {
        let alert = createAlert("Any Apparatus", [.barbell, .dumbbell])
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sexPressed(_ sender: Any) {
        let alert = createAlert("Any Sex", [.female])
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func agePressed(_ sender: Any) {
        let alert = createAlert("Any Age", [.ageUnder40, .age40s, .age50s])
        self.present(alert, animated: true, completion: nil)
    }
    
    private func createAlert(_ noTag: String, _ tags: [Program.Tags]) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        var action = UIAlertAction(title: noTag, style: .default) {_ in
            for t in tags {
                self.tags.remove(t)
            }
            self.updateUI()
        }
        alert.addAction(action)
        
        for tag in tags {
            action = UIAlertAction(title: tagToString(tag), style: .default) {_ in
                for t in tags {
                    self.tags.remove(t)
                }
                self.tags.insert(tag)
                self.updateUI()
            }
            alert.addAction(action)
            if self.tags.contains(tag) {
                alert.preferredAction = action
            }
        }
        
        return alert
    }
    
    private func updateUI() {
        var stageText = "Any Level"
        var typeText = "Any Type"
        var daysText = "Any Number of Days"
        var apparatusText = "Any Apparatus"
        var sexText = "Any Sex"
        var ageText = "Any Age"
        
        for tag in tags {
            switch tag {
            case .beginner:     stageText = tagToString(tag)
            case .intermediate: stageText = tagToString(tag)
            case .advanced:     stageText = tagToString(tag)
            case .strength:     typeText = tagToString(tag)
            case .hypertrophy:  typeText = tagToString(tag)
            case .conditioning: typeText = tagToString(tag)
            case .barbell:      apparatusText = tagToString(tag)
            case .dumbbell:     apparatusText = tagToString(tag)
            case .threeDays:    daysText = tagToString(tag)
            case .fourDays:     daysText = tagToString(tag)
            case .female:       sexText = tagToString(tag)
            case .ageUnder40:   ageText = tagToString(tag)
            case .age40s:       ageText = tagToString(tag)
            case .age50s:       ageText = tagToString(tag)
            }
        }
        
        stageButton.setTitle(stageText + " ^", for: .normal)
        typeButton.setTitle(typeText + " ^", for: .normal)
        daysButton.setTitle(daysText + " ^", for: .normal)
        apparatusButton.setTitle(apparatusText + " ^", for: .normal)
        sexButton.setTitle(sexText + " ^", for: .normal)
        ageButton.setTitle(ageText + " ^", for: .normal)
        
        let app = UIApplication.shared.delegate as! AppDelegate
        programs = app.programs.filter {$0.tags.isSuperset(of: tags)}
        
        if programs.count == 0 {
            viewButton.setTitle("No Matching Programs", for: .normal)
            viewButton.isEnabled = false

        } else if programs.count == 1 {
            viewButton.setTitle("View 1 Program", for: .normal)
            viewButton.isEnabled = true

        } else {
            viewButton.setTitle("View \(programs.count) Programs", for: .normal)
            viewButton.isEnabled = true
        }
    }
    
    private func tagToString(_ tag: Program.Tags) -> String {
        switch tag {
        case .beginner:     return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced:     return "Advanced"
        case .strength:     return "Strength"
        case .hypertrophy:  return "Hypertrophy"
        case .conditioning: return "Conditioning"
        case .barbell:      return "Barbell"
        case .dumbbell:     return "Dumbbell"
        case .threeDays:    return "3 Days/Week"
        case .fourDays:     return "4 Days/Week"
        case .female:       return "Female"
        case .ageUnder40:   return "Under 40"
        case .age40s:       return "40s"
        case .age50s:       return "50s"
        }
    }
    
    private func stringToTag(_ str: String) -> Program.Tags {
        switch str {
        case "Beginner":        return .beginner
        case "Intermediate":    return .intermediate
        case "Advanced":        return .advanced
        case "Strength":        return .strength
        case "Hypertrophy":     return .hypertrophy
        case "Conditioning":    return .conditioning
        case "Barbell":         return .barbell
        case "Dumbbell":        return .dumbbell
        case "3 Days/Week":     return .threeDays
        case "4 Days/Week":     return .fourDays
        case "Female":          return .female
        case "Under 40":        return .ageUnder40
        case "40s":             return .age40s
        case "50s":             return .age50s
        default: frontend.assert(false, "\(str) is an unknown tag"); abort()
        }
    }
    
    @IBOutlet private var stageButton: UIButton!
    @IBOutlet private var typeButton: UIButton!
    @IBOutlet private var daysButton: UIButton!
    @IBOutlet private var apparatusButton: UIButton!
    @IBOutlet private var sexButton: UIButton!
    @IBOutlet private var ageButton: UIButton!
 
    @IBOutlet private var viewButton: UIButton!
    
    private var tags: Set<Program.Tags> = [.beginner, .strength, .ageUnder40, .barbell, .threeDays]
    private var programs: [Program] = []
}

