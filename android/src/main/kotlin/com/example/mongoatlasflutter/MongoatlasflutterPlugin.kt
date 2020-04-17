package com.example.mongoatlasflutter

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.mongodb.stitch.android.core.Stitch
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import com.mongodb.stitch.core.auth.providers.anonymous.AnonymousCredential


/** MongoatlasflutterPlugin */
public class MongoatlasflutterPlugin : FlutterPlugin, MethodCallHandler {


    private lateinit var client: MongoAtlasClient

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "mongoatlasflutter")
        channel.setMethodCallHandler(this);
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
            val channel = MethodChannel(registrar.messenger(), "mongoatlasflutter")
            channel.setMethodCallHandler(MongoatlasflutterPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> getPlatformVersion(result)
            "connectMongo" -> connectMongo(call, result)
            "insertDocument" -> insertDocument(call, result)

//            "insertDocuments" -> this.insertDocuments(call, result)
//            
            "deleteDocument" -> this.deleteDocument(call, result)
//            "deleteDocuments" -> this.deleteDocuments(call, result)
//            
            "findDocuments" -> this.findDocuments(call, result)
            "findDocument" -> this.findDocument(call, result)
            
            "countDocuments" ->  this.countDocuments(call, result)
            
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



        stitchAppClient.auth.loginWithCredential(AnonymousCredential())
                .addOnSuccessListener {
                    // More code here

                    val mongoClient = stitchAppClient.getServiceClient(
                            RemoteMongoClient.factory,
                            "mongodb-atlas"
                    )

                    client = MongoAtlasClient(mongoClient)


                    result.success(true)
                }
                .addOnFailureListener {
                    result.error("ERROR", "Anonymous Provider Not Deployed", "")
                }
//
//      }
//    }
//
//    thread.start()

    }

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
            if(it.isSuccessful)
                result.success(true)
            else
                result.error("Error", "Failed to insert a document - Permission DENIED", "")

        }
    }

    // TODO: CHECK ALL THIS OPERATIONS !!!!
    private fun insertDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        val data = call.argument<HashMap<String, Any>>("data")


//        val task = client.insertDocuments(
//                databaseName,
//                collectionName,
//                data
//        )
//
//        if (task == null)
//            result.error("Error", "Failed to insert a document", "")
//
//        task!!.addOnCompleteListener {
//            if(it.isSuccessful)
//                result.success(true)
//            else
//                result.error("Error", "Failed to insert a document - Permission DENIED", "")
//
//        }
    }
   
    private fun deleteDocument(@NonNull call: MethodCall, @NonNull result: Result) {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
     //   val filter = call.argument<HashMap<String, Any>>("filter")


        val task = client.deleteDocument(
                databaseName,
                collectionName
                //add: filter
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
    private fun deleteDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        //   val filter = call.argument<HashMap<String, Any>>("filter")

        val task = client.deleteDocuments(
                databaseName,
                collectionName
                // add: filter
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
            if(it.isSuccessful)
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
            if(it.isSuccessful)
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
            if(it.isSuccessful)
                result.success(it.result)
            else
                result.error("Error", "Failed to count the collection - Permission DENIED", "")

        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


}
