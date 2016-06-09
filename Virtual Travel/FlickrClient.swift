//
//  FlickrClient.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/29.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrClient {
    static let stack = (UIApplication.sharedApplication().delegate as! AppDelegate).stack
    
    static func getPhotosForLocation(latitude: Double, longitude: Double, page: Int = 1, pin: Pin, completion: (NSError?) -> ()){
        let url = FlickrConfig.searchURLWithLocation(latitude: latitude, longitude: longitude, page: page)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
                return
            }
            
            let json = self.parseDataToJSON(data)
            
            guard let photoDict = json else {
                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
                return
            }
            
            stack.performBackgroundBatchOperation { (batch) in
                for photo in (photoDict["photos"]!["photo"] as! [[String: AnyObject]]) {
                    let url = FlickrConfig.imageURL(photo["farm"] as! Int, server_id: photo["server"] as! String, photo_id: photo["id"] as! String, secret: photo["secret"] as! String)
                    let params = ["url": url, "pin": pin]
                    let newPhoto = Photo(dictionary: params, context: batch)
                    let pinFetch = NSFetchRequest(entityName: "Pin")
                    pinFetch.predicate = NSPredicate(format: "SELF = %@", argumentArray: [pin])
                    let contextPin = try! batch.executeFetchRequest(pinFetch) as! [Pin]
                    newPhoto.pin = contextPin.first!
                }
                
            }
            
        }
        
        task.resume()
    }
    
    static func downloadPhotoDataForPhoto(photo: Photo, completion: (NSError?) -> ()) {
        let url = photo.url!
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
                return
            }
            
//            let json = self.parseDataToJSON(data)
//            
//            guard json != nil else {
//                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
//                return
//            }
            stack.performBackgroundBatchOperation{ (batch) in
                let photoFetch = NSFetchRequest(entityName: "Photo")
                photoFetch.predicate = NSPredicate(format: "SELF = %@", argumentArray: [photo])
                let contextPhoto = try! batch.executeFetchRequest(photoFetch) as! [Photo]
                contextPhoto.first!.image = data
            }
        }
        
        task.resume()
    }
    
    static func parseDataToJSON(data: NSData) -> [String: AnyObject]? {
        var json: [String:AnyObject]?
        do{
            json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
        }catch{
            return nil
        }
        guard json != nil else {
            return nil
        }
        return json
    }
    
}