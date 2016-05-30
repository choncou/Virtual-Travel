//
//  FlickrConfig.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/29.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation

class FlickrConfig {
    static private let APIKEY = "08dca469bb46bc2bae8c157436b3eb9e"
    
    static private let BaseSearchURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    
    static func searchURLWithLocation(latitude lat: Double, longitude long: Double, page: Int = 1) -> String {
        let params: [String:AnyObject] = ["api_key": FlickrConfig.APIKEY,
                      "lat": lat,
                      "lon": long,
                      "per_page": 21,
                      "page": page,
                      "format": "json"]
        return "\(BaseSearchURL)\(escapedParameters(params))"
    }
    
    static func imageURL(farm_id: Int, server_id: Int, photo_id: Int, secret: String) -> String {
        let url = "https://farm\(farm_id).staticflickr.com/\(server_id)/\(photo_id)_\(secret)_m.jpg"
        
        return url
    }
    
    private static func escapedParameters(parameters: [String:AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        }else{
            var keyValuePairs = [String]()
            for (key, value) in parameters {
                let stringValue = "\(value)"
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "&\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
}
