//
//  FLSearchParams.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation

class FLBaseParams {
    func params() -> [String: Any] {
        return [
            "api_key": Config.FlickerApiKey,
            "format": "json"
        ]
    }
}

class FLPortionParameters: FLBaseParams {
    var page: Int = 1
    var perPage: Int = 10

    override func params() -> [String: Any] {
        var params = super.params()
        let newParams: [String : Any] = [
            "per_page": perPage,
            "page": page,
        ]
        params.appendDictionary(dict: newParams)
        return params
    }

}

class FLGetPopularPhotosParams: FLPortionParameters {
    override func params() -> [String: Any] {
        var params = super.params()
        let newParams: [String : Any] = [
            "method": "flickr.photos.getRecent"
            ]
        params.appendDictionary(dict: newParams)
        return params
    }
}
