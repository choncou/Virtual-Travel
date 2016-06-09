//
//  TravelLocationsMapViewController.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/25.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    var isDeleting: Bool = false
    var longPressRecogniser: UILongPressGestureRecognizer!
    let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteAlert: UIView!
    
    //MARK: Actions
    @IBAction func editPinsTap(sender: UIBarButtonItem) {
        if isDeleting {
            hideDeleteAlert()
        } else {
            showDeleteAlert()
        }
    }
    
    func showDeleteAlert() {
        isDeleting = true
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.deleteAlert.frame.origin.y -= self.deleteAlert.frame.height
            self.mapView.frame.origin.y -= self.deleteAlert.frame.height
        }, completion: nil)
    }
    
    func hideDeleteAlert() {
        isDeleting = false
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.deleteAlert.frame.origin.y += self.deleteAlert.frame.height
            self.mapView.frame.origin.y += self.deleteAlert.frame.height
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        isDeleting = false
        setUpGestureRecogniser()
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        getAllPins()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CoreData
    lazy var sharedContext: NSManagedObjectContext = {
        return self.stack.context
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Add a sort descriptor. This enforces a sort order on the results that are generated
        // In this case we want the events sored by their timeStamps.
        fetchRequest.sortDescriptors = []
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    func getAllPins() {
        for pin in fetchedResultsController.fetchedObjects as! [Pin] {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = CLLocationDegrees(pin.latitude!)
            annotation.coordinate.longitude = CLLocationDegrees(pin.longitude!)
            mapView.addAnnotation(annotation)
        }
    }
    
    func findPinFromAnnotation(annotation: MKAnnotation) -> Pin? {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        let pins = fetchedResultsController.fetchedObjects as! [Pin]
        let lat = NSNumber(double: (annotation.coordinate.latitude))
        let long = NSNumber(double: (annotation.coordinate.longitude))
        let filtered = pins.filter({ $0.latitude == lat && $0.longitude == long  })
        guard filtered.first != nil else {
            print("Did not find")
            return nil
        }
        return filtered.first

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func setUpGestureRecogniser() {
        longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsMapViewController.addAnnotation(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        guard !isDeleting else {
            return
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            addAnnotationToCoreData(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if isDeleting {
            let toDelete = findPinFromAnnotation(view.annotation!)
            sharedContext.deleteObject(toDelete!)
            mapView.removeAnnotation(view.annotation!)
            stack.save()
        } else {
            let albumController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumController") as! PhotoAlbumViewController
            let selected = findPinFromAnnotation(view.annotation!)
            albumController.pin = selected
            navigationController!.pushViewController(albumController, animated: true)
        }
        
    }
    
    func addAnnotationToCoreData(point: MKPointAnnotation){
        let params: [String: AnyObject] = ["latitude": Double(point.coordinate.latitude),
            "longitude": Double(point.coordinate.longitude),
            "current_page": 1]
        _ = Pin(dictionary: params, context: sharedContext)
        stack.save()
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {

}
