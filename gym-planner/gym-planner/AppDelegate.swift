import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FrontEnd {
    override init() {
        super.init()
        
        let path = getPath(fileName: "program_name")
        if let name = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? String {
            program = loadProgram(name)
        }
        
        if program == nil {
            os_log("failed to load program from %@", type: .info, path)
            program = HML() // TODO: use a better default
        }
        
        frontend = self
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            self.notificationsAreEnabled = granted
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveProgram(program)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func saveExercise(_ name: String) {
//        print("-----------------------------------------")
        saveProgram(program)
    }
    
    func findExercise(_ name: String) -> Exercise? {
        return program.findExercise(name)
    }

    func assert(_ predicate: Bool, _ message: String) {
        if !predicate {
            var controller = self.window?.rootViewController
            while let next = controller?.presentedViewController {
                controller = next
            }
            
            if controller != nil {
                let alert = UIAlertController(title: "Assertion failed", message: message, preferredStyle: .actionSheet)
                
                let action = UIAlertAction(title: "OK", style: .default, handler: {(_) in Swift.assert(false, message)})
                alert.addAction(action)
                
                controller!.present(alert, animated: true, completion:nil)
            } else {
                Swift.assert(false, message)
            }
        }
    }
    
    func scheduleTimerNotification(_ fireDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Finished resting."
        content.body = ""
        content.sound = UNNotificationSound.default()
        
        let time = fireDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: "FinishedResting", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    private func loadProgram(_ name: String) -> Program? {
//        print("-----------------------------------------")
        let path = getPath(fileName: "program2-" + name)
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let store = try decoder.decode(Store.self, from: data)
//                print("---- json ---------------------------------------")
//                print(String(data: data, encoding: .utf8)!)
//
//                print("---- loading ---------------------------------------")
//                print(store)
                return Program(from: store)
            } catch {
                os_log("failed to decode program from %@: %@", type: .error, path, error.localizedDescription)
            }
        } else {
            os_log("failed to unarchive program from %@", type: .error, path)
        }
        return nil
    }
    
    private func saveProgram(_ program: Program) {
        var path = getPath(fileName: "program_name")
        saveObject(program.name as AnyObject, path)

        path = getPath(fileName: "program2-" + program.name)
        let store = Store()
        program.save(store)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        //encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(store)
//            print("---- saving ---------------------------------------")
//            print(store)
            saveObject(data as AnyObject, path)
        } catch {
            os_log("Error encoding program %@: %@", type: .error, program.name, error.localizedDescription)
        }
    }
    
    private func saveObject(_ object: AnyObject, _ path: String)
    {
        if NSKeyedArchiver.archiveRootObject(object, toFile: path) {
            //print("saved \(name) to \(path)")
        } else {
            os_log("failed to save to %@", type: .error, path)
        }
    }
    
    private func getPath(fileName: String) -> String {
        let dirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = dirs.first!
        let name = sanitizeFileName(fileName)
        let url = dir.appendingPathComponent("\(name).archive")
        return url.path
    }
    
    
    private func sanitizeFileName(_ name: String) -> String {
        var result = ""
        
        for ch in name {
            switch ch {
            // All we really should have to re-map is "/" but other characters can be annoying
            // in file names so we'll zap those too. List is from:
            // https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
            case "/", "\\", "?", "%", "*", ":", "|", "\"", "<", ">", ".", " ":
                result += "_"
            default:
                result.append(ch)
            }
        }
        
        return result
    }

    var window: UIWindow?
    var notificationsAreEnabled = false
    var program: Program!
}
