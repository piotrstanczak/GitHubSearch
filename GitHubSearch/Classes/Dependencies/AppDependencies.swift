//
//  AppDependencies.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit

/// App dependencies that later will be injected into proper VM
class AppDependencies {
    private lazy var network = NetworkManager(urlSession: .shared)
    private lazy var storage = StorageManager(with: UserDefaults.standard)
}

extension AppDependencies: CoordinatorFactory {
    
    func coordinator<N, F, R, C: Coordinator<N, F, R>>(for type: C.Type, with navigator: N) -> C {
        switch type {
            
        case is AppCoordinator.Type:
            return AppCoordinator(navigator: navigator as! UIWindow, factory: self) as! C
            
        case is SplashCoordinator.Type:
            return SplashCoordinator(navigator: navigator as! UIWindow, factory: self) as! C
            
        case is RepoListCoordinator.Type:
            return RepoListCoordinator(navigator: navigator as! UIWindow, factory: self) as! C            
            
        default:
            fatalError("It should be implemented")
        }
    }
}

extension AppDependencies: ViewControllerFactory {
        
    func viewController<T: ViewModelInjectable & ViewConfigurable, S>(for type: T.Type, viewModel: S? = nil) -> T where S == T.ViewModelType {
        switch type {
        case is SplashViewController.Type:
            let splashViewController = SplashViewController()
            splashViewController.viewModel = SplashViewModel()
            splashViewController.config = SplashViewConfig()
            return splashViewController as! T
            
        case is RepoListViewController.Type:
            let viewController = RepoListViewController()
            viewController.viewModel = RepoListViewModel(networking: self.network, storage: self.storage)
            viewController.config = RepoListConfig()
            return viewController as! T
            
        case is RepoDetailViewController.Type:
            let viewController = RepoDetailViewController()
            (viewModel as? RepoViewModel)?.network = self.network
            viewController.viewModel = viewModel as? RepoViewModel
            viewController.config = RepoDetailViewConfig()
            return viewController as! T
            
        default:
            fatalError("It should be implemented")
        }
    }
}
