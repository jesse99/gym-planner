import UIKit
import os.log

class MarkdownController: UIViewController, UITextViewDelegate {
    func initialize(_ markup: String, _ breadcrumb: String, _ unwindTo: String) {
        self.markup = markup
        self.breadcrumb = breadcrumb
        self.unwindTo = unwindTo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        breadcrumbLabel.text = breadcrumb
        textView.delegate = self

        let markdown = SwiftyMarkdown(string: markup)
        let text = markdown.attributedString()
        textView.textStorage.setAttributedString(text)
    }
    
    override func viewDidLayoutSubviews() {
        // So the text is scrolled to the top when the screen loads.
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.performSegue(withIdentifier: unwindTo, sender: self)
    }
    
    @IBOutlet private var breadcrumbLabel: UILabel!
    @IBOutlet private var textView: UITextView!
    
    private var markup = ""
    private var breadcrumb = ""
    private var unwindTo = ""
}






