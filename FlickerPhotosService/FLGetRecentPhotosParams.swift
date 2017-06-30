//
//  FLGetRecentPhotosParams.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation

class FLGetRecentPhotosParams: FLPortionParameters {
    override func params() -> [String: Any] {
        var baseParams = super.params()
        let newParams: [String : Any] = [
            "method": "flickr.photos.getRecent"
            ]
        baseParams.appendDictionary(dict: newParams)
        return baseParams
    }
}

class FLSearchPhotosParams: FLPortionParameters {
    var searchText: String?
    
    override func params() -> [String: Any] {
        var baseParams = super.params()
        var newParams: [String : Any] = [
            "method": "flickr.photos.search",
            "text": "girls"
        ]
        
        if let text = searchText {
            newParams["text"] = text
        }
        
        baseParams.appendDictionary(dict: newParams)
        return baseParams
    }
}
