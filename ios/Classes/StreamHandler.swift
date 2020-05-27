//
//  StreamHandler.swift
//  flutter_mongo_stitch
//
//  Created by kfir Matit on 25/04/2020.
//

import Foundation
import Flutter

import MongoSwift
import StitchCore
import StitchRemoteMongoDBService


class MyCustomDelegate<T>: ChangeStreamDelegate
    where T: Encodable, T: Decodable
{
    var _onCompleted: (Any)->Void
    init(_ onCompleted: @escaping (Any)->Void){
        self._onCompleted = onCompleted
    }
    
    func didReceive(event: ChangeEvent<T>) {
        self._onCompleted((event.fullDocument as! Document).extendedJSON)
    }
    

    typealias DocumentT = T
    
//    func didReceive(event: ChangeEvent<T>) {
//        // react to events
//        ev
//    }
    
    func didReceive(streamError: Error) {

    }
    
    func didOpen() {
        
    }
    
    func didClose() {
        
    }
}

class Watcher {
    var changeStreamSession: ChangeStreamSession<Document>?
    
    func watch(collection: RemoteMongoCollection<Document>,
               eventSink events: @escaping FlutterEventSink) throws {
        // Watch the collection for any changes. As long as the changeStreamSession
        // is alive, it will continue to send events to the delegate.
        changeStreamSession = try collection.watch(
            delegate: MyCustomDelegate<Document>.init({result in
                    events(result)
            }))
        
    }
    
    func close(){
        changeStreamSession?.close()
    }
}

class StreamHandler : FlutterStreamHandler{
    var client: MyMongoStitchClient
    var watcher = Watcher()
    
    init(client: MyMongoStitchClient) {
        self.client = client
    }
    
    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let args = arguments as! Dictionary<String, Any>
        
        let dbName = args["db"] as! String?
        let collectionName = args["collection"] as! String?
        
        
        do{
            let collection = try self.client.getCollection(
                databaseName: dbName, collectionName: collectionName)

            try self.watcher.watch(collection: collection!, eventSink: events)
        }
        catch{
            
        }

        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.watcher.close()
        
        return nil;
    }
}
