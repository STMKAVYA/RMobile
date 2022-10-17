//
//  AppDelegate.swift
//  RMobileV1
//
//  Created by Steerminds Pvt Ltd on 13/03/18.
//  Copyright © 2018 Steerminds Pvt Ltd. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    //true for production
    static var isConnectedToProduction = false
    
    var bundal : Bundle?
    
    var deviceTokenString: String = ""
    
    static let sharedInstance = AppDelegate()
    
    func getLanguageBundle() -> Bundle{
            return createBundlePath()
    }
    func selLanguageBundle(bundal : Bundle){
        self.bundal = bundal
    }
    func createBundlePath() -> Bundle{
        if UserDefaults.standard.string(forKey: "language") == "en"{
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        if UserDefaults.standard.string(forKey: "language") == "de"{
            let path = Bundle.main.path(forResource: "de", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        if UserDefaults.standard.string(forKey: "language") == "es"{
            let path = Bundle.main.path(forResource: "es", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        if UserDefaults.standard.string(forKey: "language") == "sv"{
            let path = Bundle.main.path(forResource: "sv", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        if UserDefaults.standard.string(forKey: "language") == "nn-NO"{
            let path = Bundle.main.path(forResource: "nn-NO", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        else{
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            let bundal = Bundle.init(path: path!)! as Bundle
            return bundal
        }
        
        
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tokenString  = UserDefaults.standard.string(forKey: "accessToken")
        let dateString = UserDefaults.standard.string(forKey: "usebyDate")
        
        //Notifications Registration
        self.registerForPushNotifications()
        //askPermission(application : application)
        
        // set the delegate in didFinishLaunchingWithOptions
        UNUserNotificationCenter.current().delegate = self
        
        //MARK:- Token and expiry Date
        if tokenString != nil && dateString != nil{
            print("token String")
            let dateString1 = UserDefaults.standard.string(forKey: "usebyDate")
            //UserDefaults.standard.removeObject(forKey: "userProfileDetails")

            let expiryDate :Date!
            //Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            expiryDate = dateFormatter.date(from: dateString1!)
            print(expiryDate  ?? "")
            
            let date1 = Date()
            let formatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let currentString = formatter.string(from: date1) // Convert string to date
            let dateFormatter1 = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let currentDate = dateFormatter1.date(from: currentString) //convert date format
//            print("currentDate" )
          
            let dateComparisionResult:ComparisonResult = currentDate!.compare(expiryDate)
            if dateComparisionResult == ComparisonResult.orderedAscending
            {
                let alert = UIAlertController(title: "Test", message:"Message", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                
                navigateToDashboard()
                //print("Seesion Expired!")
            }
            else if dateComparisionResult == ComparisonResult.orderedDescending
            {
                //print("Current date is greater than expiry date")
            }
            else if dateComparisionResult == ComparisonResult.orderedSame
            {
                //print("Current date and expiry date are same")
            }
            
//            if currentDate! > expiryDate {
//                print("session ok")
//               //self.showAlert(message: "Session Expired!", buttonTitle: "Retry")
//                let DashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardVC") as! dashBoardViewController
//                self.window?.rootViewController = DashboardVC
//            }
//            else if currentDate! == expiryDate {
//                print("sesion Expired")
//            }
//
            else{
                // Delete Token/
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "accessToken")
                
                
                
                    DispatchQueue.main.async {
                        self.navigateToDashboard()
                    }
            }
        }else {
            
                DispatchQueue.main.async {
                        let loginVC: ViewController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                        //loginVC.deviceTokenString = self.deviceTokenString
                        self.window?.rootViewController = loginVC
                }
                //self.window?.rootViewController = loginVC
                UserDefaults.standard.removeObject(forKey: "language")
            }
        
        if launchOptions != nil{
            let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification]
            if userInfo != nil {
                // Perform action here
                print("PAYLOAD")
                
            }
        }
        return true
    }
    func navigateToDashboard(){
        if iscomplexTypeLogin(role: UserDefaults.standard.value(forKey: "roles") as! String){
            let complexDashboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComplexDashboardVC") as! ComplexDashboardVC
            //DashboardVC.deviceTokenString = self.deviceTokenString
            self.window?.rootViewController = complexDashboard
        }else{
            let simpleDashboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashBoardViewController1") as! dashBoardViewController
            //DashboardVC.deviceTokenString = self.deviceTokenString
            self.window?.rootViewController = simpleDashboard
        }
    }
    func showViewController(id: String){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: id) as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.fgfgedafsddfgdgajsjdfkjjfkds
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PasswordChange"), object: nil)
        if DBManager.shared.createDatabase()
        {
            print("DATABASE AND 3 TABLES CREATED SUCCESSFULLY.")
        }else{
            print("UNABLE TO CREATE DATABASE AND TABLES DUE TO SOME ERROR")
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserDefaults.standard.removeObject(forKey: "userProfileDetails")
        /////UserDefaults.standard.removeObject(forKey: "language")
    }
    
    //when user tap on the notification which is received
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /*print("RECEIVED THE NOTIFICATION")
        print(userInfo.description)
        let apsNotification = userInfo["aps"] as? NSDictionary
        let apsString = apsNotification?["alert"] as? String

        let alert = UIAlertController(title: "Fetch CompletionHandler", message: apsString, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("OK")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            print("Cancel")
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        var currentViewController = self.window?.rootViewController
        while currentViewController?.presentedViewController != nil {
            currentViewController = currentViewController?.presentedViewController
        }
        currentViewController?.present(alert, animated: true) {}*/
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
        //self.messageBox(titleMessage: "didreceive response", messageText: "withcompletion handler")
        //write your action here
    }

    
    //executes when the app is in foreground and receives the notification "shows the notification on top"
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
       // let oldToken = UserDefaultUtil.getString(key: "apns_device_token")
        
        let oldToken = UserDefaultsUtil.getString(key: "apns_device_token")
        if (oldToken == "" || oldToken == nil) //&& (oldToken != token)
        {
            //self.messageBox(titleMessage: "APN'S DEVICE TOKEN RECEIVED", messageText: token)
            UserDefaultsUtil.storeString(key : "apns_device_token" , value : token)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeviceTokenReceived"), object: nil)
        }else if (oldToken != token) {
            //self.messageBox(titleMessage: "APN'S DEVICE TOKEN", messageText: "BORH THE TOKEN'S ARE DIFFERENT, HENCE REMOVING THE REGISTRATION ID AND FETCHING AGAIN")
            UserDefaults.standard.removeObject(forKey: "apns_device_token")
            UserDefaults.standard.removeObject(forKey: AppConstant.REGISTRATION_ID)
            
            UserDefaultsUtil.storeString(key : "apns_device_token" , value : token)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeviceTokenReceived"), object: nil)
        }else{
            //self.messageBox(titleMessage: "APN'S DEVICE TOKEN", messageText: "BORH THE TOKEN'S ARE SAME")
            print("Nothing to change")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeviceTokenReceived"), object: nil)
        }
        
    }
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: ", error.localizedDescription)
        application.registerForRemoteNotifications()
    }
    
    func messageBox(titleMessage:String, messageText:String)
    {
        let alert = UIAlertController.init(title: titleMessage, message: messageText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("OK")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            print("Cancel")
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        var currentViewController = self.window?.rootViewController
        while currentViewController?.presentedViewController != nil {
            currentViewController = currentViewController?.presentedViewController
        }
        
        currentViewController?.present(alert, animated: true) {}

    }
    
    /*func askPermission(application : UIApplication)
    {
        if #available(iOS 10.0, *)
        {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }else{
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings.init(types: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(pushNotificationSettings)
        }
        //application.registerForRemoteNotifications()
        
    }*/
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        /*if application.applicationState == .active {
            //write your code here when app is in foreground
            let apsNotification = userInfo["aps"] as? NSDictionary
            let apsString = apsNotification?["alert"] as? String
            
            let alert = UIAlertController(title: "Foreground", message: apsString, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                print("OK")
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                print("Cancel")
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            var currentViewController = self.window?.rootViewController
            while currentViewController?.presentedViewController != nil {
                currentViewController = currentViewController?.presentedViewController
            }
            currentViewController?.present(alert, animated: true) {}
        } else {
            //write your code here for other state
            let apsNotification = userInfo["aps"] as? NSDictionary
            let apsString = apsNotification?["alert"] as? String
            
            let alert = UIAlertController(title: "OtherState", message: apsString, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                print("OK")
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                print("Cancel")
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            var currentViewController = self.window?.rootViewController
            while currentViewController?.presentedViewController != nil {
                currentViewController = currentViewController?.presentedViewController
            }
            currentViewController?.present(alert, animated: true) {}
        }*/
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
            
            //Set The Default Reminder Time for LOCAL Notifications
            let time = UserDefaults.standard.integer(forKey: AppConstant.REMINDER_TIME)
            if time == 0
            {
                UserDefaults.standard.set(5, forKey: AppConstant.REMINDER_TIME)
            }else{}
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    
}


