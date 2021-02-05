package com.example.flutter_mongo_stitch

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

//import com.mongodb.stitch.android.core.Stitch
//import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import io.flutter.plugin.common.EventChannel
import android.content.Context
import android.util.Log
import com.example.flutter_mongo_stitch.streamHandlers.AuthStreamHandler
import com.example.flutter_mongo_stitch.streamHandlers.StreamHandler
import io.realm.Realm
//import com.mongodb.stitch.android.core.StitchAppClient

import io.realm.mongodb.App
import io.realm.mongodb.AppConfiguration
import io.realm.mongodb.AppException
import io.realm.mongodb.User

/** FlutterMongoStitchPlugin */
public class FlutterMongoStitchPlugin: FlutterPlugin, MethodCallHandler {

//    private lateinit var stitchAppClient: StitchAppClient
    private lateinit var app: App;
    private lateinit var client: MyMongoStitchClient
    private lateinit var appContext: Context

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var streamsChannel: StreamsChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_mongo_stitch")
        channel.setMethodCallHandler(this)

        appContext = flutterPluginBinding.applicationContext

        streamsChannel = StreamsChannel(flutterPluginBinding.binaryMessenger, "streams_channel_test")
        streamsChannel.setStreamHandlerFactory(object: StreamsChannel.StreamHandlerFactory{
            override fun create(arguments: Any?): EventChannel.StreamHandler? {
                if (arguments == null || arguments !is Map<*, *> || arguments["handler"] == null)
                    return null

                return when(arguments["handler"]){
                    "watchCollection" -> StreamHandler(client, arguments)
                    "auth" -> AuthStreamHandler(client, app, arguments)
                    else -> null
                }
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
            "connectMongo" -> connectMongo(call, result)

            // Database
            "insertDocument" -> insertDocument(call, result)
            "insertDocuments" -> insertDocuments(call, result)
            "deleteDocument" -> deleteDocument(call, result)
            "deleteDocuments" -> deleteDocuments(call, result)
            "findDocuments" -> findDocuments(call, result)
            "findDocument" -> findDocument(call, result)
            "countDocuments" -> countDocuments(call, result)
            "updateDocument" -> updateDocument(call , result)
            "updateDocuments" -> updateDocuments(call , result)
            "aggregate" -> aggregate(call, result)

            // Auth
            "signInAnonymously" -> signInAnonymously(result)
            "signInWithUsernamePassword" -> signInWithUsernamePassword(call, result)
            "signInWithGoogle" -> signInWithGoogle(call, result)
            "signInWithFacebook" -> signInWithFacebook(call, result)
            "signInWithCustomJwt" -> signInWithCustomJwt(call, result)

            "registerWithEmail" -> registerWithEmail(call, result)
            "logout" -> logout(result)
            "getUserId" -> getUserId(result)
            "getUser" -> getUser(result)
            "sendResetPasswordEmail" -> sendResetPasswordEmail(call, result)

            // Stitch Functions
            "callFunction" -> callFunction(call, result)

            else -> result.notImplemented()
        }


    }

    private fun connectMongo(@NonNull call: MethodCall, @NonNull result: Result) {
        val clientAppId = call.argument<String>("app_id")

        if (clientAppId == null) {
            result.error("ERROR", "Not provided a MongoRealm App ID", "")
        }


        Realm.init(appContext);
        try {
       //     Stitch.initializeDefaultAppClient(clientAppId!!)
            app = App(AppConfiguration.Builder(clientAppId).build())
        }
        catch (e: Exception){
            Log.d("MongoRealm", e.message);
        }

        val user: User? = app.currentUser()
        val mongoClient =  user?.getMongoClient(
                "mongodb-atlas"
        )


        client = MyMongoStitchClient(mongoClient, app)


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


    private fun signInAnonymously(@NonNull result: Result) {

//        try {
//            //     Stitch.initializeDefaultAppClient(clientAppId!!)
//            app = App(AppConfiguration.Builder(clientAppId).build())
//        }
//        catch (e: Exception){
//            Log.d("MongoRealm", e.message);
//        }





        client.signInAnonymously(App.Callback {
            if (it.isSuccess) {
                val user = it.get();
                result.success(user.toMap());
            } else {
                result.error("ERROR", "Anonymous Provider Not Deployed", "")
            }
        })
    }

    private fun signInWithUsernamePassword(@NonNull call: MethodCall, @NonNull result: Result) {
        val username = call.argument<String>("username") ?: ""
        val password = call.argument<String>("password") ?: ""

        client.signInWithUsernamePassword(username, password, App.Callback {
            if (it.isSuccess) {
                val user = it.get();
                result.success(user.toMap());
            } else {
                result.error("ERROR", "UserEmailPassword Provider Login failed: ${it.error}", "")
            }
        })

//        val task = client.signInWithUsernamePassword(username, password)
//
//        task.addOnSuccessListener {
//            result.success(it.toMap())
//        }.addOnFailureListener {
//            result.error("ERROR", "UserEmailPassword Provider Login failed: ${it.message}", "")
//        }
    }

    private fun signInWithGoogle(@NonNull call: MethodCall, @NonNull result: Result){
         val authCode = call.argument<String>("code") ?: ""

        client.signInWithGoogle(authCode, App.Callback {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Google Provider Login failed: ${it.error?.message ?: '?'}", null)//${it.exception?.message}", "")
            }
        })
//        val task = client.signInWithGoogle(authCode)
//
//        task.addOnCompleteListener {
//            if(it.isSuccessful){
//                result.success(it.result!!.toMap())
//            }
//            else{
//                result.error("ERROR", "Google Provider Login failed: ${it.exception?.message ?: '?'}", null)//${it.exception?.message}", "")
//            }
//        }
    }

    private fun signInWithFacebook(@NonNull call: MethodCall, @NonNull result: Result){
        val token = call.argument<String>("token") ?: ""


        client.signInWithFacebook(token, App.Callback {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Facebook Provider Login failed: ${it.error.message}", null)            }
        })
//        val task = client.signInWithFacebook(token)
//
//        task.addOnCompleteListener {
//            if(it.isSuccessful){
//                result.success(it.result!!.toMap())
//            }
//            else{
//                result.error("ERROR", "Facebook Provider Login failed: ", null)//${it.exception?.message}", "")
//            }
//        }
    }

    private fun signInWithCustomJwt(@NonNull call: MethodCall, @NonNull result: Result){
        val token = call.argument<String>("token") ?: ""

      //  val token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJteXN0aXRjaGFwcC1manBtbiIsImV4cCI6MTYyMTc5MzQyMSwiaWF0IjoxNjExODMwNjU1LCJzdWIiOiI1ZTlkNzEwZmJjZDg5NTIxOWM2YzFmMWIiLCJ1c2VySWQiOiI1ZTlkNzEwZmJjZDg5NTIxOWM2YzFmMWIifQ.kNowkTYV5J_xoR_aVowuattEcazesM09RmTfzpqJM2M"

        client.signInWithCustomJwt(token, App.Callback {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Custom JWT Provider Login failed: ${it.error.message}", null)            }
        })
// 601204a6a80d3fbab2e3a73f
    }

    private fun registerWithEmail(@NonNull call: MethodCall, @NonNull result: Result) {
        val email = call.argument<String>("email") ?: ""
        val password = call.argument<String>("password") ?: ""

        client.registerWithEmail(email, password, App.Callback {
            if (it.isSuccess) {
                result.success(true)
            } else {
                result.error("ERROR", "Error registering new user: ${it.error?.message}", "")
            }
        })

//        val task = client.registerWithEmail(email, password)
//
//        if (task == null)
//            result.error("Error", "Failed to register a user", "")
//
//        task!!.addOnCompleteListener {
//            if (it.isSuccessful) {
//                result.success(true)
//            } else {
//                result.error("ERROR", "Error registering new user: ${it.exception?.message}", "")
//            }
//        }
    }


    private fun logout(@NonNull result: Result) {

        client.logout(App.Callback {
            if (it.isSuccess) {
                result.success(true)
            } else {
                result.error("ERROR", "Cannot logout user", "")
            }
        })

//        val task = client.logout()
//        task.addOnSuccessListener {
//            result.success(true)
//        }.addOnFailureListener {
//            result.error("ERROR", "Cannot logout user", "")
//        }
    }

    private fun getUserId(@NonNull result: Result) {
        try {
            val id = client.getUserId()

            if(id == null){
                result.error("ERROR", "", null)
            }
            else {
                result.success(true)
            }
        }
        catch (e: AppException){
            result.error("ERROR", "", null)
        }

//        val id = client.getUserId()
//
//        if (id == null) {
//            result.error("ERROR", "", null)
//        } else {
//            result.success(id)
//        }
    }

    private fun getUser(@NonNull result: Result) {

        try {
            val user = client.getUser()
            result.success(user?.toMap())
        }
        catch (e: AppException){
            result.error("ERROR", "Cannot get user", "")
        }

//        val user = client.getUser()
//
//        result.success(user?.toMap())
    }

    private fun sendResetPasswordEmail(@NonNull call: MethodCall, @NonNull result: Result){
        val email = call.argument<String>("email")

        if(email.isNullOrEmpty()){
            result.error("ERROR", "must sent to a valid email", null)
        }

        try {
            client.sendResetPasswordEmail(email!!)
            result.success(true)
        }
        catch (e: AppException){
           result.error("Error", "Failed to send a reset password email: ${e.message}", null)
        }

//        val task = client.sendResetPasswordEmail(email!!)
//
//        if (task == null)
//            result.error("Error", "Failed to send a reset password email", "")
//
//        task!!.addOnCompleteListener {
//            if (it.isSuccessful)
//                result.success(true)
//            else
//                result.error("Error", "Failed to send a reset password email: ${it.exception?.message}", null)
//
//        }
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


        task!!.getAsync {
            if (it.isSuccess)
                result.success(true)
            else
                result.error("Error", "Failed to insert a document: ${it.error?.message ?: '?'}", null)

        }
    }

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

        task!!.getAsync {
            if(it.isSuccess)
                result.success(true)
            else
                result.error("Error", "Failed to insert a document ${it.error?.message}", null)

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

        task!!.getAsync {
            if (it.isSuccess)
                result.success(it.get()?.deletedCount)
            else
                result.error("Error", "Failed to delete a document: ${it.error?.message ?: '?'}", "")

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

        task!!.getAsync {
            if (it.isSuccess)
                result.success(it.get()?.deletedCount)
            else
                result.error("Error", "Failed to insert a document: ${it.error?.message ?: '?'}", "")

        }
    }

    /** ============================================================== */
    // filter option added
    private fun findDocuments(@NonNull call: MethodCall, @NonNull result: Result) {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        val filter = call.argument<String>("filter")

        val projection = call.argument<String>("projection")
        val limit = call.argument<Int>("limit")
        val sort = call.argument<String>("sort")

        val task = client.findDocuments(
                databaseName,
                collectionName,
                filter,
                projection,
                limit,
                sort
        )

        if (task == null)
            result.error("Error", "Failed to find documents", "")


        val queryResults = ArrayList<String>()

        task!!.iterator().getAsync { it ->
            if (!it.isSuccess) {
                result.error("Error", "Failed to find documents: ${it.error?.message ?: '?'}", "")
                return@getAsync;
            }
            if(it.get() != null) {
                it.get().forEach {
                    queryResults.add(it.toJson())
                }
            }
            result.success(queryResults)
        }
//        task!!.forEach {
//            queryResults.add(it.toJson())
//        }.continueWith {
//            if (it.isSuccessful)
//                result.success(queryResults)
//            else
//                result.error("Error", "Failed to insert a document: ${it.exception?.message ?: '?'}", "")
//        }
    }

    // filter option added
    private fun findDocument(@NonNull call: MethodCall, @NonNull result: Result) {
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        val filter = call.argument<String>("filter")
        val projection = call.argument<String>("projection")

        val task = client.findDocument(
                databaseName,
                collectionName,
                filter,
                projection
        )

        if (task == null)
            result.error("Error", "Failed to insert a document", "")

        task!!.getAsync {
            if (it.isSuccess)
                result.success(it.get()?.toJson())
            else
                result.error("Error", "Failed to insert a document: ${it.error?.message ?: '?'}", "")

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

        task!!.getAsync {
            if (it.isSuccess)
                result.success(it.get())
            else
                result.error("Error", "Failed to count the collection: ${it.error?.message ?: '?'}", "")

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

        task!!.getAsync {
            if (it.isSuccess)
                result.success(listOf(it.get()?.matchedCount,it.get()?.modifiedCount))
            else
                result.error("Error", "Failed to update the collection: ${it.error?.message ?: '?'}", "")

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
            result.error("Error", "Failed to update the collection", null)

        task!!.getAsync {
            if (it.isSuccess)
                result.success(listOf(it.get()?.matchedCount,it.get()?.modifiedCount))
            else
                result.error("Error", "Failed to update the collection: : ${it.error?.message ?: '?'}", "")

        }
    }


    private fun aggregate(@NonNull call: MethodCall, @NonNull result: Result){
        val databaseName = call.argument<String>("database_name")
        val collectionName = call.argument<String>("collection_name")
        val pipelineStrings = call.argument<List<String>>("pipeline")


        val task = client.aggregate(
                databaseName,
                collectionName,
                pipelineStrings
        )

        if (task == null)
            result.error("Error", "Failed to perform aggregation", "")

        val aggregationResults = ArrayList<String>()

        task!!.iterator().getAsync {
            if (!it.isSuccess)
                result.error("Error", "Failed to insert a document: ${it.error?.message ?: '?'}", "")

            aggregationResults.add(it.get().next().toJson())
            result.success(aggregationResults)
        }
//        task!!.forEach {
//            aggregationResults.add(it.toJson())
//        }.continueWith {
//            if (it.isSuccessful)
//                result.success(aggregationResults)
//            else
//                result.error("Error", "Failed to perform aggregation: ${it.exception?.message ?: '?'}", "")
//
//        }
    }

    ///====================================================================
    private fun callFunction(@NonNull call: MethodCall, @NonNull result: Result){
        val functionName = call.argument<String>("name")
        val args = call.argument<List<Any>>("args")
        val timeout = call.argument<Int>("timeout")

        if(functionName.isNullOrEmpty()){
            result.error("Error", "Function name is missing", null)
        }


        try {
            val funcResult = client.callFunction(functionName!!, args, timeout?.toLong());
            result.success(funcResult?.toJavaValue())
        }
        catch (e: AppException){
            result.error("Error", "Failed to call function: ${e.message}", "")
        }

//        val task = client.callFunction(functionName!!, args, timeout?.toLong())
//
//        if (task == null)
//            result.error("Error", "Failed to call function - Task Failed", "")
//
//        task!!.addOnCompleteListener {
//            if (it.isSuccessful) {
//                result.success(it.result?.toJavaValue())
//            }
//            else
//                result.error("Error", "Failed to call function: ${it.exception?.message}", "")
//
//        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
