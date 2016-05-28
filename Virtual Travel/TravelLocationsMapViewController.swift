//
//  TravelLocationsMapViewController.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/25.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {

    var isDeleting: Bool = false
    var longPressRecogniser: UILongPressGestureRecognizer!
    
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            // Add annotations to Core Data
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let albumController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumController") as! PhotoAlbumViewController
        albumController.pin = "new"
        navigationController!.pushViewController(albumController, animated: true)
        print("change")
    }
    
}
