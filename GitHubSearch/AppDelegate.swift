//
//  AppDelegate.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 02/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let appDependencies = AppDependencies()
    private var appCoordinator: AppCoordinator!
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupRootView()
        
        return true
    }
    
    private func setupRootView() {
        let window = UIWindow(frame: UIScreen.main.bounds)
                
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        appCoordinator = appDependencies.coordinator(for: AppCoordinator.self, with: window)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        self.window = window
    }
}




