import Flutter
import UIKit

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService
import RealmSwift


public class SwiftFlutterMongoStitchPlugin: NSObject, FlutterPlugin {
    var client: MyMongoStitchClient?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_mongo_stitch", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMongoStitchPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        
        let streamsChannel = FlutterStreamsChannel(name: "streams_channel_test", binaryMessenger: registrar.messenger())
        streamsChannel.setStreamHandlerFactory { arguments in
            if (arguments==nil || !(arguments is Dictionary<String, Any>)){
                return nil
            }
            
            if let args = arguments as? Dictionary<String, Any> {
                if let handlerName = args["handler"] as? String{
                    switch(handlerName){
                    case "watchCollection":
                        return StreamHandler(client: instance.client!) // StreamHandler is an instance FlutterStreamHandler
                    
                    case "auth":
//                        if #available(iOS 13.0, *) {
//                            return AuthStreamHandlerRLM(realmApp: instance.client!.app)
//                        } else {
                            // Fallback on earlier versions
                            return AuthStreamHandler(appClient: instance.client!.appClient)
//                        }
                    
                    default:
                        return nil
                    }
                }
            }
            return nil
        }
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
            
        case "insertDocuments":
            self.insertDocuments(call: call, result: result)
            
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
            
        case "updateDocument":
            self.updateDocument(call: call, result: result)
            break
            
        case "updateDocuments":
            self.updateDocuments(call: call, result: result)
            break
            
        case "aggregate":
            self.aggregate(call: call, result: result)
            break
            
        /////
            
        case "signInAnonymously":
            self.signInAnonymously(result)
            break
            
        case "signInWithUsernamePassword":
            self.signInWithUsernamePassword(call: call, result: result)
            break
            
        case "signInWithGoogle":
            self.signInWithGoogle(call: call, result: result)
            break
            
        case "signInWithFacebook":
            self.signInWithFacebook(call: call, result: result)
            break
         
        case "signInWithCustomJwt":
            self.signInWithCustomJwt(call: call, result: result)
            break
        
        case "signInWithCustomFunction":
            self.signInWithCustomFunction(call: call, result: result)
            break
            
        case "signInWithApple":
            self.signInWithApple(call: call, result: result)
            break
        
            
        case "registerWithEmail":
            self.registerWithEmail(call: call, result: result)
            break
            
        case "logout":
            self.logout(result)
            break
            
        case "getUserId":
            self.getUserId(result)
            break
            
        case "getUser":
            self.getUser(result)
            break
            
        case "sendResetPasswordEmail":
            self.sendResetPasswordEmail(call: call, result: result)
            break
            
        ////
        case "callFunction":
            self.callFunction(call: call, result: result)
            break
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    func getPlatformVersion(result: @escaping FlutterResult) {
        result(UIDevice.current.systemVersion)
    }
    
    func connectMongo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as! Dictionary<String, Any>
        let clientAppId = args["app_id"] as? String
        
        if (clientAppId == nil) {
            result(FlutterError(code: "ERROR",
                                message: "Not provided a Realm App ID",
                                details: nil))
        }
        
        let app = App(id: clientAppId!)
        let mongoClientRLM = app.currentUser?.mongoClient("mongodb-atlas")
        
        // todo: remove when removing StitchSDK dependency
        let stitchAppClient = try! Stitch.initializeDefaultAppClient(withClientAppID: clientAppId!)
        
        // todo: remove when removing StitchSDK dependency
        let mongoClient = try? stitchAppClient.serviceClient(
            fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
        )
                
        self.client = MyMongoStitchClient(client: mongoClient!, appClient: stitchAppClient, app: app)
        result(true)
    }
    
    func signInAnonymously(_ result: @escaping FlutterResult){
        self.client?.signInAnonymously(
            onCompleted: { map in
                result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func signInWithUsernamePassword(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let username = args["username"] as! String?
        let password = args["password"] as! String?
        
        self.client?.signInWithUsernamePassword(
            username: username ?? "",
            password: password ?? "",
            onCompleted: { map in
                result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func signInWithGoogle(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let authCode = args["code"] as! String?
        
        self.client?.signInWithGoogle(
            authCode: authCode ?? "",
            onCompleted: { map in
                 result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    
    func signInWithFacebook(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let accessToken = args["token"] as! String?
        
        self.client?.signInWithFacebook(
            accessToken: accessToken ?? "",
            onCompleted: { map in
                 result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func signInWithCustomJwt(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let accessToken = args["token"] as! String?
        
        self.client?.signInWithJWT(
            accessToken: accessToken ?? "",
            onCompleted: { map in
                 result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func signInWithCustomFunction(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let json = args["json"] as! String?
        
        self.client?.signInWithCustomFunction(
            json: json ?? "",
            onCompleted: { map in
                 result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func signInWithApple(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let idToken = args["token"] as! String?
        
        self.client?.signInWithApple(
            idToken: idToken ?? "",
            onCompleted: { map in
                 result(map)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    
    func registerWithEmail(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as! Dictionary<String, Any>
        
        let email = args["email"] as! String?
        let password = args["password"] as! String?
        
        self.client?.registerWithEmail(
            email: email ?? "",
            password: password ?? "",
            onCompleted: { _ in
                result(true)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func logout(_ result: @escaping FlutterResult){
        self.client?.logout(
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
    
    func getUserId(_ result: @escaping FlutterResult){
        let id = self.client?.getUserId()
        
        if (id == nil) {
            result(FlutterError(code: "ERROR", message: "can't get user id ", details: nil))
        } else {
            result(id)
        }
    }
    
    func getUser(_ result: @escaping FlutterResult){
        let user = self.client?.getUser()
    
        if (user == nil){
            result([])
        }
        else {
            result(user!.toMap())
        }
    }
    
    func sendResetPasswordEmail(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let email = args["email"] as? String
        
        if(email==nil || email!.isEmpty){
            result(FlutterError(code: "ERROR", message: "must send to a valid email", details: nil))
        }
        
        self.client?.sendResetPasswordEmail(
            email: email!,
            onCompleted: {
                result(true)
            },
            onError: { message in
                result(FlutterError(code: "ERROR", message: message, details: nil))
            }
        )
        
    }
    
    /// ====================================
    
    
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
            onCompleted: { value in
                result((value as! ObjectId).hex)
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
    
    func insertDocuments(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let list = args["list"] as? Array<String>
        
        self.client?.insertDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            list: list,
            onCompleted: { ids in
                var map:[Int32:String] = [:]
                for (key,value) in ids! {
                    map[Int32(key)] = (value as! ObjectId).hex
                }
                result(map)
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
        let projection = args["projection"] as? String
        let limit = args["limit"] as? Int
        let sort = args["sort"] as? String
        
        
        self.client?.findDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            projectionJson: projection,
            limit: limit,
            sortJson: sort,
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
        let projection = args["projection"] as? String
        
        
        self.client?.findDocument(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            projectionJson: projection,
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
    
    func updateDocument(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        let update = (args["update"] as? String)!
        
        self.client?.updateDocument(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            updateJson: update,
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
    
    func updateDocuments(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let filter = args["filter"] as? String
        let update = (args["update"] as? String)!
        
        self.client?.updateDocuments(
            databaseName: databaseName,
            collectionName: collectionName,
            filterJson: filter,
            updateJson: update,
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message,details: nil))
            }
        )
    }
    
    
    func aggregate(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let args = call.arguments as! Dictionary<String, Any>
        
        let databaseName = args["database_name"] as? String
        let collectionName = args["collection_name"] as? String
        let pipeline = args["pipeline"] as? Array<String>
    
        
        self.client?.aggregate(
            databaseName: databaseName,
            collectionName: collectionName,
            pipelineList: pipeline,
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message,details: nil))
            }
        )
    }
    
    
    
    
    
    func callFunction(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let callArgs = call.arguments as! Dictionary<String, Any>
        
        let name = callArgs["name"] as? String
        let args = callArgs["args"] as? Array<Any>
        let timeout = callArgs["timeout"] as? Int64
        
        if(name == nil || name!.isEmpty){
            result(FlutterError(code: "ERROR", message: "", details: nil))
        }
        
        self.client?.callFunction(
            name: name!,
            args: args,
            requestTimeout: timeout,
            onCompleted: { value in
                result(value)
            },
            onError: { message in
                result(FlutterError(code: "ERROR",message: message, details: nil))
            }
        )
    }
}
