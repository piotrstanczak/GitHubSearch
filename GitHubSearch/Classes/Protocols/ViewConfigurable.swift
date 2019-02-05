//
//  ViewConfigurable.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 04/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import Foundation

/// ViewConfig congigurable procol
public protocol ViewConfigurable {
    associatedtype ConfigType
    
    var config: ConfigType { get set }
}
