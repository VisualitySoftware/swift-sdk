//
//  CloudUserTest.swift
//  CloudBoost
//
//  Created by Randhir Singh on 28/03/16.
//  Copyright © 2016 Randhir Singh. All rights reserved.
//

import XCTest
@testable import CloudBoost

class CloudUserTest: XCTestCase {

    override func setUp() {
        super.setUp()
        let app = CloudApp.init(appID: "xckzjbmtsbfb", appKey: "345f3324-c73c-4b15-94b5-9e89356c1b4e")
        app.setIsLogging(true)
        app.setMasterKey("f5cc5cb3-ba0d-446d-9e51-e09be23c540d")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    // Should sign up  a user
    func testUserSignup(){
        let expectation = expectationWithDescription("signup a user on the app")
        let username = Util.makeString(10)
        let email = Util.makeEmail()
        let user = CloudUser(username: username, password: "abcdef")
        user.setEmail(email)
        
        do{
            try user.signup({
                response in
                XCTAssert(response.success)
                expectation.fulfill()
            })
        } catch let error as CloudBoostError {
            print(error)
        } catch {
            print("Could not catch!")
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    // Should login a user
    func testUserLogin(){
        let expectation = expectationWithDescription("login a user on the app")
        let user = CloudUser(username: "randhirsingh", password: "abcdef")
        user.setEmail("randhirsingh051@gmail.com")
        do{
            try user.login({
                resp in
                XCTAssert(resp.success)
                print("user logged in: \(user.getId())")
                expectation.fulfill()
            })
        } catch let error as CloudBoostError {
            print(error)
        } catch {
            print("Could not catch!")
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // SHould not change password wher the user is logged in
    func testLoggedInPasswordChange(){
        let expectation = expectationWithDescription(("dont change password when logged in"))
        
        let user = CloudUser(username: Util.makeString(10), password: "")
        user.set("password", value: "password")
        user.setEmail("rick.rox10@gmail.com")
        try! user.signup({
            (response: CloudBoostResponse) in
            if(response.success){
                CloudUser.resetPassword(user.getEmail()!, callback: {
                    (reponse: CloudBoostResponse) in
                    response.log()
                    expectation.fulfill()
                })
            }
        })
        waitForExpectationsWithTimeout(30, handler: nil)
        
    }
    
    // Should resset password
    func testRestPassword() {
        let expectation = expectationWithDescription("should reset password")
        
        CloudUser.resetPassword("randhirsingh051@gmail.com", callback: {
            (response: CloudBoostResponse) in
            response.log()
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // Should change password
    func testChangePassword() {
        let expectation = expectationWithDescription("should reset password")
        
        let user = CloudUser(username: "randhirsingh", password: "abcdef")
        user.setEmail("randhirsingh051@gmail.com")
        do{
            try user.login({ resp in
                print("user logged in: \(user.getId())")
                user.changePassword("abcdef", newPassword: "qwerty", callback: { res in
                    res.log()
                    expectation.fulfill()
                })
                
            })
        } catch {
            print("Could not catch!")
        }

        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // Should send a rest email with email setting and default templates
    func testResetEmail(){
        
    }
    
    // Should logout the user
    func testLogoutUser(){
        let exp = expectationWithDescription("logout user")
        let user = CloudUser(username: "randhirsingh", password: "abcdef")
        user.setEmail("randhirsingh051@gmail.com")
        do{
            try user.login({
                resp in
                XCTAssert(resp.success)
                print("user logged in: \(user.getId())")
                try! user.logout({
                    response in
                    XCTAssert(response.success)
                    exp.fulfill()
                })
            })
        } catch let error as CloudBoostError {
            print(error)
        } catch {
            print("Could not catch!")
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // Should create a user and get version
    func testCreateUserVersion(){
        let exp = expectationWithDescription("create user and get the version")
        let username = Util.makeString(10)
        let email = Util.makeEmail()
        
        let user = CloudUser(username: username, password: "abcdef")
        user.setEmail(email)
        try! user.signup({
            resp in
            XCTAssert(resp.success)
            if user.getUsername()! == username && Int(user.getVersion()!) >= 0 {
                exp.fulfill()
            }
        })
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // sshould do a query on user
    func testQueryUser() {
        let exp = expectationWithDescription("query on user")
        let username = Util.makeString(10)
        let email = Util.makeEmail()
        
        let user = CloudUser(username: username, password: "abcdef")
        user.setEmail(email)
        user.setEmail(email)
        try! user.signup({
            response in
            let query = CloudQuery(tableName: "User")
            query.findById(user.getId()!, callback: {
                resp in
                XCTAssert(resp.success)
                resp.log()
                exp.fulfill()
            })
        })
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // should assign a role to the user
    func testAssignRole(){
        let exp = expectationWithDescription("ASsign role to a user")
        let roleName = "normal"
        let role = CloudRole(roleName: roleName)
//        role.save({
//            resp in
//            if resp.success {
                let user = CloudUser(username: "randhirsingh", password: "abcdef")
                user.setEmail("randhirsingh051@gmail.com")
                try! user.login({
                    resp in
                    if resp.success {
                        try! user.addToRole(role, callback: {
                            response in
                            response.log()
                            XCTAssert(response.success)
                            exp.fulfill()
                        })
                    }
                })
//            } else {
//                XCTAssert(false)
//                exp.fulfill()
//            }
//        })
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    // get saved user
    func testGetSaveduser(){
        let exp = expectationWithDescription("get saved user")
        let username = Util.makeString(10)
        let email = Util.makeEmail()
        let user = CloudUser(username: username, password: "abcdef")
        user.setEmail(email)
        
        user.getEmail()
        do{
            try user.signup({
                response in
                let user = CloudUser.getCurrentUser()
                print(user?.getUsername())
                print(user?.getPassword())
                XCTAssert(response.success)
                exp.fulfill()
            })
        } catch let error as CloudBoostError {
            print(error)
        } catch {
            print("Could not catch!")
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    // User login, fetch, save and logout
    func testLostPassword() {
        
        _ = expectationWithDescription("get let user")
        
        let username = "michele.longhi@me.com"
        let password = "111296"
        let user = CloudUser(username: username, password: password)
        user.setEmail(username)
        
        try! user.login { response in
            
            if response.success {
                
                user.set("favorites", value: ["60173"])
            }
            
            user.save {response in
                
                if response.success {
                    
                    try! user.logout{ response in
                        
                        if response.success {
                            
                            let username = "michele.longhi@me.com"
                            let password = "111296"
                            let user = CloudUser(username: username, password: password)
                            user.setEmail(username)
                            
                            try! user.login{ response in
                            
                                XCTAssert(response.success, "Login failed!")
                            }
                        }
                    }
                }
            }
        }
    
        waitForExpectationsWithTimeout(200, handler: nil)
    }

}
