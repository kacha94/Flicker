//
//  MDPhotos.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 28.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct MDPhotos {
    let photo: [MDPhoto]
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
}

//MARK: Decodable
extension MDPhotos: Decodable {
    static func decode(_ json: JSON) -> Decoded<MDPhotos> {
        let photos = curry(MDPhotos.init)
            <^> json <|| "photo"
            <*> json <| "page"
            <*> json <| "pages"
            <*> json <| "perpage"
            <*> json <| "total"

        return photos
    }
}
