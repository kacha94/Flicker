//
//  FlickerApi.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation
import Moya

enum FLPhotoService {
    case searchPhoto(FLPortionParameters)
    case getRecent(FLGetPopularPhotosParams)
}

extension FLPhotoService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.flickr.com/services/")!
    }
    
    var path: String {
        switch self {
        case .searchPhoto(_):
            return "rest/"
        case .getRecent:
            return "rest/"
        }
    }
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchPhoto(let query):
            return query.params()
        case .getRecent(let query):
            return query.params()
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var task: Task {
        return .request
    }
    
    var validate: Bool {
        switch self {
        case .searchPhoto(_):
            return true
        case .getRecent:
            return false
        }
    }
    
    var sampleData: Data {
        switch self {
        case .searchPhoto(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .getRecent:
            return Data()//"[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        }
    }
        
}
