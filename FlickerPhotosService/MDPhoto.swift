//
//  MDPhoto.swift
//  
//
//  Created by Andrey Polyashev on 28.06.17.
//
//

import Foundation
import Argo
import Curry
import Runes

struct MDPhoto {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Bool
    let isFriend: Bool
    
    func link() -> URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
    
    func originalLink() -> URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!
    }
}

//MARK: Decodable
extension MDPhoto: Decodable {
    static func decode(_ json: JSON) -> Decoded<MDPhoto> {
        let photo = curry(MDPhoto.init)
            <^> json <| "id"
            <*> json <| "owner"
            <*> json <| "secret"

        let photo2 = photo
            <*> json <| "server"
            <*> json <| "farm"
            <*> json <| "title"
            <*> json <| "ispublic"
            <*> json <| "isfriend"

        
        return photo2
    }
}
