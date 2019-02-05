//
//  ListCoordinator.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift

enum RepoListReturnType {
    case detail(RepoViewModel)
}

class RepoListCoordinator: Coordinator<UIWindow, CoordinatorFactory & ViewControllerFactory, RepoListReturnType> {
    
    private let disposeBag = DisposeBag()
    
    override func start() -> Observable<Completion> {
        
        let viewController = factory.viewController(for: RepoListViewController.self, viewModel: nil)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewController.viewModel?.selected.asObservable()
            .subscribe(onNext: { [weak self] viewModel in
                self?.showRepoDetailViewController(with: viewModel)
            })
            .disposed(by: disposeBag)
        
        navigator.rootViewController = navigationController
        
        UIView.transition(with: navigator,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
        
        return .never()
    }
        
    private func showRepoDetailViewController(with viewModel: RepoViewModel) {
        let viewController = factory.viewController(for: RepoDetailViewController.self, viewModel: viewModel)
        (navigator.rootViewController as? UINavigationController)?.show(viewController, sender: nil)
    }

}
