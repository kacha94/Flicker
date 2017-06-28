//
//  Dictionary+Appending.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func appendDictionary(dict: Dictionary) {
        dict.forEach { (key, value) in
            self[key] = value
        }
    }
}
