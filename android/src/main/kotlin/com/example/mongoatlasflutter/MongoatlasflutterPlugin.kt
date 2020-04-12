package com.example.mongoatlasflutter

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.mongodb.stitch.android.core.Stitch
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import com.mongodb.stitch.core.auth.providers.anonymous.AnonymousCredential
import com.mongodb.stitch.core.services.mongodb.remote.RemoteInsertOneResult


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
            "insertDocument" -> {
                val task = insertDocumentIntoCollection(call)

                if (task == null)
                    result.error("Error", "Failed to insert a document", "")

                task!!.addOnCompleteListener {
                    if(it.isSuccessful)
                        result.success(true)
                    else
                        result.error("Error", "Failed to insert a document - Permission DENIED", "")

                }
            }
            else -> result.notImplemented()
        }


    }


    private fun getPlatformVersion(@NonNull result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    private fun connectMongo(@NonNull call: MethodCall, @NonNull result: Result) {
//    val mongoClient = MongoClients.create(
//            "mongodb+srv://kfiross:7c034cfd@cluster0-ugz4h.mongodb.net/test?retryWrites=true&w=majority")

//    launch(Dispatchers.Default) { // will get dispatched to DefaultDispatcher
//      println("Default               : I'm working in thread ${Thread.currentThread().name}")
//    }
//
//    val thread = object : Thread() {
//      override fun run() {
//        val uri = MongoClientURI("mongodb+srv://kfiross:7c034cfd@cluster0-ugz4h.mongodb.net/test?retryWrites=true&w=majority")
//        val mongoClient = MongoClient(uri)
//
//        val database = mongoClient.getDatabase("test")


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


    private fun insertDocumentIntoCollection(@NonNull call: MethodCall)
            : Task<RemoteInsertOneResult>? {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        val data = call.argument<HashMap<String, Any>>("data")


        return client.insertDocument(
                databaseName,
                collectionName,
                data
        )
//        val myFirstDocument = Document()
//        myFirstDocument["time"] = Date().time
//        myFirstDocument["user_id"] = client.auth.user!!.id
//
//        myCollection.insertOne(myFirstDocument)
//                .addOnSuccessListener {
//                    Log.d("STITCH", "One document inserted")
//                }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


}
