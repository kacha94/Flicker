//
//  FLBaseParams.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 30.06.17.
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
