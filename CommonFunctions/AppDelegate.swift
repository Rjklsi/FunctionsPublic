//
//  AppDelegate.swift
//  CommonFunctions
//
//  Created by mac on 03/05/21.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


//Global appdelegate instance
    static var appDelegate: AppDelegate!
    override init() {
        super.init()
        AppDelegate.appDelegate = self
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      //************
        ///read notifications when app open
        if ((launchOptions) != nil) {
            if  let userinfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any]{
                if let apsinfo = userinfo["aps"] as? NSDictionary {
                if let alert = apsinfo["alert"] as? NSDictionary{
                if let message = alert["body"] as? String {
                            print(message)
                          //Navigate to notificationVC
                }
                }
                }
            }
        }
        //*****************
        ///localization
        //language handle
       
        
        
        
        
        
        ///setups
        // Override point for customization after application launch.
        //**************
        //google map
        GMSServices.provideAPIKey("AIzaSyCam7dReq6rh4wNMWmHnE3NSHGIRLn31a8")
        //*************
        //iqkeyboard
        IQKeyboardManager.shared.enable = true
        //location
        LocationManager.shared.requestAndFetchLocation()
        //****************
        //push notification setup
            FirebaseApp.configure()
                FirebaseConfiguration.shared.setLoggerLevel(.min)
                Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
                
                //push notification
                //MARK: firebase and push notification
               // FirebaseApp.configure()
                
                // [START set_messaging_delegate]
                Messaging.messaging().delegate = self
                // [END set_messaging_delegate]
                // Register for remote notifications. This shows a permission dialog on first run, to
                // show the dialog at a more appropriate time move this registration accordingly.
                // [START register_for_notifications]
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self
                    
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_, _ in })
                } else {
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                }
                
                application.registerForRemoteNotifications()
                
                //get application instance ID
                InstanceID.instanceID().instanceID { (result, error) in
                     if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                    } else if let result = result {
                        print("Remote instance ID token: \(result.token)")
                        self.deviceToken = result.token  as String
                    }
                }
                
        //**************
        
        
        
        
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    //push notification setup
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) {
                    granted, error in
            }
        } else {
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Recived: \(userInfo)")
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print("Recived: \(userInfo)")
    }
}

@available(iOS 10.0, *)
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        self.deviceToken = "\(fcmToken!)"
        //Messaging.messaging().shouldEstablishDirectChannel = true
        
        let dataDict:[String: String] = ["token": fcmToken!]
        print(dataDict)
        
        UserDefaults.standard.set(fcmToken, forKey: "FcmToken")
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
//        print("Received data message: \(remoteMessage.appData)")
//        let userInfo = remoteMessage.appData
//        print(userInfo)
        print("Received data message: \(remoteMessage.description)")
       }
    }
    // [END ios_10_data_message]

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        print(userInfo)
        completionHandler([.alert])
    }
    
    
}


