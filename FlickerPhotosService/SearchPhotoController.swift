//
//  SearchPhotoController.swift
//  FlickerPhotosService
//
//  Created by Andrey Polyashev on 27.06.17.
//  Copyright © 2017 Andrey Polyashev. All rights reserved.
//

import UIKit
import ReactiveSwift
import SKPhotoBrowser

class SearchPhotoController: UIViewController {

    //MARK: Private Properties
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var photosLayout: PhotosLayout!
    @IBOutlet fileprivate weak var spinner: UIActivityIndicatorView!

    fileprivate var refreshControl: UIRefreshControl!
    fileprivate let viewModel: SearchPhotoViewModel
    
    //MARK: Initializers
    init(viewModel: SearchPhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        binding()
        viewModel.loadInitialPhotos()
    }
}

extension SearchPhotoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = viewModel.modelForRow(atIndex: indexPath.row) else {
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPhotoControllerCell", for:  indexPath) as? SearchPhotoControllerCell else {
            return UICollectionViewCell()
        }
        cell.url = model.link()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension SearchPhotoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = viewModel.imageLinks().map({ SKPhoto.photoWithImageURL($0.absoluteString) })
        let browser = SKPhotoBrowser(photos: photos)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
        
        if scrollView.contentOffset.y > maxOffsetY {
            viewModel.loadNextPhotoPortion()
            return
        }
    }
}

//MARK: FeedLayoutDelegate
extension SearchPhotoController: PhotosLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        var cellSize: CGSize
        
        if (indexPath.row + 1) % 2 == 0 {
            cellSize = CGSize(width: 640, height: 430)
        } else {
            cellSize = CGSize(width: 640, height: 640)
        }
        
        return PhotoSizeCalculator.calculateHeight(forPhotoSize: cellSize, width: width)
    }
}

//MARK: Setup UI
private extension SearchPhotoController {
    func setup() {
        title = "Flicker Photos"
        spinner.hidesWhenStopped = true
        
        photosLayout.delegate = self
        photosLayout.sectionContentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SearchPhotoControllerCell", bundle: nil),
                                forCellWithReuseIdentifier: "SearchPhotoControllerCell")

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.beginRefreshing()
        if #available(iOS 10, *) {
            collectionView.refreshControl = refreshControl
        }
        else {
            collectionView.addSubview(refreshControl)
        }
    }
}

//MARK: Actions
private extension SearchPhotoController {
    @objc func handleRefresh() {
        viewModel.loadInitialPhotos()
    }
}

//MARK: Binding
private extension SearchPhotoController {
    func binding() {
        viewModel.indexPathsToInsert.producer
            .observe(on: UIScheduler())
            .on(value: { [weak self] indexPaths in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.collectionView.insertItems(at: indexPaths)
                
            }).start()
        
        viewModel.isLoading.producer
            .observe(on: UIScheduler())
            .on(value: { [weak self] isLoading in
                guard let strongSelf = self else {
                    return
                }
                if isLoading {
                    strongSelf.spinner.startAnimating()
                } else {
                    strongSelf.spinner.stopAnimating()
                    
                    if strongSelf.refreshControl.isRefreshing {
                        strongSelf.refreshControl.endRefreshing()
                    }
                }
            }).start()
        
        
        viewModel.reloadData.producer
            .observe(on: UIScheduler())
            .on(value: { [weak self] isLoading in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.collectionView.reloadData()
            }).start()
    }
}
