//
//  CoordinatorFactory.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import UIKit

/// Coordinator factory protocol
protocol CoordinatorFactory {
    /// - Returns: a Coordinator for C type with navigator 
    func coordinator<N, F, R, C: Coordinator<N, F, R>>(for type: C.Type, with navigator: N) -> C
}

