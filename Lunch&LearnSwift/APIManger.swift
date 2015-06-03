//
//  APIManger.swift
//  HappyNashville
//
//  Created by Richmond Watkins on 3/31/15.
//  Copyright (c) 2015 Richmond Watkins. All rights reserved.
//

import UIKit
import CoreData

class APIManger: NSObject {
    
    class func requestNewData(completion: (locations: Array<Location>) -> Void) {
        let urlString = "https://s3-us-west-2.amazonaws.com/nashvilledeals/sandbox.json"
        var url: NSURL = NSURL(string: urlString)!;
        var request: NSURLRequest = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                
            self.updateDeals(jsonResult["locations"] as! NSArray, completion: { (locations) -> Void in
                completion(locations: locations)
            })
        }

    }
    
    class func updateDeals(deals: NSArray, completion: (locations: Array<Location>) -> Void) {
        var locationArray: Array<Location> = []

        for location in deals as! [NSDictionary] {
            locationArray.append(createLocation(location))
        }
        
        completion(locations: locationArray)
    }
    
    class func createLocation(locationDict: NSDictionary) -> Location {
        let location: Location = Location()
        
        for key in locationDict.allKeys as! [String] {
            if key != "_id" {
                if key == "dealDays" {
                    location.addDealDays(self.addDealDays(locationDict[key] as! NSArray, location: location) as Set<NSObject>)
                } else if key == "coords" {
                    var coordsDict: NSDictionary = locationDict[key] as! NSDictionary
                    location.lat = coordsDict["lat"] as! NSNumber
                    location.lng = coordsDict["lng"] as! NSNumber
                } else {
                    location.setValue(locationDict[key], forKey: key)
                }
            }
        }
        
        return location
    }
    
    class func addDealDays(dealDays: NSArray, location: Location) -> NSSet {
        var dealDaysArray: Array<DealDay> = []
        
        for dealDayDict in dealDays as! [NSDictionary] {
            
            var dealDay: DealDay = DealDay()
                        
            dealDaysArray.append(dealDay)
            
            dealDay.location = location
            
            for key in dealDayDict.allKeys as! [String] {
                
                if key == "specials" {
                    
                    dealDay.addSpecials(self.setSpecials(dealDayDict[key] as! NSArray) as Set<NSObject>)
                } else {

                    dealDay.setValue(dealDayDict[key], forKey: key)
                }
            }
            
        }
        
        return NSSet(array: dealDaysArray)
    }
    
    class func setSpecials(specials: NSArray) -> NSSet {
        var specialMutable: Array<Special> = []
        
        for  specialDict in specials as! [NSDictionary] {
            
            var special: Special = Special()
            
            for key in specialDict.allKeys as! [String] {
                special.setValue(specialDict[key], forKey: key)
            }
            
            specialMutable.append(special)
        }
        
        return NSSet(array: specialMutable)
    }

    class func fetchAllLocations(moc: NSManagedObjectContext) -> NSArray? {
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Location")
        
        return moc.executeFetchRequest(fetchRequest, error: nil)
    }
}