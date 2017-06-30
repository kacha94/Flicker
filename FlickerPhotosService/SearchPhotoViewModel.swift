//
//  SearchPhotoViewModel.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import UIKit
import ReactiveSwift
import Moya

class SearchPhotoViewModel {
    
    //MARK: Internal properties
    var reloadData: Property<Bool> { return Property(_reloadData) }
    var indexPathsToInsert: Property<[IndexPath]> { return Property(_indexPathsToInsert) }
    var isLoading: Property<Bool> { return Property(_isLoading) }
    
    //MARK: Private properties
    fileprivate let _isLoading: MutableProperty<Bool> = MutableProperty(false)
    fileprivate let _indexPathsToInsert: MutableProperty<[IndexPath]> = MutableProperty([])
    fileprivate let _reloadData: MutableProperty<Bool> = MutableProperty(false)
    
    fileprivate let params = FLSearchPhotosParams()
    fileprivate var photos: [MDPhoto] = []
    fileprivate let totalItemsCount = 1000 // HARD Code
    
    fileprivate let provider: ReactiveSwiftMoyaProvider<FLPhotoService>
    
    //MARK: Initializers
    init(provider: ReactiveSwiftMoyaProvider<FLPhotoService>) {
        self.provider = provider
        params.perPage = 10
        params.page = 1
    }
}

//MARK: Collection view data source
extension SearchPhotoViewModel {
    func modelForRow(atIndex index: Int) -> MDPhoto? {
        guard case 0..<photos.count = index else {
            return nil
        }
        return photos[index]
    }
    
    func rowsCount() -> Int {
        return photos.count
    }
    
    func imageLinks() -> [URL] {
        return photos.map({ return $0.originalLink() })
    }
}

//MARK: Api methods
extension SearchPhotoViewModel {
    func search(withText text: String?) {
        photos = []
        
        params.searchText = text
        params.page = 1
        
        load(withService: .searchPhoto(params))
    }
    
    func loadInitialPhotos() {
        photos = []
        params.page = 1
        
        load(withService: .searchPhoto(params))
    }

    func loadNextPhotoPortion() {
        let loadedItemsCount = photos.count
        
        guard !_isLoading.value else {
            return
        }
        
        guard loadedItemsCount < totalItemsCount else {
            return
        }
        
        params.page += 1
        load(withService: .searchPhoto(params))
    }
}


private extension SearchPhotoViewModel {
    func load(withService service: FLPhotoService) {
        _isLoading.value = true
        provider
            .request(service)
            .filterSuccessfulStatusCodes()
            .mapFlickerObject(type: MDPhotos.self, rootKey: "photos")
            .observe(on: UIScheduler())
            .on(starting: { [weak self] in
                self?._isLoading.value = true
            })
            .on(value: { [weak self] portion in
                guard let strongSelf = self else {
                    return
                }
                strongSelf._isLoading.value = false
                
                //MARK: Need to use InsertIndexPathAtValue
                
                if strongSelf.photos.count == 0 {
                    strongSelf.photos = portion.photo
                    strongSelf._reloadData.value = true
                } else {
                    
                    let indexPaths = SearchPhotoViewModel.indexPaths(forItems: portion.photo, addedToItemsWithCount: strongSelf.photos.count)
                    strongSelf.photos.append(contentsOf: portion.photo)
                    
                    if indexPaths.count > 0 {
                        strongSelf._indexPathsToInsert.value = indexPaths
                    }
                }
            })
            .on(failed: { [weak self] error in
                print(error)
                //MARK: Add Error handler
            })
            .on(event: { [weak self] event in
                switch event {
                case .interrupted, .failed(_):
                    self?._isLoading.value = false
                default:
                    return
                }
            })
            .start()
    }

    
    static func indexPaths(forItems newItems: [MDPhoto], addedToItemsWithCount count: Int) -> [IndexPath] {
        var indexPathsToReturn: [IndexPath] = []
        
        for i in 0..<newItems.count {
            let indexPath = IndexPath(row: count + i, section: 0)
            indexPathsToReturn.append(indexPath)
        }
        
        return indexPathsToReturn
    }
}
