//
//  FlickerProvider.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation
import Moya


class CustomReactiveMoyaProvider<Target>: ReactiveSwiftMoyaProvider<Target> where Target: TargetType {
    init() {
        let plugin = NetworkLoggerPlugin(verbose: true, responseDataFormatter:  JSONResponseDataFormatter)
        super.init(plugins: [plugin])

    }
}
