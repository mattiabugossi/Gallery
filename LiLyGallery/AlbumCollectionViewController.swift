//
//  AlbumCollectionViewController.swift
//  LiLyGallery
//
//  Created by Mattia Bugossi on 1/27/16.
//  Copyright © 2016 Mattia Bugossi. All rights reserved.
//

import UIKit


class AlbumCollectionViewController: UICollectionViewController, UINavigationControllerDelegate, ZOZolaZoomTransitionDelegate {

    var dataSourceArray: [String]?
    var photosArray: [String]?
    var videosArray: [String]?
    var galleryStackLayout: GalleryStackLayout?
    var selectedCell: GalleryCell!

    var isOnlyPictures = false {
        didSet {
            if isOnlyPictures {
                collectionView?.performBatchUpdates({ () -> Void in
                    self.dataSourceArray = self.photosArray
                    if self.isAll {
                        self.removeVideos()
                        self.isAll = false
                    } else if self.isOnlyVideo {
                        var indexPathToDelete = [NSIndexPath]()
                        for i in 0 ..< self.videosArray!.count {
                            indexPathToDelete.append(NSIndexPath(forItem: i, inSection: 0))
                        }
                        self.collectionView?.deleteItemsAtIndexPaths(indexPathToDelete)
                        
                        self.insertPhotos()
                        self.isOnlyVideo = false
                    }
                }, completion: nil)
            }
        }
    }
    var isOnlyVideo = false {
        didSet {
            if isOnlyVideo {
                collectionView?.performBatchUpdates({ () -> Void in
                    self.dataSourceArray = self.videosArray
                    if self.isAll {
                        self.removePhotos()
                        self.isAll = false
                    } else if self.isOnlyPictures {
                        self.removePhotos()
                        
                        var indexPathToAdd = [NSIndexPath]()
                        for i in 0 ..< self.videosArray!.count {
                            indexPathToAdd.append(NSIndexPath(forItem: i, inSection: 0))
                        }
                        self.collectionView?.insertItemsAtIndexPaths(indexPathToAdd)
                        self.isOnlyPictures = false
                    }
                }, completion: nil)
            }
        }
    }
    
    var isAll = true {
        didSet {
            if isAll {
                collectionView?.performBatchUpdates({ () -> Void in
                    self.dataSourceArray = self.photosArray! + self.videosArray!
                    if self.isOnlyPictures {
                        self.insertVideos()
                        self.isOnlyPictures = false
                    } else if self.isOnlyVideo {
                        self.insertPhotos()
                        self.isOnlyVideo = false
                    }
                }, completion: nil)
            }
        }
    }
    
    func removePhotos() {
        var indexPathToDelete = [NSIndexPath]()
        for i in 0 ..< self.photosArray!.count {
            indexPathToDelete.append(NSIndexPath(forItem: i, inSection: 0))
        }
        self.collectionView?.deleteItemsAtIndexPaths(indexPathToDelete)
    }
    
    func insertPhotos() {
        var indexPathToAdd = [NSIndexPath]()
        for i in 0 ..< self.photosArray!.count {
            indexPathToAdd.append(NSIndexPath(forItem: i, inSection: 0))
        }
        self.collectionView?.insertItemsAtIndexPaths(indexPathToAdd)
    }
    
    func insertVideos() {
        var indexPathToAdd = [NSIndexPath]()
        for i in 0 ..< self.videosArray!.count {
            indexPathToAdd.append(NSIndexPath(forItem: self.photosArray!.count + i, inSection: 0))
        }
        self.collectionView?.insertItemsAtIndexPaths(indexPathToAdd)
    }
    
    func removeVideos() {
        var indexPathToDelete = [NSIndexPath]()
        for i in 0 ..< self.videosArray!.count {
            indexPathToDelete.append(NSIndexPath(forItem: self.photosArray!.count + i, inSection: 0))
        }
        self.collectionView?.deleteItemsAtIndexPaths(indexPathToDelete)
    }
    
    @IBAction func filterPhotos(sender: AnyObject) {
        isOnlyPictures = true
    }
    
    @IBAction func filterVideos(sender: AnyObject) {
        isOnlyVideo = true
    }
    
    @IBAction func filterNone(sender: AnyObject) {
        isAll = true
    }
    
    @IBAction func back(sender: AnyObject) {
        collectionView?.setContentOffset(CGPointZero, animated: true)
        if let galleryStackLayout = galleryStackLayout {
            collectionView?.setCollectionViewLayout(galleryStackLayout, animated: true)
        }
        
        after(0.3) {
            self.navigationController?.popViewControllerAnimated(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryStackLayout = collectionView?.collectionViewLayout as? GalleryStackLayout
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        
        after(0.1) {
            let gridLayout = UICollectionViewFlowLayout()
            gridLayout.itemSize = CGSize(width: (UIScreen.mainScreen().bounds.width - 40) / 3, height: (UIScreen.mainScreen().bounds.width - 40) / 3)
            gridLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.collectionView?.setCollectionViewLayout(gridLayout, animated: true)
        }
    }
    
    func after(delay: NSTimeInterval, block: dispatch_block_t) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * 1_000_000_000)), dispatch_get_main_queue(), block)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceArray?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryCell
        
        let imageName: String
        if isAll {
            imageName = dataSourceArray![indexPath.item]
        } else if isOnlyPictures {
            imageName = photosArray![indexPath.item]
        } else {
            imageName = videosArray![indexPath.item]
        }
        
        if let image = UIImage(named: String(format: "%@.jpg", imageName))  {
            cell.imageView?.image = image
        }
        return cell
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? DetailViewController, let selectedIndexPath = collectionView?.indexPathsForSelectedItems()?.first, let imageName = dataSourceArray?[selectedIndexPath.item], let image = UIImage(named: String(format: "%@.jpg", imageName)) {
            
            if let cell = collectionView?.cellForItemAtIndexPath(selectedIndexPath) as? GalleryCell {
                selectedCell = cell
            }
            
            detailViewController.image = image
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC != self && toVC != self {
            return nil
        }
        
        let type = fromVC == self ? ZOTransitionType.Presenting : ZOTransitionType.Dismissing
        let zoomTransition = ZOZolaZoomTransition(fromView: selectedCell.imageView!, type: type, duration: 0.5, delegate: self)
        zoomTransition.fadeColor = collectionView?.backgroundColor ?? .whiteColor()
        return zoomTransition
    }
    
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, startingFrameForView targetView: UIView!, relativeToView relativeView: UIView!, fromViewController: UIViewController!, toViewController: UIViewController!) -> CGRect {
        if fromViewController == self {
            return selectedCell.imageView!.convertRect(selectedCell.imageView!.bounds, toView: relativeView)
        } else if let detailViewController = fromViewController as? DetailViewController {
            return detailViewController.imageView!.convertRect(detailViewController.imageView!.bounds, toView: relativeView)
        }
        
        return CGRectZero
    }
    
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, finishingFrameForView targetView: UIView!, relativeToView relativeView: UIView!, fromViewController fromViewComtroller: UIViewController!, toViewController: UIViewController!) -> CGRect {
        if let detailViewController = toViewController as? DetailViewController where fromViewComtroller == self {
           return detailViewController.imageView!.convertRect(detailViewController.imageView!.bounds, toView: relativeView)
        } else if fromViewComtroller is DetailViewController {
            return selectedCell.imageView!.convertRect(selectedCell.imageView!.bounds, toView: relativeView)
        }
        
        return CGRectZero
    }
    
    func supplementaryViewsForZolaZoomTransition(zoomTransition: ZOZolaZoomTransition!) -> [AnyObject]! {
        let clippedCells = NSMutableArray(capacity: collectionView?.visibleCells().count ?? 0)
        
        for cell in collectionView?.visibleCells() ?? [] {
            let convertedRect = cell.convertRect(cell.bounds, toView: view)
            if !CGRectContainsRect(view.frame, convertedRect) {
                clippedCells.addObject(cell)
            }
        }
        
        return clippedCells as [AnyObject]
    }
    
    func zolaZoomTransition(zoomTransition: ZOZolaZoomTransition!, frameForSupplementaryView supplementaryView: UIView!, relativeToView relativeView: UIView!) -> CGRect {
        return supplementaryView.convertRect(supplementaryView.bounds, toView: relativeView)
    }

}
