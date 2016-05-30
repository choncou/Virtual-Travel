//
//  FlickrClient.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/29.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static func getPhotosForLocation(latitude: Double, longitude: Double, page: Int = 1, completion: (NSError?) -> ()){
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
            
            guard json != nil else {
                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
                return
            }
            
            //TODO: Create CoreData class for photos and save to conext
            
        }
        
        task.resume()
    }
    
    static func downloadPhotoDataForPhoto(photo: Photo, completion: (NSError?) -> ()) {
        let url = photo.url
        
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
            
            guard json != nil else {
                completion(NSError(domain: "FlickrClient", code: 400, userInfo: nil))
                return
            }
            
            //TODO: save core data image for photo and save to conext
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