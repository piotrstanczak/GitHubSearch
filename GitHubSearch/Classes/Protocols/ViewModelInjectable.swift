//
//  ViewModelInjectable.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import Foundation

/// ViewModel injectable procol
protocol ViewModelInjectable: class {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType { get set }
}
