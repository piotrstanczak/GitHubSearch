//
//  NetworkManager.swift
//  GitHubSearch
//
//  Created by Piotr Stanczak on 03/02/2019.
//  Copyright © 2019 Piotr Stanczak. All rights reserved.
//

import RxSwift
import RxCocoa

enum NetworkingError: Error {
    case couldNotEncodeUrl
    case couldNotDecodeData
    case badStatus(status: Int)
}

extension NetworkingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .couldNotEncodeUrl:
            return "Wrong url :|"
        case .couldNotDecodeData:
            return "Data format issue"
        case .badStatus(let status):
            return "Http issue with status code: \(status)"
        }        
    }
}

class NetworkManager {
    
    // MARK: - Properties
    private let baseUrl = "https://api.github.com/search/repositories?q=%@&sort=stars&page=%d&per_page=30"
    
    fileprivate let urlSession: URLSession
    fileprivate let imageCache: NSCache<AnyObject, AnyObject>
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
        self.imageCache = NSCache()
    }
    
    // MARK: - Public methods
    
    /// - Returns: a Model of type T that conforms to Codable protocol
    func search<T: Codable>(with phrase: String, page: Int) -> Observable<T> {
        
        guard let encodedPhrase = phrase.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
            let url = URL(string: String(format: baseUrl, encodedPhrase, page)) else {
                return .error(NetworkingError.couldNotEncodeUrl)
        }
        
        return urlSession.rx.response(request: URLRequest(url: url))
            .flatMap({ (arguments) -> Observable<T> in
                let (response, data) = arguments
                
                guard 200..<300 ~= response.statusCode else {
                    return .error(NetworkingError.badStatus(status: response.statusCode))
                }
                
                let decoded: T
                do {
                    decoded = try JSONDecoder().decode(T.self, from: data)
                } catch {
                    return .error(NetworkingError.couldNotDecodeData)
                }
                
                return .of(decoded)
            })
    }

}

extension NetworkManager {
        
    func loadImageWithUrl(_ url: URL) -> Observable<UIImage?> {

        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {            
            return .of(imageFromCache)
        }
        
        return urlSession.rx.data(request: URLRequest(url: url))
            
            .map { UIImage(data: $0) }
            .do(onNext: { [weak self] image in
                if let image = image {
                    self?.imageCache.setObject(image, forKey: url as AnyObject)
                }
            })
    }
}
