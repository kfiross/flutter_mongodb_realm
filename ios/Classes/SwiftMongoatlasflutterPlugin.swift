import Flutter
import UIKit

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

public class SwiftMongoatlasflutterPlugin: NSObject, FlutterPlugin {
    var mongoClient: RemoteMongoClient?


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mongoatlasflutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMongoatlasflutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "getPlatformVersion":
            self.getPlatformVersion(result: result)
        case "connectMongo" :
            self.connectMongo(call: call,result: result)
        case "insertDocument":
            self.insertDocument(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }

    }

    func getPlatformVersion(result: @escaping FlutterResult) {
        result(UIDevice.current.systemVersion)
    }

    func connectMongo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // todo: implement this


        var args = call.arguments as! Dictionary<String, Any>
        let clientAppId = args["app_id"] as? String

        if (clientAppId == nil) {
            result(FlutterError(code: "ERROR",
                                message: "Not provided a MongoStitch App ID",
                                details: nil))
        }

        let client = try? Stitch.initializeDefaultAppClient(withClientAppID: clientAppId!/*"mystitchapp-fjpmn"*/)
//
//
//
        client?.auth.login(withCredential: AnonymousCredential()) { authResult in
            switch authResult {
            case .success(let user):
//                mongoClient = client.serviceClient(
//                    fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
//                )

                self.mongoClient = try? client?.serviceClient(
                    fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
                )

                result(true)
                break

            case .failure(let error):
                // todo:
                break


            }
        }
    }

    func insertDocument(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        
        let args = call.arguments as! Dictionary<String, Any>
        
//        let databaseName = call.argument<String>("database_name")
//        let collectionName = call.argument<String>("collection_name")
//        let data = call.argument<HashMap<String, Any>>("data")
        
        let databaseName = args["database_name"] as! String
        let collectionName = args["collection_name"] as! String
        let data = args["data"] as? Dictionary<String, Any>
        
//        return mongoClient!!.insertDocument(
//            databaseName,
//            collectionName,
//            data
//        )
        
        // TODO: move to designated function..
        
        //let collection = getCollection(databaseName, collectionName)
        
        let collection = self.mongoClient!.db(databaseName).collection(collectionName)
        
//
//        let dict = [
//            "7": 5,
//            "key": "value"
//        ]
//
        
//        let doc: Dictionary<String, Any> = [
//            "name": "kfir",
//            "time": 1578836236
//        ]
//
        
        //Document.parse(json)
        //let document =  x as? Document //Document()
        
        if(data == nil){
            result(FlutterError(code: "ERROR",
                                message: "Not provided data to insert",
                                details: nil))
            return
        }
        
        // my fu** up solution
        var document = Document()
        for (key) in data!.keys{
            let value = data![key]

            if let bsonValue = value as? String {
                document[key] = bsonValue
            }

            if let bsonValue = value as? Int {
                document[key] = bsonValue
            }

//            if let bsonValue = value as? BSONValue {
//                document[key] = bsonValue
//            }
        }

      
        
        collection.insertOne(document) { result in
            switch result {
            case .success(let result):
                print("Successfully inserted item with _id: \(result.insertedId))");
            case .failure(let error):
                print("Failed to insert item: \(error)");
            }
        }
    }
}
