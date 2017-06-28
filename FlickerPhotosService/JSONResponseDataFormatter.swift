//
//  JSONResponseDataFormatter.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation

func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        guard var stringData = String(bytes: data, encoding: String.Encoding.utf8) else {
            return data
        }
        stringData = stringData.replacingOccurrences(of: "jsonFlickrApi(", with: "")
        stringData = stringData.replacingOccurrences(of: ")", with: "")
        
        guard let clearData = stringData.data(using: String.Encoding.utf8) else {
            return data
        }
        let dataAsJSON = try JSONSerialization.jsonObject(with: clearData)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}
