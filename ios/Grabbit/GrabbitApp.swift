//
//  GrabbitApp.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import SwiftUI

@main
struct GrabbitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject var mainUser: User = User.mainUser
    @StateObject var trackingViewModel = TrackingViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                switch authViewModel.state {
                case .signedOut:
                    LoginView()
                case .signedIn:
                    HomeView()
                }
            }
            .environmentObject(trackingViewModel)
            .environmentObject(mainUser)
            .environmentObject(authViewModel)
            .onAppear {
                Task {
                    await loadUser()
                }
            }
            .onChange(of: authViewModel.state) { _ in
                Task {
                    await loadUser()
                }
            }
        }
    }
    
    private func loadUser() async {
        let result = await authViewModel.authenticateUser()
        
        switch result {
        case .success(let user):
            mainUser.id = user.id
            mainUser.deviceId = user.deviceId
            mainUser.email = user.email
            mainUser.hasLimit = user.hasLimit
            mainUser.tracking = user.tracking
            
            authViewModel.state = .signedIn
        case .failure(_):
            authViewModel.state = .signedOut
            print("No user logged in.")
        }
    }
    
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure FirebaseApp
        FirebaseApp.configure()
        
        // Set Up Cloud Messaging
        Messaging.messaging().delegate = self
        
        // Set Up Notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in}
            )
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.applicationIconBadgeNumber = 0
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message
        print(userInfo)

        return UIBackgroundFetchResult.newData
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { }
    
}

// MARK: - Cloud Messaging

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        // Update token on backend
        if let userId = UserDefaults.standard.object(forKey: "userId") as? String,
           let fcmToken = fcmToken {
            Task {
                await NetworkManager.shared.updateDeviceToken(deviceId: fcmToken, userId: userId)
            }
        }
        
        // Save to UserDefaults
        UserDefaults.standard.setValue(fcmToken ?? "", forKey: "deviceId")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
}

// MARK: - User Notification

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message
        print(userInfo)

        return [[.banner, .badge, .sound]]
    }
    
}
