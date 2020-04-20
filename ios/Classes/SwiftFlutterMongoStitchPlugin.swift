import Flutter
import UIKit

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

public class SwiftFlutterMongoStitchPlugin: NSObject, FlutterPlugin {
  var client: MongoAtlasClient?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_mongo_stitch", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterMongoStitchPlugin()
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

          /////

          case "signInAnonymously":
              self.signInAnonymously(result)
              break

          case "signInWithUsernamePassword":
              self.signInWithUsernamePassword(call: call, result: result)
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

          default:
              result(FlutterMethodNotImplemented)
          }

      }

      func getPlatformVersion(result: @escaping FlutterResult) {
          result(UIDevice.current.systemVersion)
      }

      func connectMongo(call: FlutterMethodCall, result: @escaping FlutterResult) {

          var args = call.arguments as! Dictionary<String, Any>
          let clientAppId = args["app_id"] as? String

          if (clientAppId == nil) {
              result(FlutterError(code: "ERROR",
                                  message: "Not provided a MongoStitch App ID",
                                  details: nil))
          }

          let stitchAppClient = try! Stitch.initializeDefaultAppClient(withClientAppID: clientAppId!)
  //
  //

          let mongoClient = try? stitchAppClient.serviceClient(
              fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas"
          )

          self.client = MongoAtlasClient(client: mongoClient!, auth: stitchAppClient.auth)
          result(true)
      }

      func signInAnonymously(_ result: @escaping FlutterResult){
          self.client?.signInAnonymously(
              onCompleted: { value in
                  result(value)
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
              onCompleted: { value in
                  result(value)
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
              onCompleted: { value in
                  result(value)
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

      /// ====================================

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

