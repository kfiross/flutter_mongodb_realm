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

//class AuthWatcher {
//    var appClient: StitchAppClient
//
//      init(_ appClient: StitchAppClient) {
//          self.appClient = appClient
//      }
//
//    func watch(eventSink events: @escaping FlutterEventSink) throws {
//        // Watch the collection for any changes. As long as the changeStreamSession
//        // is alive, it will continue to send events to the delegate.
//        self.appClient.auth.add(authDelegate: MyStitchAuthDelegate({result in
//            events(result)
//        }))
//    }
//}

class MyStitchAuthDelegate: StitchAuthDelegate
{
    var _events: FlutterEventSink
    init(eventSink events: @escaping FlutterEventSink){
        self._events = events
    }
    
//    var _onCompleted: (Any?)->Void
//    init(_ onCompleted: @escaping (Any?)->Void){
//        self._onCompleted = onCompleted
//    }
    
    func onAuthEvent(fromAuth: StitchAuth) {
//        DispatchQueue.main.async {
            // Call the desired channel message here.
            let user = fromAuth.currentUser
            
            if (user != nil){
                self._events(user!.toMap())
            }
            else {
                self._events(nil)
            }
//        }
        
    }
  
}

class AuthStreamHandler : FlutterStreamHandler{
    var appClient: StitchAppClient
//    var authWatcher:AuthWatcher
     var authDelegate:MyStitchAuthDelegate?
    
    init(appClient: StitchAppClient) {
        self.appClient = appClient
//        self.authWatcher = AuthWatcher(appClient)
       
    }
    
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {

         authDelegate = MyStitchAuthDelegate(eventSink: events)
//        let args = arguments as! Dictionary<String, Any>
//
//        let dbName = args["db"] as! String?
//        let collectionName = args["collection"] as! String?
        
        
//        do{
//            let collection = try self.client.getCollection(
//                databaseName: dbName, collectionName: collectionName)
//
//            try self.watcher.watch(collection: collection!, eventSink: events)
//        }
//        catch{
//
//        }
//        do{
//      try self.authWatcher.watch(eventSink: events)
//
        self.appClient.auth.add(authDelegate: self.authDelegate!)
//        }
//        catch{
//
//        }

        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        self.watcher.close()
        
        return nil;
    }
    
    
}

