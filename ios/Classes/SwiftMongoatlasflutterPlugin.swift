import Flutter
import UIKit

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

public class SwiftMongoatlasflutterPlugin: NSObject, FlutterPlugin {
    var client: MongoAtlasClient?


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mongoatlasflutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMongoatlasflutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "getPlatformVersion":
            self.getPlatformVersion(result: result)
            break

        case "connectMongo":
            self.connectMongo(call: call,result: result)
            break

        case "insertDocument":
            self.insertDocument(call: call, result: result)
            break
            
//        case "insertDocuments":
//            self.insertDocuments(call: call, result: result)

        case "deleteDocument":
            self.deleteDocument(call: call, result: result)
            break

        case "deleteDocuments":
            self.deleteDocuments(call: call, result: result)
            break
        
        case "findDocuments":
            self.findDocuments(call: call, result: result)
            break
            
        case "findDocument":
            self.findDocument(call: call, result: result)
            break
            
        case "countDocuments":
            self.countDocuments(call: call, result: result)
            break
            
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

        let stitchAppClient = try? Stitch.initializeDefaultAppClient(withClientAppID: clientAppId!)
//
//
        stitchAppClient?.auth.login(withCredential: AnonymousCredential()) { authResult in
            switch authResult {
            case .success(let user):
                let mongoClient = try? stitchAppClient?.serviceClient(
                    fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
                )
                
                self.client = MongoAtlasClient(client: mongoClient!)

                result(true)
                break

            case .failure(let error):
                // todo:
                break


            }
        }
    }

    // DONE!
    func insertDocument(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        
        let args = call.arguments as! Dictionary<String, Any>
        
//        let databaseName = call.argument<String>("database_name")
//        let collectionName = call.argument<String>("collection_name")
//        let data = call.argument<HashMap<String, Any>>("data")
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let data = args["data"] as? Dictionary<String, Any>
        
        self.client?.insertDocument(
            databaseName: databaseName,
            collectionName: collectionName,
            data: data,
            onCompleted: {
                result(true)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
        
    }
    
    func deleteDocument(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>

        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        
        self.client?.deleteDocument(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
    }
    
    func deleteDocuments(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        
        self.client?.deleteDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
    }
    
    func findDocuments(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        
        self.client?.findDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            onCompleted: {value in
                result(value)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
    }
    
    func findDocument(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        
        self.client?.findDocument(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            onCompleted: {value in
                result(value)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
    }
    
    func countDocuments(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
    
        self.client?.countDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            onCompleted: {value in
                result(value)
            },
            onError: { message in
                result(FlutterError(
                    code: "ERROR",
                    message: message,
                    details: nil
                ))
            }
        )
    }
}



