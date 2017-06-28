//
//  SearchPhotoControllerCell.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import UIKit
import Kingfisher

class SearchPhotoControllerCell: UICollectionViewCell {

    var url: URL? {
        didSet {
            flickerImageView.kf.setImage(with: url)
        }
    }
    
    //MARK: Private properties
    @IBOutlet fileprivate weak var flickerImageView: UIImageView!
    
    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 20
        clipsToBounds = true
        flickerImageView.backgroundColor = UIColor.lightGray
        flickerImageView.contentMode = .scaleAspectFill
    }
}
