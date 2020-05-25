package com.example.flutter_mongo_stitch

import android.net.Uri
import android.util.Log
import com.google.android.gms.tasks.Task
import com.mongodb.stitch.android.core.StitchAppClient
import com.mongodb.stitch.android.core.auth.StitchAuth
import com.mongodb.stitch.android.core.auth.StitchUser
import com.mongodb.stitch.core.auth.providers.anonymous.AnonymousCredential
import com.mongodb.stitch.core.auth.providers.userpassword.UserPasswordCredential
import org.bson.BsonDocument
import org.bson.Document
import java.lang.Exception
import kotlin.collections.HashMap
import com.mongodb.stitch.android.core.auth.providers.userpassword.UserPasswordAuthProviderClient
import com.mongodb.stitch.android.services.mongodb.remote.*
import com.mongodb.stitch.core.auth.providers.facebook.FacebookCredential
import com.mongodb.stitch.core.auth.providers.google.GoogleCredential
import com.mongodb.stitch.core.services.mongodb.remote.*
import org.bson.BsonValue


// Basic CRUD..

class MyMongoStitchClient(
    private var client: RemoteMongoClient,
    private var appClient: StitchAppClient
) {
    private var auth: StitchAuth = appClient.auth

    /** ========================== Auth-related function  ========================= **/
//    fun signInWithCustomJWT(jwtString: String): Task<StitchUser>? {
//        return auth.loginWithCredential(CustomCredential(jwtString))
//    }
//

    fun getUser(): StitchUser? {
        return auth.user
    }

//    fun confirmUser() {
//        //var uri = Intent.getIntent().getData();
//
//        val token = uri.getQueryParameter("token");
//        val tokenId = uri.getQueryParameter("tokenId");
//
//        val emailPassClient = auth.getProviderClient(UserPasswordAuthProviderClient.factory)
//
//        emailPassClient.confirmUser(token, tokenId)
//                .addOnCompleteListener {
//                    if (it.isSuccessful) {
//                        Log.d("stitch", "Successfully reset user's password");
//                    } else {
//                        Log.e("stitch", "Error resetting user's password:", task.getException());
//                    }
//
//                }
//    }

    fun sendResetPasswordEmail(email: String): Task<Void>? {
        val emailPassClient = auth.getProviderClient(UserPasswordAuthProviderClient.factory)
        return emailPassClient.sendResetPasswordEmail(email)
    }


    fun getUserId(): String?{
        return auth.user?.id
    }

    fun isUserLoggedIn(): Boolean{
        return auth.user?.isLoggedIn ?: false
    }

    fun signInAnonymously(): Task<StitchUser>
            = auth.loginWithCredential(AnonymousCredential())

    fun signInWithUsernamePassword(username: String, password: String ): Task<StitchUser> {
        return auth.loginWithCredential(UserPasswordCredential(username, password))
    }

    fun signInWithGoogle(authCode: String): Task<StitchUser> {
        return auth.loginWithCredential(GoogleCredential(authCode))
    }

    fun signInWithFacebook(accessToken: String): Task<StitchUser> {
        return auth.loginWithCredential(FacebookCredential(accessToken))
    }

    fun logout(): Task<Void> = auth.logout()

    fun registerWithEmail(email: String, password: String): Task<Void>? {
        val emailPassClient = auth.getProviderClient(
                UserPasswordAuthProviderClient.factory
        )
        return emailPassClient.registerWithEmail(email, password)
    }


    /** ========================== Database-related function  ========================= **/
    private fun getCollection(databaseName: String?, collectionName: String?): RemoteMongoCollection<Document>? {
        if(databaseName == null || collectionName == null)
            throw Exception()

        return client.getDatabase(databaseName).getCollection(collectionName)
    }

    fun insertDocument(databaseName: String?, collectionName: String?, data: HashMap<String, Any>?)
            : Task<RemoteInsertOneResult>? {
        val collection = getCollection(databaseName, collectionName)


        
        //Document.parse(json)
        val document = Document()

        if(data == null)
            return null

        for (item in data.entries){
            document[item.key] = item.value
        }

        return collection?.insertOne(document)
    }

    fun insertDocuments(databaseName: String?, collectionName: String?, list: List<String>?)
            : Task<RemoteInsertManyResult>? {
        val collection = getCollection(databaseName, collectionName)

        if (list == null)
          return null

        val documents = list.map {
            Document.parse(it)
        }

        return collection?.insertMany(documents)
    }


    fun deleteDocument(databaseName: String?, collectionName: String?, filterJson: String?)
            : Task<RemoteDeleteResult>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.deleteOne(BsonDocument())

        val filter = BsonDocument.parse(filterJson)
        return collection?.deleteOne(filter)
    }

    // TODO:  check this implementation
    fun deleteDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : Task<RemoteDeleteResult>? {
        val collection = getCollection(databaseName, collectionName)
        
        if (filterJson == null)
            return collection?.deleteMany(BsonDocument())

        val filter = BsonDocument.parse(filterJson)
        return collection?.deleteMany(filter)
    }

    /*******************************************************************************/

    fun findDocuments(
            databaseName: String?,
            collectionName: String?,
            filterJson: String?,
            projectionJson: String?,
            limit: Int?,
            sortJson: String?
    ): RemoteFindIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)


        var filter = BsonDocument()
        var projectionBson = BsonDocument()
        var sortBson:BsonDocument? = null

        if (filterJson != null)
            filter = BsonDocument.parse(filterJson)

        if (projectionJson != null)
            projectionBson = BsonDocument.parse(projectionJson)

        if (sortJson != null)
            sortBson = BsonDocument.parse(sortJson)

        val result = collection?.find(filter)?.projection(projectionBson)

        //  add optional limit
        if (limit != null){
            result?.limit(limit)
        }

        // add optional sort
        if (sortBson != null){
            result?.sort(sortBson)
        }

        return result
    }



    fun findDocument(databaseName: String?, collectionName: String?, filterJson: String?, projectionJson: String?)
            : Task<Document>? {
        val collection = getCollection(databaseName, collectionName)


//        if (filterJson == null)
//            return collection?.findOne()
//
//        val filter = BsonDocument.parse(filterJson)
//
//        return collection?.findOne(filter)

        var filter = BsonDocument()
        val options = RemoteFindOptions()

        if (filterJson != null)
            filter = BsonDocument.parse(filterJson)

        if (projectionJson != null)
            options.projection(BsonDocument.parse(projectionJson))

        return collection?.findOne(filter, options)
    }


    fun countDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : Task<Long>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.count()
        
        val filter = BsonDocument.parse(filterJson)
        return collection?.count(filter)
    }

    fun updateDocument(databaseName: String?, collectionName: String?, filterJson: String?, updateJson: String)
            : Task<RemoteUpdateResult>? {
        val collection = getCollection(databaseName, collectionName)

        val update = BsonDocument.parse(updateJson)
        if (filterJson == null)
            return collection?.updateOne(BsonDocument(), update)

        val filter = BsonDocument.parse(filterJson)
        return collection?.updateOne(filter, update)
    }

    fun updateDocuments(databaseName: String?, collectionName: String?, filterJson: String?, updateJson: String)
            : Task<RemoteUpdateResult>? {
        val collection = getCollection(databaseName, collectionName)

        val update = BsonDocument.parse(updateJson)
        if (filterJson == null)
            return collection?.updateMany(BsonDocument(), update)


        val filter = BsonDocument.parse(filterJson)
        return collection?.updateMany(filter, update)
    }

    //?
    fun watchCollection(
        databaseName: String?, collectionName: String?, filterJson: String?
    ): Task<AsyncChangeStream<Document, ChangeEvent<Document>>>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.watch()


        val matchFilter = BsonDocument.parse(filterJson)
        return collection?.watchWithFilter(matchFilter)
    }


    fun aggregate(databaseName: String?, collectionName: String?, pipelineStrings: List<String>?): RemoteAggregateIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)

        val pipeline = pipelineStrings?.map {
            BsonDocument.parse(it)
        }

        return collection?.aggregate(pipeline)
    }

    fun callFunction(name: String, args: List<Any>?, requestTimeout: Long?)
            : Task<BsonValue>? {

        return appClient.callFunction(
                name,
                args ?: emptyList<Any>(),
                requestTimeout ?: 15*1000,
                BsonValue::class.java
        )
    }




}