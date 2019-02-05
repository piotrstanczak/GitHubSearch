//
//  SplashCoordinator.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift

class SplashCoordinator: Coordinator<UIWindow, CoordinatorFactory & ViewControllerFactory, Empty> {
    
    private let disposeBag = DisposeBag()
    
    override func start() -> Observable<Completion> {
        
        let viewController = factory.viewController(for: SplashViewController.self, viewModel: nil)
        
        navigator.rootViewController = viewController
        navigator.makeKeyAndVisible()
        
        return viewController.viewModel?.completed ?? .never()
    }
}
