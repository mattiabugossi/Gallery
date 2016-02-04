//
//  GalleryCollectionViewController.swift
//  LiLyGallery
//
//  Created by Mattia Bugossi on 1/27/16.
//  Copyright © 2016 Mattia Bugossi. All rights reserved.
//

import UIKit


class GalleryCollectionViewController: UICollectionViewController {

    typealias CompletionHandler = (() -> ())?
    
    var dataSource: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photosDataSourceFile =  NSBundle.mainBundle().pathForResource("PhotosDataSource", ofType: "plist") {
            dataSource = NSMutableArray(contentsOfFile: photosDataSourceFile)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleCellVisibility(hiding: false)
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryCell
        cell.dataSourceArray = dataSource?[indexPath.item] as? [String]
        cell.albumNameLabel?.text = "Album: \(indexPath.item)"
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        toggleCellVisibility(exceptForCellAtIndexPath: indexPath, hiding: true) {
            self.performSegueWithIdentifier("segueToAlbum", sender: indexPath)
        }
    }
    
    func toggleCellVisibility(exceptForCellAtIndexPath indexPath: NSIndexPath? = nil, hiding: Bool, completion: CompletionHandler = nil) {
        var indexArray = [NSIndexPath]()
        
        for i in 0 ..< collectionView!.numberOfItemsInSection(0) {
            let currentIndexPath = NSIndexPath(forItem: i, inSection: 0)
            if indexPath?.item != i {
                indexArray.append(currentIndexPath)
            }
        }
        
        UIView.animateWithDuration(0.3, animations: {
            for index in indexArray {
                let cell = self.collectionView!.cellForItemAtIndexPath(index)
                cell?.alpha = hiding ? 0 : 1
            }
        }, completion: { _ in
            completion?()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let albumViewController = segue.destinationViewController as? AlbumCollectionViewController, let indexPath = sender as? NSIndexPath, let attribute = collectionView?.layoutAttributesForItemAtIndexPath(indexPath) {
            let cellPoint: CGPoint
            if collectionView!.contentOffset.y > 0 {
                cellPoint = CGPoint(x: attribute.center.x, y: attribute.center.y - collectionView!.contentOffset.y - 20)
            } else {
                cellPoint = attribute.center
            }
            
            (albumViewController.collectionView!.collectionViewLayout as! GalleryStackLayout).centerPoint = cellPoint
            albumViewController.collectionView!.dataSource = albumViewController
            
            var photosArray: [String] = []
            var videosArray: [String] = []
            
            for item in dataSource?[indexPath.item] as? [String] ?? [] {
                if photosArray.count < 4 {
                    photosArray.append(item)
                } else {
                    videosArray.append(item)
                }
            }
            
            albumViewController.navigationItem.title = "Album: \(indexPath.item)"
            albumViewController.dataSourceArray = photosArray + videosArray
            albumViewController.photosArray = photosArray
            albumViewController.videosArray = videosArray
        }
    }

}

class GalleryCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var albumNameLabel: UILabel?
    
    var dataSourceArray: [String]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func awakeFromNib() {
        collectionView?.userInteractionEnabled = false
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceArray?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryCell
        if let imageName = dataSourceArray?[indexPath.item], let image = UIImage(named: String(format: "%@.jpg", imageName))  {
            cell.imageView?.image = image
        }
        
        return cell
    }

}