//
//  CloudUser.swift
//  CloudBoost
//
//  Created by Randhir Singh on 27/03/16.
//  Copyright © 2016 Randhir Singh. All rights reserved.
//

import Foundation

public class CloudUser: CloudObject {
    
    static var currentUser: CloudUser?
    
    public init(username: String, password: String){
        super.init(tableName: "User")
        
        document["username"] = username
        document["password"] = password
        
        _modifiedColumns.append("username")
        _modifiedColumns.append("password")
        
        document["_modifiedColumns"] = _modifiedColumns
    }
    
    private init(doc: NSMutableDictionary){
        super.init(tableName: "User")
        
        self.document = doc
    }
    
    required public init(tableName: String) {
        super.init(tableName: "User")
    }

    // MARK: Setters
    
    public func setEmail(email: String) {
        document["email"] = email
        _modifiedColumns.append("email")
        document["_modifiedColumns"] = _modifiedColumns
    }
    
    public func setUsername(username: String){
        document["username"] = username
        _modifiedColumns.append("username")
        document["_modifiedColumns"] = _modifiedColumns
    }
    
    public func setPassword(password: String){
        document["password"] = password
        _modifiedColumns.append("password")
        document["_modifiedColumns"] = _modifiedColumns
    }
    
    // MARK: Getters
    
    public func getUsername() -> String? {
        return document["username"] as? String
    }
    
    public func getEmail() -> String? {
        return document["email"] as? String
    }
    
    public func getPassword() -> String? {
        return document["password"] as? String
    }
    
    public func getVersion() -> String?{
        return document["_version"] as? String
    }
    
    // MARK: Cloud operations on CloudUser
    
    
    /**
     *
     * Sign Up
     *
     * @param callbackObject
     * @throws CloudBoostError
     */
    public func signup(callback: (response: CloudBoostResponse)->Void) throws{
        if(CloudApp.appID == nil){
            throw CloudBoostError.AppIdNotSet
        }
        if(document["username"] == nil){
            throw CloudBoostError.UsernameNotSet
        }
        if(document["email"] == nil){
            throw CloudBoostError.EmailNotSet
        }
        if(document["password"] == nil){
            throw CloudBoostError.PasswordNotSet
        }
        
        // Setting the payload
        let data = NSMutableDictionary()
        data["document"] = document
        data["key"] = CloudApp.appKey
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/signup"
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in
            if(CloudApp.isLogging()){
                response.log()
            }
            // Save the user if he has been successfully logged in
            if(response.status == 200){
                if let doc = response.object as? NSMutableDictionary{
                    self.document = doc
                    self.setAsCurrentUser()
                }
            }
            callback(response: response)
        })
    }
    
    /**
     *
     * Log in
     *
     * @param callbackObject
     * @throws CloudBoostError
     */
    public func login(callback: (response: CloudBoostResponse)->Void) throws {
        if(CloudApp.appID == nil){
            throw CloudBoostError.AppIdNotSet
        }
        if(document["username"] == nil){
            throw CloudBoostError.UsernameNotSet
        }
        if(document["password"] == nil){
            throw CloudBoostError.PasswordNotSet
        }
        
        // Setting the payload
        let data = NSMutableDictionary()
        data["document"] = document
        data["key"] = CloudApp.appKey
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/login"
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in
            if response.success {
                if let doc = response.object as? NSMutableDictionary {
                    self.resetModificationState()
                    self.document = doc
                    self.setAsCurrentUser()
                }
            }
            // Save the user if he has been successfully logged in
            callback(response: response)
        })
    }
    
    /// Authenticate user against a social provider
    ///
    /// - parameter provider: name of the provider
    /// - parameter accessToken: the access token for the specific provider
    /// - parameter accessSecret: the access secret key for the specific provider
    /// - parameter callback: the response block for this call
    ///
    /// - returns: if response.success is true, response.object will contain a valid CloudUser
    ///
    public class func authenticateWithProvider(provider: String,
                                               accessToken: String,
                                               accessSecret: String,
                                               callback: (response: CloudBoostResponse)->()) throws {
        
        if(CloudApp.appID == nil){
            throw CloudBoostError.AppIdNotSet
        }
        
        let data: NSMutableDictionary = [
            "key": CloudApp.appKey!,
            "provider": provider.lowercaseString,
            "accessToken": accessToken,
            "accessSecret": accessSecret
        ]

        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/loginwithprovider"
        
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in
          
            if let doc = response.object as? NSDictionary where response.success {
                
                if let user = CloudUser.cloudObjectFromDocumentDictionary(doc, documentType: self) as? CloudUser {
                    
                    response.object = user                
                    user.setAsCurrentUser()
                }
            }
            
            callback(response: response)
        })
    }
    
    /**
     *
     * Log out
     *
     * @param callbackObject
     * @throws CloudBoostError
     */
    public func logout(callback: (response: CloudBoostResponse)->Void) throws{
        if(CloudApp.appID == nil){
            throw CloudBoostError.AppIdNotSet
        }
        
        // Setting the payload
        let data = NSMutableDictionary()
        data["document"] = document
        data["key"] = CloudApp.appKey
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/logout"
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in

            if response.success || response.status == 400 {
                
                CloudUser.removeCurrentUser()
            }
            
            // return callback
            callback(response: response)
        })
        
    }
    
    /// Reset the Password associated with a given email
    ///
    /// - parameter email: email addesso of the use requesting password reset
    /// - parameter callback: a block returning a CloudBoostResponse with the response of the operation
    ///
    public static func resetPassword(email: String, callback: (reponse: CloudBoostResponse)->Void) {
        let data = NSMutableDictionary()
        data["key"] = CloudApp.getAppKey()
        data["email"] = email
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/resetPassword"
        CloudCommunications._request("POST", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in
            if(CloudApp.isLogging()){
                response.log()
            }
            // Save the user if he has been successfully logged in            
            callback(reponse: response)
        })
    }
    
    /// Change the password the current logged user
    ///
    /// - parameter oldPassword: The previous password associaterd with this user
    /// - parameter newPassword: The new password to be associated with this user
    /// - parameter callback: The block called after the operation is completed, with an `CloudBoostResponse` containing the result
    ///
    public func changePassword(oldPassword: String, newPassword: String, callback: (response: CloudBoostResponse)->Void) {
        let data = NSMutableDictionary()
        data["key"] = CloudApp.getAppKey()
        data["oldPassword"] = oldPassword
        data["newPassword"] = newPassword
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/changePassword"
        CloudCommunications._request("PUT", url: NSURL(string: url)!, params: data, callback: {
            (response: CloudBoostResponse) in
            if(CloudApp.isLogging()){
                response.log()
            }
            // Save the user if he has been successfully logged in
            if response.status == 200 && response.success {
                if let doc = response.object as? NSMutableDictionary {
                    self.document = doc
                }
            }
            callback(response: response)
        })
    }
    
    /// Add this user to a spcified CloudRole
    ///
    /// - parameter role: The role to be assigned to this user; must be of class CloudRole
    /// - parameter callback: The block called after the operation has bee executed, returning an `CloudBoostResponse` with the result of the operation
    ///
    public func addToRole(role: CloudRole, callback: (response: CloudBoostResponse)-> Void) throws{
        if role.getName() == nil {
            throw CloudBoostError.InvalidArgument
        }
        let params = NSMutableDictionary()
        params["user"] = self.document
        params["role"] = role.document
        params["key"] = CloudApp.getAppKey()
        
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/addToRole"
        CloudCommunications._request("PUT", url: NSURL(string: url)!, params: params, callback: {
            response in
            callback(response: response)
        })
    }
    
    /**
     *
     * Remove from Role
     *
     * @param role
     * @param callbackObject
     * @throws CloudBoostError
     */
    public func removeFromRole(role: CloudRole, callback: (response: CloudBoostResponse)->Void) throws{
        if role.getName() == nil {
            throw CloudBoostError.InvalidArgument
        }
        let params = NSMutableDictionary()
        params["user"] = self.document
        params["role"] = role.document
        params["key"] = CloudApp.getAppKey()
        
        let url = CloudApp.getApiUrl() + "/user/" + CloudApp.getAppId()! + "/removeFromRole"
        CloudCommunications._request("PUT", url: NSURL(string: url)!, params: params, callback: {
            response in
            callback(response: response)
        })
        
    }
    
    /// Check if the current user belongs to a Role
    ///
    /// - parameter role: The role to check against
    /// - returns: true if this user belongs to the Role
    ///
    public func isInRole(role: CloudRole) -> Bool {
        
        if let roles = self.document.get("roles") as? [String] {
            if let rID = role.get("_id") as? String where roles.contains(rID) {
                return true
            }
        }
        
        if let roles = self.document.get("roles") as? [NSDictionary] {
            if (roles.contains { _role in return (_role["_id"] as! String) == role.getId()!}) {
                return true
            }
        }

        if let roles = self.document.get("roles") as? [CloudRole] {
            if (roles.contains { _role in return _role.getId()! == role.getId()!}) {
                return true
            }
        }
        
        return false
    }
   
    /// Get the current user logged in the system
    ///
    /// - returns: A CloudUser object contining the user currently logged in. If nil, no user is logged in in CLoudBoost
    ///
    public static func getCurrentUser<T where T:CloudUser>() -> T? {
        
        if self.currentUser != nil {
            return self.currentUser as? T
        }
        
        let def = NSUserDefaults.standardUserDefaults()
        if let userDat = def.objectForKey("cb_current_user") as? NSData{
            if let doc = NSKeyedUnarchiver.unarchiveObjectWithData(userDat) as? NSMutableDictionary {

                let user = CloudUser.cloudObjectFromDocumentDictionary(doc, documentType: T.self)
                
                self.currentUser = user as? T

                return user as? T
            }
            return nil
        }
        return nil
    }
    
    public func setAsCurrentUser(){
        
        CloudUser.currentUser = self
        
        let def = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(self.document)
        def.setObject(data, forKey: "cb_current_user")
        
    }
    
    public class func removeCurrentUser() {
        
        self.currentUser = nil
        
        let def = NSUserDefaults.standardUserDefaults()
        def.removeObjectForKey("cb_current_user")
    }
    
}