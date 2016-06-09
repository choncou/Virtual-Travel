//
//  PhotoAlbumViewController.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/25.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    var pin: Pin!
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
    
    var updatedObjectIndexes: [NSIndexPath]!
    var insertedObjectIndexes: [NSIndexPath]!
    var deletedObjectIndexes: [NSIndexPath]!
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    
    //MARK: Actions
    @IBAction func newCollectionTap(sender: UIButton) {
        getNewPhotos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nibName = UINib(nibName: "PhotoCollectionViewCell", bundle:nil)
        
        collectionView.registerNib(nibName, forCellWithReuseIdentifier: "photoCell")

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        fetchedResultsController.delegate = self
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            getNewPhotos()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        let width = floor(collectionView.frame.size.width/3) - layout.minimumLineSpacing
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    func getNewPhotos() {
        let oldPhotos = fetchedResultsController.fetchedObjects as! [Photo]
        for pic in oldPhotos {
            sharedContext.deleteObject(pic)
        }
        print("getNewPics on page \(pin.current_page!)")
        pin.current_page = Int(pin.current_page!) + 1
        stack.save()
        FlickrClient.getPhotosForLocation(Double(pin.latitude!), longitude: Double(pin.longitude!), page: Int(pin.current_page!), pin: pin){ error in
            guard error != nil else {
                return
            }
            print(error)
        }
    }
    
    func checkLoadedimages(){
        var photos = fetchedResultsController.fetchedObjects as! [Photo]
        photos = photos.filter({$0.image == nil})
        
        if photos.isEmpty{
            newCollection.enabled = false
        } else {
            newCollection.enabled = true
        }
    }
    
    func setUpMap() {
        let coord = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude!), CLLocationDegrees(pin.longitude!))
        mapView.setRegion(MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        mapView.addAnnotation(annotation)
    }
    
    //MARK: CoreData
    lazy var sharedContext: NSManagedObjectContext = {
        return self.stack.context
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [self.pin])
        
        // Add a sort descriptor. This enforces a sort order on the results that are generated
        // In this case we want the events sored by their timeStamps.
        fetchRequest.sortDescriptors = []
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        cell.photo.backgroundColor = UIColor.whiteColor()
        cell.photo.image = UIImage(named: "loadingImage")
        
        guard photo.image != nil else{
            performTaskOnBackground {
                FlickrClient.downloadPhotoDataForPhoto(photo){ (error) in
                    guard error != nil else {
                        return
                    }
                    print(error)
                }
            }
            return cell
        }
        
        cell.photo.image = UIImage(data: photo.image!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        sharedContext.deleteObject(photo)
        stack.save()
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedObjectIndexes = []
        deletedObjectIndexes = []
        updatedObjectIndexes = []
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        performUpdateOnMain{
            self.collectionView.performBatchUpdates({() -> Void in
                
                self.collectionView.insertItemsAtIndexPaths(self.insertedObjectIndexes)
                self.collectionView.reloadItemsAtIndexPaths(self.updatedObjectIndexes)
                self.collectionView.deleteItemsAtIndexPaths(self.deletedObjectIndexes)
                
            }, completion: nil)
            self.checkLoadedimages()
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            insertedObjectIndexes.append(newIndexPath!)
        case .Delete:
            deletedObjectIndexes.append(indexPath!)
        case .Update:
            updatedObjectIndexes.append(indexPath!)
        default :
            break
            
        }
        
    }
    
}
