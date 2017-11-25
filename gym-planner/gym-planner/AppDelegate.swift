import UIKit
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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
        //saveResults()   // this shouldn't take longer than 5s
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
    
    private func getPath(fileName: String) -> String {
        let dirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = dirs.first!
        let name = sanitizeFileName(fileName)
        let url = dir.appendingPathComponent("\(name).archive")
        return url.path
    }
    
    
    fileprivate func sanitizeFileName(_ name: String) -> String {
        var result = ""
        
        for ch in name {
            switch ch {
            // All we really should have to re-map is "/" but other characters can be annoying
            // in file names so we'll zap those too. List is from
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
}
