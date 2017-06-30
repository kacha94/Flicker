//
//  FLPortionParameters.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 30.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation

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
