//
//  CloudObject.swift
//  CloudBoost
//
//  Created by Randhir Singh on 18/03/16.
//  Copyright © 2016 Randhir Singh. All rights reserved.
//

import Foundation

/// Base class of all the object fetched and saved to CloudBoost. CloudObject can be subclass, the the framework take care of the rest, utilizing the appropriate class based on various definitition found throught the SDK.

public class CloudObject: NSObject {
    
    var document = NSMutableDictionary()

    var acl = ACL()
    var _modifiedColumns = [String]()
    
    required public init(tableName: String) {
        
        self._modifiedColumns = [String]()
        
        _modifiedColumns.append("createdAt")
        _modifiedColumns.append("updatedAt")
        _modifiedColumns.append("ACL")
        _modifiedColumns.append("expires")
        
        document["_id"] = ""
        document["ACL"] = acl.getACL()
        document["_tableName"] = tableName
        if(tableName == "Role"){
            document["_type"] = "role"
        }else if (tableName == "User"){
            document["_type"] = "user"
        }else{
            document["_type"] = "custom"
        }
        document["createdAt"] = ""
        document["updatedAt"] = ""
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true
    }

    public init(dictionary: NSDictionary){
        
        self.document = NSMutableDictionary(dictionary: dictionary as [NSObject : AnyObject], copyItems: true)
    }
    
    override public var description: String {
        
        return document.description
    }
    
    public func getDocumentDictionary() -> NSMutableDictionary {
        return document
    }

    public func setDocumentDictionary(dictionary: NSDictionary) {
        document = NSMutableDictionary(dictionary: dictionary as [NSObject : AnyObject], copyItems: true)
    }

    // MARK:- Setter Functions
    
    /// Set an object to a thethe given property
    ///
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: a generic jobect to inserted into the propriery
    /// - returns: TDB
    /// - note: The object has to be serialized, so i must contains only NSCoding compliant objects
    ///
    /// This method evaluates the content of the given object and takes care of the action needed to to fill the remote property, such as for CloudGeoPoints or CloudFile.
    ///
    /// Relational objects are returned by recostructing the appropriate CloudObject subclass, depending on the originating query or serach request or by the mapping configuring throught the objectsMappgin property of CloudApp. See the CloudApp reference for further informtions on CloudObject sublclassing.
    
    public func set(attribute: String, value: AnyObject?) -> (Int, String?) {
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }
        
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        // Cloud Object
        if let obj = value as? CloudObject {
            document[attribute] = obj.document
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Cloud Object List
        else if let obj = value as? [CloudObject] {
            var res = [NSMutableDictionary]()
            for o in obj {
                res.append(o.document)
            }
            document[attribute] = res
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Geo point
        else if let obj = value as? CloudGeoPoint {
            document[attribute] = obj.document
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Geo point list
        else if let obj = value as? [CloudGeoPoint] {
            var res = [NSMutableDictionary]()
            for o in obj {
                res.append(o.document)
            }
            document[attribute] = res
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Cloud File
        else if let obj = value as? CloudFile {
            document[attribute] = obj.document
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Cloud file list
        else if let obj = value as? [CloudFile] {
            var res = [NSMutableDictionary]()
            for o in obj {
                res.append(o.document)
            }
            document[attribute] = res
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            // Date
        else if let obj = value as? NSDate {
            document[attribute] = CloudBoostDateFormatter.getISOFormatter().stringFromDate(obj)
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
            
        else {
            document[attribute] = value
            _modifiedColumns.append(attribute)
            document["_modifiedColumns"] = _modifiedColumns
        }
        
        document["_isModified"] = true
        
        return(1,nil)
    }
    
    /// Assigns an String value to the given property
    ///
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: a String ojbect to be assigned to the property
    /// - returns: TDB
    ///
    public func setString(attribute: String, value: String?) -> (Int, String?) {
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }
        
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        document[attribute] = value
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true

        return(1,nil)
    }
    
    /// Assigns an int value to the given property
    ///
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: a Int object to be assigned to the property
    /// - returns: TDB
    ///
    
    public func setInt(attribute: String, value: Int?) -> (Int, String?) {
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }
        
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        document[attribute] = value
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true

        return(1,nil)
    }
    
    /// Assigns an double value to the given property
    ///
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: a Double object to be assigned to the property
    /// - returns: TDB
    ///
    
    public func setDouble(attribute: String, value: Double?) -> (Int, String?){
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }
        
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        document[attribute] = value
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true

        return(1,nil)
    }
    
    /// Assigns an NSDecimalNumber object to the given property
    /// 
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: an NSDecimalNumber object
    /// - returns: TDB
    ///
    
    public func setDecimalNUmber(attribute: String, value: NSDecimalNumber?) -> (Int, String?) {
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }

        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        document[attribute] = value.doubleValue
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true

        return(1,nil)
    }
    
    /// Assigns a NSDate value to the given property
    ///
    /// - parameter attribute: the name of the remode attribute
    /// - parameter value: an NSDate ojbect to be assigned to the property
    /// - returns: TDB
    ///    
    
    public func setDate(attribute: String, value: NSDate?) -> (Int, String?) {
        
        guard let value = value else {
            
            return removeValueFromAttribute(attribute)
        }
        
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        // Converting the date to a standard date string format
        document[attribute] = CloudBoostDateFormatter.getISOFormatter().stringFromDate(value)
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true

        return(1,nil)
    }
    
    /// Remove the value assigned to a given property
    ///
    /// - parameter attribute: the name of the remode attribute
    ///
    
    public func removeValueFromAttribute(attribute: String) -> (Int, String?) {
        let keywords = ["_tableName", "_type","operator","_id","createdAt","updatedAt"]
        if(keywords.indexOf(attribute) != nil){
            //Not allowed to chage these values
            return(-1,"Not allowed to change these values")
        }
        
        document.removeObjectForKey(attribute)
        
        _modifiedColumns.append(attribute)
        document["_modifiedColumns"] = _modifiedColumns
        document["_isModified"] = true
        
        return (1, nil)
    }
    
    // Should this object appear in searches
    public func setIsSearchable(value: Bool){
        document["_isSearchable"] = value
        _modifiedColumns.append("_isSearchable")
    }
    
    // Set expiry time for this cloudobject, after which it will not appear in queries and searches
    public func setExpires(value: NSDate){
        document["expires"] = value.description
    }
    
    /// Obtains the unique id assogned to this cloud object
    ///
    /// - returns: a String optional
    
    public func getId() -> String? {
        if let id = document["_id"] as? String {
            if(id  == ""){
                return nil
            }else{
                return id
            }
        }
        return nil
    }
    
    /// Set the unique ID
    ///
    /// can set the ID to fetch the object later, 
    /// only possible if the object does not have an existing ID
    public func setId(id: String) -> Bool {
        if let id = document["_id"] as? String {
            if(id  == ""){
                document["_id"] = id
                return true
            }else{
                return false
            }
        }
        document["_id"] = id
        return true
    }
    
    /// Obtains the ACL object assigned to this cloud object
    /// - note: See ACL section for more on ACL
    ///
    /// - returns: a String optional

    public func getAcl() -> ACL? {
        if let aclDoc = document["ACL"] as? NSMutableDictionary {
            return ACL(acl: aclDoc)
        }
        return nil
    }
    
    /// Set an ACL object to this cloud object
    /// - parameter acl: The ACL object to be assigned to this cloud objct
    /// - note: See ACL section for more on ACL
    
    public func setACL(acl: ACL) {
        _modifiedColumns.append("ACL")
        document["ACL"] = acl.getACL()
    }

    /// Check if this objct has the specified key
    /// - parameter key: the String key to be verified
    /// - returns: true if the key exists

    func exist(key: String) -> Bool{
        if(document[key] != nil){
            return true
        }
        return false
    }
    
    // Get when this cloudobject will expire
    public func getExpires() -> NSDate? {
        // Parse as NSDate
        return document["expires"] as? NSDate
    }
    
    // Gets the creation date of this Object
    public func getCreatedAt() -> NSDate? {
        // Implement parsing logic
        
        return document["createdAt"] as? NSDate
    }
    
    // Gets the last update date of this object
    public func getUpdatedAt() -> NSDate? {
        // Implement parsing logic
        
        return document["updatedAt"] as? NSDate
    }
    
    
    /// Get an object for the specified attributed
    /// - note: Is the attribute contains a relational object or list, it tries to reconstruct the appropriate CloudObject or sublcassed object
    /// - parameter attribute: The attribute for the object to be retrieved
    /// - returns: and AnyObject optional or a CloudObject optional

    public func get(attribute: String) -> AnyObject? {
        
        // Check if the attribute is a relational CloudObject
        if let dictionary = document[attribute] as? NSDictionary
            where dictionary["_tableName"] is String {
        
            // Relational object
            
            // TODO: Check for a correct type
            let object = CloudObject.cloudObjectFromDocumentDictionary(dictionary)
            
            return object
        }
        
        // Check if the attribute is a list of CloudObjects
        if let array = document[attribute] as? [NSDictionary] {

            var cloudObjects = [CloudObject]()
            
            for dictionary in array where dictionary["_tableName"] is String {
                
                let object = CloudObject.cloudObjectFromDocumentDictionary(dictionary)
                
                cloudObjects.append(object)
            }
            
            if cloudObjects.count > 0 {
                return cloudObjects
            }
        }
        
        return document[attribute]
    }
    
    // return true if search can be performed on the object
    public func getIsSearchable() -> Bool? {
        return document["_isSearchable"] as? Bool
    }
    
    // Get an integer attribute
    public func getInt(attribute: String) -> Int? {
        return document[attribute] as? Int
    }
    
    // Get a double number attribute
    public func getDouble(attribute: String) -> Double? {
        return document[attribute] as? Double
    }
    
    // Get a decimal number
    public func getDecimalNumber(attribute: String) -> NSDecimalNumber? {
        if let double = document[attribute] as? Double {
            return NSDecimalNumber(double: double)
        } else {
            return nil
        }
    }
    
    // Get a string attribute
    public func getString(attribute: String) -> String? {
        return document[attribute] as? String
    }
    
    // Get a boolean attribute
    public func getBoolean(attribute: String) -> Bool? {
        return document[attribute] as? Bool
    }
    
    // Get a date attribute
    public func getDate(attribute: String) -> NSDate? {
        if let attribute = document[attribute] as? String {
            return CloudBoostDateFormatter.getISOFormatter().dateFromString(attribute)
        }
        return nil
    }
    
    // Get a GeoPoint
    public func getGeoPoint(attribute: String) -> CloudGeoPoint? {
        if let geoPoint = document[attribute] as? NSDictionary {
            do {
                let geoPointObj = try CloudGeoPoint(latitude: geoPoint["latitude"] as! Double, longitude: geoPoint["longitude"] as! Double)
                return geoPointObj
            } catch {
                return nil
            }
        }
        return nil
    }
    
    // Log this cloud boost object
    public func log() {
        print("-- CLoud Object --")
        print(document)
    }
    
    
    /// Save this object in a table.
    ///
    /// - Parameter callback: block where receiving results of the operation    
    public func save(callback: (CloudBoostResponse) -> Void ){
        let url = CloudApp.serverUrl + "/data/" + CloudApp.appID! + "/"
            + (self.document["_tableName"] as! String)
        let params = NSMutableDictionary()
        params["key"] = CloudApp.appKey!
        params["document"] = document
        
        CloudCommunications._request("PUT", url: NSURL(string: url)!, params: params, callback:
            {(response: CloudBoostResponse) in
                if(response.success){
                    if let newDocument = response.object {
                        self.document = newDocument as! NSMutableDictionary
                        self.document["_isModified"] = false
                        self.document["_modifiedColumns"] = nil
                    }
                }
                callback(response)
        })
    }
    
    /// Fetch the object
    ///
    /// - Parameter callback: block where receiving results of the operation
    public func fetch(callback: (CloudBoostResponse) -> Void ){
        guard let id = self.getId() else {
            let resp = CloudBoostResponse()
            resp.message = "Object does not have an ID, cannot fetch"
            callback(resp)
            return
        }
        print("id : \(id)")
        let query = CloudQuery(tableName: self.get("_tableName")as!String)
        
        query.findById(id, callback: { resp in
            
            if let obj = resp.object?.firstObject as? CloudObject {
                self.document = obj.document
                print("Object updated")
            }
            callback(resp)
        })
        
    }
    
    
    /// Delete self object from his settable
    ///
    /// - Parameter callback: block where receiving results of the operation
    
    public func delete( callback: (CloudBoostResponse) -> Void ){
        let url = CloudApp.serverUrl + "/data/" + CloudApp.appID! + "/"
            + (self.document["_tableName"] as! String);
        let params = NSMutableDictionary()
        params["key"] = CloudApp.appKey!
        params["document"] = document
        
        CloudCommunications._request("DELETE", url: NSURL(string: url)!, params: params, callback:
            {(response: CloudBoostResponse) in
                callback(response)
        })
    }
    
    /// Bulk save all object in a table.
    /// - Note: The operation is made using a single api call.
    ///
    /// - Parameter array: an array of CloudObject to be saved
    /// - Parameter callback: block where receiving results of the operation
    
    public static func saveAll(array: [CloudObject], callback: (CloudBoostResponse)->Void) {
        
        // Ready the response
        let resp = CloudBoostResponse()
        resp.success = true
        var count = 0
        
        // Iterate through the array
        for object in array {
            let url = CloudApp.serverUrl + "/data/" + CloudApp.appID! + "/"
                + (object.document["_tableName"] as! String);
            let params = NSMutableDictionary()
            params["key"] = CloudApp.appKey!
            params["document"] = object.document
            
            CloudCommunications._request("PUT", url: NSURL(string: url)!, params: params, callback:
                {(response: CloudBoostResponse) in
                    count += 1
                    if(response.success){
                        if let newDocument = response.object {
                            object.document = newDocument as! NSMutableDictionary
                        }
                    }else{
                        resp.success = false
                        resp.message = "one or more objects were not saved"
                    }
                    if(count == array.count){
                        resp.object = count
                        callback(resp)
                    }
            })
        }
    }
    
    /// Bulk delete all object in a table.
    /// - Note: The operation is made using a single api call.
    ///
    /// - Parameter array: an array of CloudObject to be deleted
    /// - Parameter callback: block where receiving results of the operation
    
    public static func deleteAll(array: [CloudObject], callback: (CloudBoostResponse)->Void) {
        
        // Ready the response
        let resp = CloudBoostResponse()
        resp.success = true
        var count = 0
        
        // Iterate through the array
        for object in array {
            let url = CloudApp.serverUrl + "/data/" + CloudApp.appID! + "/"
                + (object.document["_tableName"] as! String);
            let params = NSMutableDictionary()
            params["key"] = CloudApp.appKey!
            params["document"] = object.document
            
            CloudCommunications._request("DELETE", url: NSURL(string: url)!, params: params, callback:
                {(response: CloudBoostResponse) in
                    count += 1
                    if(!response.success){
                        resp.success = false
                        resp.message = "one or more objects were not deleted"
                    }
                    if(count == array.count){
                        callback(resp)
                    }
            })
        }
    }
    
    /// Start listening to events on an intire table
    ///
    /// - Parameter tableName: table to listen to events from
    /// - Parameter eventType: one of created, deleted, updated
    /// - Parameter objectClass: (optional) Class of the object that has to be retturned from each resulsts. It has to be a CloudObject subclass; if not specificied, CloudObject class will be user
    /// - Parameter handler: block to receive update/create/delete notification
    /// - Parameter callback: block where receiveing other notifications, as errors
    
    public static func on(tableName: String,
                          eventType: String,
                          objectClass: CloudObject.Type = CloudObject.self,
                          handler: ([CloudObject]?)->Void, callback: (error: String?)->Void){
        
        let tableName = tableName.lowercaseString
        let eventType = eventType.lowercaseString
        if CloudApp.SESSION_ID == nil {
            callback(error: "Invalid session ID")
        }else{
            print("Using session ID: \(CloudApp.SESSION_ID)")
        }
        if eventType == "created" || eventType == "deleted" || eventType == "updated" {
            let str = (CloudApp.getAppId()! + "table" + tableName + eventType).lowercaseString
            let payload = NSMutableDictionary()
            payload["room"] = str
            
            CloudSocket.getSocket().on(str, callback: {
                data, ack in
                
                var objectsArray = [CloudObject]()
                
                for document in data {
                    
                    if let dictionary = document as? NSDictionary {
                        
                        let object = objectClass.cloudObjectFromDocumentDictionary(dictionary,
                            documentType: objectClass)
                        
                        objectsArray.append(object)
                    }
                }
                
                handler(objectsArray)
            })
            
            CloudSocket.getSocket().on("connect", callback: { data, ack in
                print("sessionID: \(CloudSocket.getSocket().sid)")
                payload["sessionId"] = CloudSocket.getSocket().sid
                CloudSocket.getSocket().emit("join-object-channel", payload)
                callback(error: nil)
            })
            
            CloudSocket.getSocket().connect(timeoutAfter: 15, withTimeoutHandler: {
                print("Timeout")
                callback(error: "Timed out")
            })
            
        } else {
            callback(error: "invalid event type, it can only be (created, deleted, updated)")
        }
    }
    
    /// Start listening to events on an intire table
    ///
    /// - Parameter tableName: table to listen to events from
    /// - Parameter eventType: one of created, deleted, updated
    /// - Parameter objectClass: (optional) Class of the object that has to be retturned from each resulsts. It has to be a CloudObject subclass; if not specificied, CloudObject class will be user
    /// - Parameter handler: block to receive update/create/delete notification
    /// - Parameter callback: block where receiveing other notifications, as errors
    public static func on(tableName: String,
                          eventTypes: [String],
                          objectClass: CloudObject.Type = CloudObject.self,
                          handler: ([CloudObject]?)->Void,
                          callback: (error: String?)->Void) {
        
        let tableName = tableName.lowercaseString
        if CloudApp.SESSION_ID == nil {
            callback(error: "Invalid session ID")
        }else{
            print("Using session ID: \(CloudApp.SESSION_ID)")
        }
        var payloads = [NSMutableDictionary]()
        
        for (index,event) in eventTypes.enumerate() {
            if event == "created" || event == "deleted" || event == "updated" {
                let str = (CloudApp.getAppId()! + "table" + tableName + event).lowercaseString
                payloads.insert([:], atIndex: index)
                payloads[index]["room"] = str
                CloudSocket.getSocket().on(str, callback: {
                    data, ack in
                    
                    var objectsArray = [CloudObject]()
                    
                    for document in data {
                        
                        if let dictionary = document as? NSDictionary {
                            
                            let object = objectClass.cloudObjectFromDocumentDictionary(dictionary,
                                documentType: objectClass)
                            
                            objectsArray.append(object)
                        }
                    }
                    
                    handler(objectsArray)
                })
            }else{
                callback(error: "invalid event type, it can only be (created, deleted, updated)")
                return
            }
        }
        CloudSocket.getSocket().on("connect", callback: { data, ack in
            print("sessionID: \(CloudSocket.getSocket().sid)")
            for (index,_) in payloads.enumerate() {
                payloads[index]["sessionId"] = CloudSocket.getSocket().sid
                CloudSocket.getSocket().emit("join-object-channel", payloads[index])
            }
            callback(error: nil)
        })
        CloudSocket.getSocket().connect(timeoutAfter: 15, withTimeoutHandler: {
            print("Timeout")
            callback(error: "Timed out")
        })
        
    }
    
    /// Start listening to events on an intire table or a specific query
    ///
    /// - Parameter tableName: table to listen to events from
    /// - Parameter eventType: one of created, deleted, updated
    /// - Parameter cloudQuery: (optional) CloudQeuery object to apply to the data
    /// - Parameter objectClass: (optional) Class of the object that has to be retturned from each resulsts. It has to be a CloudObject subclass; if not specificied, CloudObject class will be user
    /// - Parameter handler: block to receive update/create/delete notification
    /// - Parameter callback: block where receiveing other notifications, as errors
    
    public static func on(tableName: String,
                          eventType: String,
                          query: CloudQuery,
                          objectClass: CloudObject.Type = CloudObject.self,
                          handler: ([CloudObject]?)->Void,
                          callback: (error: String?)->Void) {
        
        let eventType = eventType.lowercaseString
        if query.getTableName() != tableName {
            print(query.getTableName())
            print(tableName)
            callback(error: "CloudQuery TableName and CloudNotification TableName should be same")
            return
        }
        // if select not equal to an empty mutable dictionary
        if query.getSelect() != NSMutableDictionary() {
            callback(error: "You cannot pass the query with select in CloudNotifications")
            return
        }
        var countLimit = query.getLimit()
        if eventType == "created" || eventType == "deleted" || eventType == "updated" {
            let str = (CloudApp.getAppId()! + "table" + tableName + eventType).lowercaseString
            let payload = NSMutableDictionary()
            payload["room"] = str
            
            CloudSocket.getSocket().on(str, callback: {
                data, ack in
                
                var objectsArray = [CloudObject]()
                
                for document in data {
                    
                    if let dictionary = document as? NSDictionary {
                        
                        let object = objectClass.cloudObjectFromDocumentDictionary(dictionary,
                            documentType: objectClass)
                        
                        if CloudObject.validateNotificationQuery(object, query: query)
                            && countLimit != 0 {
                            
                            countLimit -= 1
                            objectsArray.append(object)
                        }
                    }
                }
                
                if objectsArray.count > 0{
                    handler(objectsArray)
                }
            })
            CloudSocket.getSocket().on("connect", callback: { data, ack in
                print("sessionID: \(CloudSocket.getSocket().sid)")
                payload["sessionId"] = CloudSocket.getSocket().sid
                CloudSocket.getSocket().emit("join-object-channel", payload)
                callback(error: nil)
            })
            CloudSocket.getSocket().connect(timeoutAfter: 15, withTimeoutHandler: {
                print("Timeout")
                callback(error: "Timed out")
            })
            
            
            
        } else {
            callback(error: "invalid event type, it can only be (created, deleted, updated)")
        }
    }
    
    /// Stop listening to events on an intire trable previously registered as listinere with method .on
    ///
    /// - Parameter tableName: table to stop listen from
    /// - Parameter eventType: one of created, deleted, updated
    /// - Parameter callback: block where receiveing the result of the operation
    
    public static func off(tableName: String,
                           eventType: String,
                           callback: (error: String?)->Void) {
        
        let tableName = tableName.lowercaseString
        let eventType = eventType.lowercaseString
        if eventType == "created" || eventType == "deleted" || eventType == "updated" {
            let str = (CloudApp.getAppId()! + "table" + tableName + eventType).lowercaseString
            
            CloudSocket.getSocket().emit("leave-object-channel", str)
            CloudSocket.getSocket().on(str, callback: {_,_ in})
            
            
        } else {
            callback(error: "invalid event type, it can only be (created, deleted, updated)")
        }
    }
    
    private static func validateNotificationQuery(object: CloudObject, query: CloudQuery) -> Bool {
        var valid = false
        
        // if query is equal to empty dictionary
        if query.getQuery() == NSMutableDictionary(){
            return valid
        }
        if query.getLimit() == 0 {
            return valid
        }
        if query.getSkip() > 0 {
            query.setSkip((query.getSkip())-1)
            return valid
        }
        let realQuery = query.getQuery()
        realQuery["$include"] = nil
        realQuery["$all"] = nil
        realQuery["$includeList"] = nil
        valid = CloudQuery.validateQuery(object, query: realQuery)
        
        return valid
    }
    
    internal static func cloudObjectFromDocumentDictionary(dictionary: NSDictionary,
                                                           documentType type: CloudObject.Type? = nil) -> CloudObject {
        
        let tableName = dictionary["_tableName"] as! String

        var objectClass: CloudObject.Type

        if let type = type {
            objectClass = type
        } else {
            objectClass = CloudApp.objectClassForTableName(tableName)
        }
        
        let object = objectClass.init(tableName: tableName)
        object.document = NSMutableDictionary(dictionary: dictionary as [NSObject : AnyObject], copyItems: true)
        
        return object
    }
    
}