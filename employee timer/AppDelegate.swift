//
//  AppDelegate.swift
//  employee timer
//
//  Created by אורי עינת on 3.9.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isLoggedIn:Bool?
    //keep variables
    let keeper = UserDefaults.standard

    override init() {
        
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        RebeloperStore.shared.start()
      
        FBSDKApplicationDelegate.sharedInstance().application(<#T##application: UIApplication!##UIApplication!#>, didFinishLaunchingWithOptions: launchOptions)
        
        //FIRApp.configure()
        // Override point for customization after application launch.
        let currentUser = FIRAuth.auth()?.currentUser
        print (currentUser as Any)

        if currentUser != nil { isLoggedIn = true; } else {  isLoggedIn = false}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController  =  storyboard.instantiateViewController(withIdentifier: "loginScreen")
        let homeViewController  =  storyboard.instantiateViewController(withIdentifier: "homeScreen")
        print(isLoggedIn!,keeper.integer(forKey: "remember"))
        if isLoggedIn == true && keeper.integer(forKey: "remember") == 1 {
            self.window?.rootViewController = homeViewController
            //self.window?.rootViewController = loginViewController
            
            

        } else {
            self.window?.rootViewController = loginViewController
            
        }
 

    return true
        

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
        let handlded = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: [UIApplicationOpenURLOptionsKey.annotation])
        
        }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //try! FIRAuth.auth()!.signOut()
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

   


    
}

