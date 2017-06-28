
//
//  Response+Argo.swift
//  Pods
//
//  Created by Sam Watts on 23/01/2016.
//
//

import Foundation
import Moya
import Argo

extension Response {
    
    func mapFlickerJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            guard var stringData = String(bytes: data, encoding: String.Encoding.utf8) else {
                return data
            }
            stringData = stringData.replacingOccurrences(of: "jsonFlickrApi(", with: "")
            stringData = stringData.replacingOccurrences(of: ")", with: "")
            
            guard let clearData = stringData.data(using: String.Encoding.utf8) else {
                return data
            }
            
            return try JSONSerialization.jsonObject(with: clearData, options: .allowFragments)
        } catch {
            if data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw MoyaError.jsonMapping(self)
        }
    }
    
    func mapFlickerObject<T:Decodable>(rootKey: String? = nil) throws -> T where T == T.DecodedType {
        
        do {
            //map to JSON (even if it's wrapped it's still a dict)
            let JSON = try self.mapFlickerJSON() as? [String: AnyObject] ?? [:]
            
            //decode with Argo
            let decodedObject:Decoded<T>
            if let rootKey = rootKey {
                decodedObject = decode(JSON, rootKey: rootKey)
            } else {
                decodedObject = decode(JSON)
            }
            
            //return decoded value, or throw decoding error
            return try decodedValue(decoded: decodedObject)
            
        } catch {
            
            throw error
        }
    }
    
    private func decodedValue<T>(decoded: Decoded<T>) throws -> T {
        
        switch decoded {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
