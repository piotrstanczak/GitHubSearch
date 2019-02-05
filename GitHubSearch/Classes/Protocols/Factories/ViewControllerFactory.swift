//
//  ViewControllerFactory.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit

/// ViewController factory protocol
protocol ViewControllerFactory {    
    /// - Returns: a UIViewController of type T that conforms to ViewModelInjectable protocol
    func viewController<T: ViewModelInjectable & ViewConfigurable, S>(for type: T.Type, viewModel: S?) -> T where S == T.ViewModelType
}


