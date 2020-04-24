package com.example.flutter_mongo_stitch

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import com.mongodb.stitch.android.core.Stitch
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import io.flutter.plugin.common.EventChannel



/** FlutterMongoStitchPlugin */
public class FlutterMongoStitchPlugin: FlutterPlugin, MethodCallHandler {


  private lateinit var client: MyMongoStitchClient


  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var streamsChannel: StreamsChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_mongo_stitch")
    channel.setMethodCallHandler(this)

    streamsChannel = StreamsChannel(flutterPluginBinding.binaryMessenger, "streams_channel_test")
    streamsChannel.setStreamHandlerFactory(object: StreamsChannel.StreamHandlerFactory{
      override fun create(arguments: Any?): EventChannel.StreamHandler {
        return StreamHandler(client, arguments)
      }

    })
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_mongo_stitch")
      channel.setMethodCallHandler(FlutterMongoStitchPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> getPlatformVersion(result)
      "connectMongo" -> connectMongo(call, result)
      "insertDocument" -> insertDocument(call, result)

      "insertDocuments" -> insertDocuments(call, result)
//
      "deleteDocument" -> deleteDocument(call, result)
      "deleteDocuments" -> deleteDocuments(call, result)
//
      "findDocuments" -> findDocuments(call, result)
      "findDocument" -> findDocument(call, result)

      "countDocuments" -> countDocuments(call, result)

      ////
      "updateDocument" -> updateDocument(call , result)
      "updateDocuments" -> updateDocuments(call , result)

      /////
      "watch" -> watchCollection(call, result)

      /////
      "signInAnonymously" -> signInAnonymously(result)
      "signInWithUsernamePassword" -> signInWithUsernamePassword(call, result)
      "registerWithEmail" -> registerWithEmail(call, result)
      "logout" -> logout(result)
      "getUserId" -> getUserId(result)

      else -> result.notImplemented()
    }


  }


  private fun getPlatformVersion(@NonNull result: Result) {
    result.success("Android ${android.os.Build.VERSION.RELEASE}")
  }

  private fun connectMongo(@NonNull call: MethodCall, @NonNull result: Result) {
    val clientAppId = call.argument<String>("app_id")

    if (clientAppId == null) {
      result.error("ERROR", "Not provided a MongoStitch App ID", "")
    }

    Stitch.initializeDefaultAppClient(clientAppId!!)

    val stitchAppClient = Stitch.getDefaultAppClient()

    val mongoClient = stitchAppClient.getServiceClient(
            RemoteMongoClient.factory,
            "mongodb-atlas"
    )

    client = MyMongoStitchClient(mongoClient, stitchAppClient.auth)
    result.success(true)
  }

//    private fun signInWithCustomJWT(@NonNull call: MethodCall, @NonNull result: Result) {
////        val username = call.argument<String>("username") ?: ""
//        val token = call.argument<String>("token") ?: ""
//
//        val task = client.signInWithCustomJWT(token)
//
//        if (task == null)
//            result.error("Error", "Failed to Login", "")
//
//
//        task.addOnSuccessListener {
//            result.success(true)
//        }.addOnFailureListener {
//            result.error("ERROR", "UserEmailPassword Provider Not Deployed", "")
//        }
//    }


  private fun signInWithUsernamePassword(@NonNull call: MethodCall, @NonNull result: Result) {
    val username = call.argument<String>("username") ?: ""
    val password = call.argument<String>("password") ?: ""

    val task = client.signInWithUsernamePassword(username, password)

    if (task == null)
      result.error("Error", "Failed to Login", "")


    task!!.addOnSuccessListener {
      result.success(true)
    }.addOnFailureListener {
      result.error("ERROR", "UserEmailPassword Provider Login failed: ${it.message}", "")
    }
  }

  private fun registerWithEmail(@NonNull call: MethodCall, @NonNull result: Result) {
    val email = call.argument<String>("email") ?: ""
    val password = call.argument<String>("password") ?: ""

    val task = client.registerWithEmail(email, password)

    if (task == null)
      result.error("Error", "Failed to register a user", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful) {
        result.success(true)
      } else {
        result.error("ERROR", "Error registering new user: ${it.exception?.message}", "")
      }
    }
  }

  private fun signInAnonymously(@NonNull result: Result) {
    val task = client.signInAnonymously()

    if (task == null)
      result.error("Error", "Failed to Login", "")

    task!!.addOnSuccessListener {
      result.success(true)
    }.addOnFailureListener {
      result.error("ERROR", "Anonymous Provider Not Deployed", "")
    }
  }


  private fun logout(@NonNull result: Result) {
    val task = client.logout()

    task.addOnSuccessListener {
      result.success(true)
    }.addOnFailureListener {
      result.error("ERROR", "Cannot logout user", "")
    }
  }

  private fun getUserId(@NonNull result: Result) {
    val id = client.getUserId()

    if (id == null) {
      result.error("ERROR", "", null)
    } else {
      result.success(id)
    }

  }

  //////////////////////////////////////////////////////////////////////////////
  /**
   *
   */
  private fun insertDocument(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val data = call.argument<HashMap<String, Any>>("data")


    val task = client.insertDocument(
            databaseName,
            collectionName,
            data
    )

    if (task == null)
      result.error("Error", "Failed to insert a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(true)
      else
        result.error("Error", "Failed to insert a document - Permission DENIED", "")

    }
  }

  // TODO: CHECK THIS OPERATION !!!!
  private fun insertDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val list = call.argument<List<String>>("list")


    val task = client.insertDocuments(
            databaseName,
            collectionName,
            list
    )

    if (task == null)
      result.error("Error", "Failed to insert a document", "")

    task!!.addOnCompleteListener {
      if(it.isSuccessful)
        result.success(true)
      else
        result.error("Error", "Failed to insert a document - Permission DENIED", "")

    }
  }

  private fun deleteDocument(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")


    val task = client.deleteDocument(
            databaseName,
            collectionName,
            filter
    )

    if (task == null)
      result.error("Error", "Failed to delete a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(it.result.deletedCount)
      else
        result.error("Error", "Failed to delete a document - Permission DENIED", "")

    }
  }

  private fun deleteDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")

    val task = client.deleteDocuments(
            databaseName,
            collectionName,
            filter
    )

    if (task == null)
      result.error("Error", "Failed to insert a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(it.result.deletedCount)
      else
        result.error("Error", "Failed to insert a document - Permission DENIED", "")

    }
  }

  /** ============================================================== */
  // filter option added
  private fun findDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")

    val task = client.findDocuments(
            databaseName,
            collectionName,
            filter
    )

    if (task == null)
      result.error("Error", "Failed to insert a document", "")


    val queryResults = ArrayList<String>()
    task!!.forEach {
      queryResults.add(it.toJson())
    }.continueWith {
      if (it.isSuccessful)
        result.success(queryResults)
      else
        result.error("Error", "Failed to insert a document - Permission DENIED", "")

    }
  }

  // filter option added
  private fun findDocument(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")


    val task = client.findDocument(
            databaseName,
            collectionName,
            filter
    )

    if (task == null)
      result.error("Error", "Failed to insert a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(it.result.toJson())
      else
        result.error("Error", "Failed to insert a document - Permission DENIED", "")

    }
  }

  // filter option added
  private fun countDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")

    val task = client.countDocuments(
            databaseName,
            collectionName,
            filter
    )

    if (task == null)
      result.error("Error", "Failed to count the collection", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(it.result)
      else
        result.error("Error", "Failed to count the collection - Permission DENIED", "")

    }
  }

  //
  private fun updateDocument(@NonNull call: MethodCall, @NonNull result: Result){
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")
    val update = call.argument<String>("update")

    val task = client.updateDocument(
            databaseName,
            collectionName,
            filter,
            update!!
    )

    if (task == null)
      result.error("Error", "Failed to update a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(listOf(it.result.matchedCount,it.result.modifiedCount))
      else
        result.error("Error", "Failed to update the collection - Permission DENIED", "")

    }
  }

  private fun updateDocuments(@NonNull call: MethodCall, @NonNull result: Result){
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")
    val update = call.argument<String>("update")

    val task = client.updateDocuments(
            databaseName,
            collectionName,
            filter,
            update!!
    )

    if (task == null)
      result.error("Error", "Failed to update a document", "")

    task!!.addOnCompleteListener {
      if (it.isSuccessful)
        result.success(listOf(it.result.matchedCount,it.result.modifiedCount))
      else
        result.error("Error", "Failed to update the collection - Permission DENIED", "")

    }
  }

  private fun watchCollection(@NonNull call: MethodCall, @NonNull result: Result){
    val databaseName = call.argument<String>("database_name")
    val collectionName = call.argument<String>("collection_name")
    val filter = call.argument<String>("filter")
    val update = call.argument<String>("update")

    val task = client.watchCollection(
            databaseName,
            collectionName,
            filter
    )

//    task!!.addOnCompleteListener {
//      if (it.isSuccessful)
//        result.success()
//      else
//        result.error("Error", "Failed to update the collection - Permission DENIED", "")
//
//    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
