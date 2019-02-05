//
//  SplashViewController.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit
import RxSwift
import Lottie

class SplashViewController: UIViewController, ViewModelInjectable, ViewConfigurable {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    var viewModel: SplashViewModel?
    var config: SplashViewConfig?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let config = config else { return }
        
        setupView(with: config)
    }
    
    // MARK: - View setup
    
    private func setupView(with config: SplashViewConfig) {
        view.backgroundColor = config.backgroundColor
        addLoadingAnimation(with: config.animationName)
    }
    
    private func addLoadingAnimation(with animationName: String) {
        
        view.backgroundColor = UIColor(rgb: 0xe8e8e8)
        
        let animationView = LOTAnimationView(name: animationName)
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        animationView.play{ [weak self] (finished) in
            self?.viewModel?.completed.onNext(())
        }
    }    
}
