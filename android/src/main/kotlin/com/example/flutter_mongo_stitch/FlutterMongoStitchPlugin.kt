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
import com.google.android.gms.common.Scopes
import com.google.android.gms.common.api.Scope
import android.R.attr.data
import android.content.Context
import com.google.android.gms.tasks.Task
import androidx.core.app.ActivityCompat.startActivityForResult
import android.content.Intent


/** FlutterMongoStitchPlugin */
public class FlutterMongoStitchPlugin: FlutterPlugin, MethodCallHandler {


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
            result.error("ERROR", "Not provided a MongoStitch App ID", "")
        }

        Stitch.initializeDefaultAppClient(clientAppId!!)

        val stitchAppClient = Stitch.getDefaultAppClient()

        val mongoClient = stitchAppClient.getServiceClient(
                RemoteMongoClient.factory,
                "mongodb-atlas"
        )

        client = MyMongoStitchClient(mongoClient, stitchAppClient)
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
        val task = client.signInAnonymously()

        if (task == null)
            result.error("Error", "Failed to Login", "")

        task!!.addOnSuccessListener {
            result.success(mapOf(
                    "id" to it.id,
                    "device_id" to it.deviceId
            ))
        }.addOnFailureListener {
            result.error("ERROR", "Anonymous Provider Not Deployed", "")
        }
    }

    private fun signInWithUsernamePassword(@NonNull call: MethodCall, @NonNull result: Result) {
        val username = call.argument<String>("username") ?: ""
        val password = call.argument<String>("password") ?: ""

        val task = client.signInWithUsernamePassword(username, password)

        if (task == null)
            result.error("Error", "Failed to Login", "")


        task!!.addOnSuccessListener {
            result.success(mapOf(
                    "id" to it.id,
                    "device_id" to it.deviceId
            ))
        }.addOnFailureListener {
            result.error("ERROR", "UserEmailPassword Provider Login failed: ${it.message}", "")
        }
    }

    private fun signInWithGoogle(@NonNull call: MethodCall, @NonNull result: Result){
        val authCode = call.argument<String>("code") ?: ""

        val task = client.signInWithGoogle(authCode)


        task.addOnCompleteListener {
            if(it.isSuccessful){
                result.success(mapOf(
                        "id" to it.result?.id,
                        "device_id" to it.result?.deviceId
                ))
            }
            else{
                result.error("ERROR", "Google Provider Login failed: ", null)//${it.exception?.message}", "")
            }
        }
    }

    private fun signInWithFacebook(@NonNull call: MethodCall, @NonNull result: Result){
        val token = call.argument<String>("token") ?: ""

        val task = client.signInWithFacebook(token)


        task.addOnCompleteListener {
            if(it.isSuccessful){
                result.success(mapOf(
                        "id" to it.result?.id,
                        "device_id" to it.result?.deviceId
                ))
            }
            else{
                result.error("ERROR", "Facebook Provider Login failed: ", null)//${it.exception?.message}", "")
            }
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

    private fun getUser(@NonNull result: Result) {
        val user = client.getUser()

        result.success(mapOf(
                "id" to user?.id,
                "device_id" to user?.deviceId,
                "profile" to mapOf(
                    "name" to user?.profile?.name,
                    "email" to user?.profile?.email,
                    "pictureUrl" to user?.profile?.pictureUrl,
                    "firstName" to user?.profile?.firstName,
                    "lastName" to user?.profile?.lastName,
                    "gender" to user?.profile?.gender,
                    "birthday" to user?.profile?.birthday,
                    "minAge" to user?.profile?.minAge,
                    "maxAge" to user?.profile?.maxAge
                )
        ))
    }

    private fun sendResetPasswordEmail(@NonNull call: MethodCall, @NonNull result: Result){
        val email = call.argument<String>("email")

        if(email.isNullOrEmpty()){
            result.error("ERROR", "must sent to a valid email", null)
        }

        val task = client.sendResetPasswordEmail(email!!)

        if (task == null)
            result.error("Error", "Failed to insert a document", "")

        task!!.addOnCompleteListener {
            if (it.isSuccessful)
                result.success(true)
            else
                result.error("Error", "Failed to send a reset password email: ${it.exception?.message ?: '?'}", null)

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
                result.success(it.result?.deletedCount)
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
                result.success(it.result?.deletedCount)
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
        val projection = call.argument<String>("projection")

        val task = client.findDocument(
                databaseName,
                collectionName,
                filter,
                projection
        )

        if (task == null)
            result.error("Error", "Failed to insert a document", "")

        task!!.addOnCompleteListener {
            if (it.isSuccessful)
                result.success(it.result?.toJson())
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
                result.success(listOf(it.result?.matchedCount,it.result?.modifiedCount))
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
                result.success(listOf(it.result?.matchedCount,it.result?.modifiedCount))
            else
                result.error("Error", "Failed to update the collection - Permission DENIED", "")

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
        task!!.forEach {
            aggregationResults.add(it.toJson())
        }.continueWith {
            if (it.isSuccessful)
                result.success(aggregationResults)
            else
                result.error("Error", "Failed to perform aggregation - Permission DENIED", "")

        }
    }

    ///====================================================================
    private fun callFunction(@NonNull call: MethodCall, @NonNull result: Result){
        val functionName = call.argument<String>("name")
        val args = call.argument<List<Any>>("args")
        val timeout = call.argument<Int>("timeout")

        if(functionName.isNullOrEmpty()){
            result.error("Error", "Function name is missing", null)
        }

        val task = client.callFunction(functionName!!, args, timeout?.toLong())

        if (task == null)
            result.error("Error", "Failed to call function - Task Failed", "")

        task!!.addOnCompleteListener {
            if (it.isSuccessful) {
                result.success(it.result?.toJavaValue())
            }
            else
                result.error("Error", "Failed to call function: ${it.exception?.message}", "")

        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
