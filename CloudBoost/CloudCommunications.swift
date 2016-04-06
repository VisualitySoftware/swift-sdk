//
//  CloudCommunications.swift
//  CloudBoost
//
//  Created by Randhir Singh on 18/03/16.
//  Copyright © 2016 Randhir Singh. All rights reserved.
//

import Foundation

public class CloudCommunications {
    
    public static func _request( method: String, url: NSURL, params: NSMutableDictionary, callback: (response: CloudBoostResponse) -> Void ){
        
        var _method = method
        
        //Check for logging
        let isLogging = CloudApp.isLogging()
        
        //Ready the calback response
        let cloudBoostResponse = CloudBoostResponse()
        
        //Handling DELETE request by fitting a parameter
        if(_method == "DELETE"){
            params["method"] = "DELETE"
            _method = "PUT"
        }
        
        //Ready the session
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        
        //Check params
        if(isLogging){
            print("Sending the following Object: ")
            print(NSString(data: try! params.getJSON()!, encoding: NSUTF8StringEncoding))
        }
        
        //Ready the payload by converting it to JSON
        let payload = try! params.getJSON()
        request.HTTPMethod = _method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = payload
        
        //Calling Service to send data and receive response
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil){
                cloudBoostResponse.message = "Error occured while reaching out to server"
                callback(response: cloudBoostResponse)
            } else if(response == nil){
                cloudBoostResponse.message = "Nil response"
                callback(response: cloudBoostResponse)
            } else if(data == nil){
                cloudBoostResponse.message = "No data received"
                callback(response: cloudBoostResponse)
            } else {
                
                //Checking the response
                if(isLogging){
                    print("Response: \(response)")
                    let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Body: \(strData)")
                }
                
                //Converting to proper format and returning
                do{
                    if let httpResponse = response as? NSHTTPURLResponse {
                        cloudBoostResponse.status = httpResponse.statusCode
                        if(httpResponse.statusCode == 200){
                            cloudBoostResponse.success = true
                        } else {
                            cloudBoostResponse.message = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                        }
                    }
                    
                    let serialisedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    if let jsonObjectReult = serialisedData as? NSMutableDictionary {
                        cloudBoostResponse.object = jsonObjectReult
                        callback(response: cloudBoostResponse)
                    }else if let  jsonArrayResult = serialisedData as? [NSDictionary] {
                        cloudBoostResponse.object = jsonArrayResult
                        callback(response: cloudBoostResponse)
                    }else{
                        if(isLogging){
                            print("Could not convert the response to NSMutalbeDictionary")
                        }
                        callback(response: cloudBoostResponse)
                    }
                    
                }catch let parseError {
                    if let intVal = Int((NSString(data: data!, encoding: NSUTF8StringEncoding) as? String)!)  {
                        cloudBoostResponse.object = intVal
                    }
                    if(isLogging){
                        print(parseError)
                    }
                    callback(response: cloudBoostResponse)
                }
            }
        })
        
        task.resume()
        
    }

}