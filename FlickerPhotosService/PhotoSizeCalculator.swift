//
//  PhotoSizeCalculator.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 28.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import Foundation
import AVFoundation

class PhotoSizeCalculator {
    
    static let heightForUnknownPhotoSize: CGFloat = 60
    
    static func calculateHeight(forPhotoSize photoSize: CGSize?, width: CGFloat) -> CGFloat {
        
        guard let photoSize = photoSize else {
            return PhotoSizeCalculator.heightForUnknownPhotoSize
        }
        
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect = AVMakeRect(aspectRatio: photoSize, insideRect: boundingRect)
        return rect.size.height
    }
}
