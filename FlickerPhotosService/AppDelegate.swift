//
//  AppDelegate.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let provider = CustomReactiveMoyaProvider<FLPhotoService>()
        let viewModel = SearchPhotoViewModel(provider: provider)
        let vc = SearchPhotoController(viewModel: viewModel)
        window?.rootViewController = CustomNavigationController(rootViewController: vc)
        
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

/*https://api.flickr.com/services/rest/ ?api_key=46b9e13fa396ca1a0907717a361ba065 &api_sig=0a565d5e00d6aa90e07e7a42c1755066 &auth_token=72157683231148841-691d60d96c1f8e50 &format=json &method=flickr.photos.search &nojsoncallback=1 &page=1 &per_page=10 &text=girls */

//https://api.flickr.com/services/rest/ ?method=flickr.photos.search &api_key=46b9e13fa396ca1a0907717a361ba065 &tags=girls &text=girls &content_type=1 &per_page=10 &page=2 &format=json &nojsoncallback=1 &auth_token=72157683231148841-691d60d96c1f8e50 &api_sig=101065befdcbe1ba94398c48aa3fe2cd

