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

