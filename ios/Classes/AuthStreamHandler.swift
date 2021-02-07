//
//  File.swift
//  flutter_mongo_stitch
//
//  Created by kfir Matit on 25/05/2020.
//

import Foundation

import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

import RealmSwift

@available(iOS 13.0, *)
class MyRLMAuthDelegate: ASLoginDelegate
{
    var _events: FlutterEventSink
    init(eventSink events: @escaping FlutterEventSink){
        self._events = events;
    }
    func authenticationDidComplete(error: Error) {
        
    }
    
    func authenticationDidComplete(user: User) {
//        if (user != nil){
//            self._events(user!.toMap())
//        }
//        else {
//            self._events(nil)
//        }
        switch(user.state){
            case .loggedIn:
                self._events(user.toMap())
                break
                
            case .loggedOut:
                self._events(nil)
                break
                
            case .removed:
                self._events(nil)
                break
                
            default:
                break;
        }
        
    }
    
    
}

class MyStitchAuthDelegate: StitchAuthDelegate
{
    var _events: FlutterEventSink
    init(eventSink events: @escaping FlutterEventSink){
        self._events = events
    }

    
    func onAuthEvent(fromAuth: StitchAuth) {
        let user = fromAuth.currentUser
        
        if (user != nil){
            self._events(user!.toMap())
        }
        else {
            self._events(nil)
        }
    }
}


@available(iOS 13.0, *)
class AuthStreamHandlerRLM : FlutterStreamHandler{
    var realmApp: App
    var loginDelegate: MyRLMAuthDelegate?
    
    init(realmApp: App) {
        self.realmApp = realmApp
    }
    
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {

        loginDelegate = MyRLMAuthDelegate(eventSink: events)
        self.realmApp.authorizationDelegate = loginDelegate!

        if let user = self.realmApp.currentUser {
            if(user.isLoggedIn){
                events(user.toMap())
            }
            else {
                events(nil)
            }
        }
        else{
            events(nil)
        }
        
        
        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil;
    }

}

class AuthStreamHandler : FlutterStreamHandler{
    var appClient: StitchAppClient
     var authDelegate:MyStitchAuthDelegate?
    
    init(appClient: StitchAppClient) {
        self.appClient = appClient
    }
    
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {

        authDelegate = MyStitchAuthDelegate(eventSink: events)
        self.appClient.auth.add(authDelegate: self.authDelegate!)
        
        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil;
    }

}

