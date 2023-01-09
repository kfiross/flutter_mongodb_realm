package com.example.flutter_mongo_stitch

import android.content.Context
import android.util.Log
import com.example.flutter_mongo_stitch.streamHandlers.AuthStreamHandler
import com.example.flutter_mongo_stitch.streamHandlers.StreamHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.realm.Realm
import io.realm.mongodb.App
import io.realm.mongodb.AppConfiguration
import io.realm.mongodb.AppException
import io.realm.mongodb.User


/** FlutterMongoStitchPlugin */
class FlutterMongoStitchPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var app: App
    private lateinit var client: MyMongoStitchClient
    private lateinit var appContext: Context

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var streamsChannel: StreamsChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor,
            "flutter_mongo_stitch")
        channel.setMethodCallHandler(this)

        appContext = flutterPluginBinding.applicationContext

        streamsChannel =
            StreamsChannel(flutterPluginBinding.binaryMessenger, "streams_channel_test")
        streamsChannel.setStreamHandlerFactory(object : StreamsChannel.StreamHandlerFactory {
            override fun create(arguments: Any?): EventChannel.StreamHandler? {
                if (arguments == null || arguments !is Map<*, *> || arguments["handler"] == null)
                    return null

                return when (arguments["handler"]) {
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

    override fun onMethodCall(call: MethodCall, result: Result) {
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
            "updateDocument" -> updateDocument(call, result)
            "updateDocuments" -> updateDocuments(call, result)
            "aggregate" -> aggregate(call, result)

            // Auth
            "signInAnonymously" -> signInAnonymously(result)
            "signInWithUsernamePassword" -> signInWithUsernamePassword(call, result)
            "signInWithGoogle" -> signInWithGoogle(call, result)
            "signInWithFacebook" -> signInWithFacebook(call, result)
            "signInWithCustomJwt" -> signInWithCustomJwt(call, result)
            "signInWithCustomFunction" -> signInWithCustomAuthFunction(call, result)
            "signInWithApple" -> signInWithApple(call, result)

            "isLoggedIn" -> isLoggedIn(result)
            "linkCredentials" -> linkCredentials(call, result)
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

    private fun connectMongo(call: MethodCall, result: Result) {
        val clientAppId = call.argument<String>("app_id")

        if (clientAppId == null) {
            result.error("ERROR", "Not provided a MongoRealm App ID", "")
        }

        Realm.init(appContext)
        try {
            app = App(AppConfiguration.Builder(clientAppId!!).build())
        } catch (e: Exception) {
            Log.d("MongoRealm", e.message ?: "")
        }

        val user: User? = app.currentUser()
        val mongoClient = user?.getMongoClient(
            "mongodb-atlas"
        )


        client = MyMongoStitchClient(mongoClient, app)


        result.success(true)
    }


    private fun signInAnonymously(result: Result) {

        client.signInAnonymously {
            if (it.isSuccess) {
                val user = it.get()
                result.success(user.toMap())
            } else {
                result.error("ERROR", "Anonymous Provider Not Deployed", "")
            }
        }
    }

    private fun signInWithUsernamePassword(call: MethodCall, result: Result) {
        val username = call.argument<String>("username") ?: ""
        val password = call.argument<String>("password") ?: ""

        client.signInWithUsernamePassword(username, password) {
            if (it.isSuccess) {
                val user = it.get()
                result.success(user.toMap())
            } else {
                result.error("ERROR", "UserEmailPassword Provider Login failed: ${it.error}", "")
            }
        }

    }

    private fun signInWithGoogle(call: MethodCall, result: Result) {
        val authCode = call.argument<String>("code") ?: ""

        client.signInWithGoogle(authCode) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR",
                    "Google Provider Login failed: ${it.error?.message ?: '?'}",
                    null)
            }
        }
    }

    private fun signInWithFacebook(call: MethodCall, result: Result) {
        val token = call.argument<String>("token") ?: ""


        client.signInWithFacebook(token) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Facebook Provider Login failed: ${it.error.message}", null)
            }
        }
    }

    private fun signInWithCustomJwt(call: MethodCall, result: Result) {
        val token = call.argument<String>("token") ?: ""

        client.signInWithCustomJwt(token) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Custom JWT Provider Login failed: ${it.error.message}", null)
            }
        }
    }


    private fun signInWithCustomAuthFunction(call: MethodCall, result: Result) {
        val json = call.argument<String>("json") ?: ""

        client.signInWithCustomAuthFunction(json) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR",
                    "Custom Auth Function Provider Login failed: ${it.error.message}",
                    null)
            }
        }
    }

    private fun signInWithApple(call: MethodCall, result: Result) {
        val idToken = call.argument<String>("token") ?: ""

        client.signInWithApple(idToken) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Sign in with Apple Login failed: ${it.error.message}", null)
            }
        }
    }

    private fun isLoggedIn(result: Result) {
        val isLogged = client.isLoggedIn()
        result.success(isLogged)
    }

    // TODO: check this
    private fun linkCredentials(call: MethodCall, result: Result) {
        val credsJson = call.argument<HashMap<String, Any>>("creds") ?: emptyMap()

        client.linkCredentials(credsJson) {
            if (it.isSuccess) {
                result.success(it.get().toMap())
            } else {
                result.error("ERROR", "Linking accounts failed: ${it.error.message}", null)
            }
        }
    }

    private fun registerWithEmail(call: MethodCall, result: Result) {
        val email = call.argument<String>("email") ?: ""
        val password = call.argument<String>("password") ?: ""

        client.registerWithEmail(email, password) {
            if (it.isSuccess) {
                result.success(true)
            } else {
                result.error("ERROR", "Error registering new user: ${it.error?.message}", "")
            }
        }
    }


    private fun logout(result: Result) {
        client.logout {
            if (it.isSuccess) {
                result.success(true)
            } else {
                result.error("ERROR", "Cannot logout user", "")
            }
        }
    }

    private fun getUserId(result: Result) {
        try {
            val id = client.getUserId()

            if (id == null) {
                result.error("ERROR", "", null)
            } else {
                result.success(id)
            }
        } catch (e: AppException) {
            result.error("ERROR", "", null)
        }
    }

    private fun getUser(result: Result) {

        try {
            val user = client.getUser()
            result.success(user?.toMap())
        } catch (e: AppException) {
            result.error("ERROR", "Cannot get user", "")
        }
    }

    private fun sendResetPasswordEmail(call: MethodCall, result: Result) {
        val email = call.argument<String>("email")

        if (email.isNullOrEmpty()) {
            result.error("ERROR", "must sent to a valid email", null)
        }

        try {
            client.sendResetPasswordEmail(email!!)
            result.success(true)
        } catch (e: AppException) {
            result.error("Error", "Failed to send a reset password email: ${e.message}", null)
        }
    }

    //////////////////////////////////////////////////////////////////////////////
    /**
     *
     */
    private fun insertDocument(call: MethodCall, result: Result) {
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
            if (it.isSuccess) {
                result.success(it.get().insertedId.toJavaValue())
            } else {
                result.error("Error",
                    "Failed to insert a document: ${it.error?.message ?: '?'}",
                    null)
            }
        }
    }

    private fun insertDocuments(call: MethodCall, result: Result) {
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

        task!!.getAsync { it ->
            if (it.isSuccess) {
                val results = emptyMap<Int, String>().toMutableMap()
                val insertedIds = it.get().insertedIds
                insertedIds.forEach {
                    results[it.key.toInt()] = it.value.asObjectId().value.toHexString()
                }

                result.success(results)
            } else
                result.error("Error", "Failed to insert a document ${it.error?.message}", null)

        }
    }

    private fun deleteDocument(call: MethodCall, result: Result) {
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
                result.error("Error",
                    "Failed to delete a document: ${it.error?.message ?: '?'}",
                    "")

        }
    }

    private fun deleteDocuments(call: MethodCall, result: Result) {
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
                result.error("Error",
                    "Failed to insert a document: ${it.error?.message ?: '?'}",
                    "")

        }
    }


    private fun findDocuments(call: MethodCall, result: Result) {
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
                return@getAsync
            }
            if (it.get() != null) {
                it.get().forEach {
                    queryResults.add(it.toJson())
                }
            }
            result.success(queryResults)
        }
    }

    private fun findDocument(call: MethodCall, result: Result) {
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
                result.error("Error",
                    "Failed to insert a document: ${it.error?.message ?: '?'}",
                    "")

        }
    }

    // filter option added
    private fun countDocuments(call: MethodCall, result: Result) {
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
                result.error("Error",
                    "Failed to count the collection: ${it.error?.message ?: '?'}",
                    "")

        }
    }

    //
    private fun updateDocument(call: MethodCall, result: Result) {
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
                result.success(listOf(it.get()?.matchedCount, it.get()?.modifiedCount))
            else
                result.error("Error",
                    "Failed to update the collection: ${it.error?.message ?: '?'}",
                    "")

        }
    }

    private fun updateDocuments(call: MethodCall, result: Result) {
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
                result.success(listOf(it.get()?.matchedCount, it.get()?.modifiedCount))
            else
                result.error("Error",
                    "Failed to update the collection: : ${it.error?.message ?: '?'}",
                    "")

        }
    }


    private fun aggregate(call: MethodCall, result: Result) {
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
                result.error("Error",
                    "Failed to insert a document: ${it.error?.message ?: '?'}",
                    "")

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
    private fun callFunction(call: MethodCall, result: Result) {
        val functionName = call.argument<String>("name")
        val args = call.argument<List<Any>>("args")
        val timeout = call.argument<Int>("timeout")

        if (functionName.isNullOrEmpty()) {
            result.error("Error", "Function name is missing", null)
        }


        try {
            val funcResult = client.callFunction(functionName!!, args, timeout?.toLong())
            result.success(funcResult?.toJavaValue())
        } catch (e: AppException) {
            result.error("Error", "Failed to call function: ${e.message}", "")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
