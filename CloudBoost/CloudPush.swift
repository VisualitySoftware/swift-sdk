//
//  CloudPush.swift
//  CloudBoost
//
//  Created by Randhir Singh on 14/05/16.
//  Copyright © 2016 Randhir Singh. All rights reserved.
//

import Foundation

public class CloudPush {
    
    public static func send(data: AnyObject, query: CloudQuery?, callback: (CloudBoostResponse)->Void) throws {
        
        if CloudApp.getAppId() == nil {
            throw CloudBoostError.AppIdNotSet
        }
        if CloudApp.getAppKey() == nil {
            throw CloudBoostError.AppIdNotSet
        }
        var pushQuery: CloudQuery
        if query == nil {
            pushQuery = CloudQuery(tableName: "Device")
        }else{
            pushQuery = query!
        }
        
        let params = NSMutableDictionary()

        params["query"] = pushQuery.getQuery()
        params["sort"] = pushQuery.getSort()
        params["limit"] = pushQuery.getLimit()
        params["skip"] = pushQuery.getSkip()
        
        params["key"] = CloudApp.getAppKey()
        params["data"] = data
        
        let url = CloudApp.getApiUrl() + "/push/" + CloudApp.getAppId()! + "/send"
        
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: params, callback: {response in
            print("Response !!")
            callback(response)
        })
        
    }
    
    public static func registerDeviceWithToken(token: NSData,
                                               timezone: String,
                                               channels: [String]?,
                                               callback: (CloudBoostResponse)->Void)  {
    
        var tokenString = NSString(format: "%@", token)
        tokenString = tokenString.stringByReplacingOccurrencesOfString("<", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString(">", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")

        let device = CloudObject(tableName: "Device")
        device.set("deviceToken", value: tokenString)
        device.set("deviceOS", value: "iOS")
        device.set("timezone", value: timezone)
        if let channels = channels {
            device.set("channels", value: channels)
        }

        device.save { response in
            
            callback(response)
        }
    }
    
    public static func unregisterDeviceWithToken(token: NSData,
                                                 callback: (CloudBoostResponse)->Void)  {
        
        var tokenString = NSString(format: "%@", token)
        tokenString = tokenString.stringByReplacingOccurrencesOfString("<", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString(">", withString: "")
        tokenString = tokenString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let query = CloudQuery(tableName: "Device")
        try! query.equalTo("deviceToken", obj: tokenString)
        try! query.findOne { (response) in
            
            if let device = response.object as? CloudObject {
                
                device.delete({ (response) in
                    
                    callback(response)
                })
            }
        }
        
    }
}