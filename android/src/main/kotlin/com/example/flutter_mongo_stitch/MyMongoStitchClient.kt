package com.example.flutter_mongo_stitch


//import com.mongodb.stitch.android.core.StitchAppClient
//import com.mongodb.stitch.android.core.auth.StitchAuth
//import com.mongodb.stitch.android.core.auth.StitchUser
//import com.mongodb.stitch.core.auth.providers.anonymous.AnonymousCredential
//import com.mongodb.stitch.core.auth.providers.userpassword.UserPasswordCredential
import java.lang.Exception
import kotlin.collections.HashMap
//import com.mongodb.stitch.android.core.auth.providers.userpassword.UserPasswordAuthProviderClient
//import com.mongodb.stitch.android.services.mongodb.remote.*
//import com.mongodb.stitch.core.auth.providers.facebook.FacebookCredential
//import com.mongodb.stitch.core.auth.providers.google.GoogleCredential
//import com.mongodb.stitch.core.services.mongodb.remote.*
import io.realm.RealmAsyncTask
import io.realm.mongodb.*
import io.realm.mongodb.auth.GoogleAuthType
import io.realm.mongodb.functions.Functions
import org.bson.*
import org.bson.types.ObjectId

import io.realm.mongodb.mongo.MongoClient
import io.realm.mongodb.mongo.MongoCollection
import io.realm.mongodb.mongo.iterable.AggregateIterable
import io.realm.mongodb.mongo.iterable.FindIterable
import io.realm.mongodb.mongo.options.FindOptions
import io.realm.mongodb.mongo.options.InsertManyResult
import io.realm.mongodb.mongo.result.DeleteResult
import io.realm.mongodb.mongo.result.InsertOneResult
import io.realm.mongodb.mongo.result.UpdateResult

// Basic CRUD..

class MyMongoStitchClient(
        private var client: MongoClient?,
        private var app: App
) {
 //   private var auth: StitchAuth = app.currentUser()

    /** ========================== Auth-related function  ========================= **/

    fun getUser(): User? {
        return app.currentUser();
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

    fun sendResetPasswordEmail(email: String) {

//        val emailPassClient = auth.getProviderClient(UserPasswordAuthProviderClient.factory)
        return app.emailPassword.sendResetPasswordEmail(email);
    }


    fun getUserId(): String?{
        return app.currentUser()?.id
    }

    fun isUserLoggedIn(): Boolean{
        return app.currentUser()?.isLoggedIn ?: false
    }


    fun signInAnonymously(callback: App.Callback<User>): RealmAsyncTask?
            = app.loginAsync(Credentials.anonymous(), callback)

    fun signInWithUsernamePassword(username: String, password: String, callback: App.Callback<User>)
                : RealmAsyncTask? {
        return app.loginAsync(Credentials.emailPassword(username, password), callback)
    }

    fun signInWithGoogle(idToken: String, callback: App.Callback<User>): RealmAsyncTask? {
        return app.loginAsync(Credentials.google(idToken ,GoogleAuthType.ID_TOKEN), callback)
    }

    fun signInWithFacebook(accessToken: String, callback: App.Callback<User>): RealmAsyncTask? {
        return app.loginAsync(Credentials.facebook(accessToken), callback)
    }

    fun signInWithCustomJwt(jwtToken: String, callback: App.Callback<User>): RealmAsyncTask? {
        return app.loginAsync(Credentials.jwt(jwtToken), callback)
    }

    fun signInWithCustomAuthFunction(json: String, callback: App.Callback<User>): RealmAsyncTask? {
        val args = Document.parse(json)

        return app.loginAsync(Credentials.customFunction(args), callback)
    }

    fun signInWithApple(idToken: String, callback: App.Callback<User>) : RealmAsyncTask? {
        return app.loginAsync(Credentials.apple(idToken), callback);
    }

    fun logout(callback: App.Callback<User>): RealmAsyncTask?
            = app.currentUser()?.logOutAsync(callback);

    fun registerWithEmail(email: String, password: String, callback: App.Callback<Void>)
                : RealmAsyncTask? {
//        val emailPassClient = auth.getProviderClient(
//                UserPasswordAuthProviderClient.factory
//        )
//        return emailPassClient.registerWithEmail(email, password)
        return app.emailPassword.registerUserAsync(email, password, callback);
    }


    /** ========================== Database-related function  ========================= **/
    private fun getCollection(databaseName: String?, collectionName: String?): MongoCollection<Document>? {
        if(databaseName == null || collectionName == null)
            throw Exception()

        return client?.getDatabase(databaseName)?.getCollection(collectionName)
    }

    fun insertDocument(databaseName: String?, collectionName: String?, data: HashMap<String, Any>?)
            : RealmResultTask<InsertOneResult>? {
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
            : RealmResultTask<InsertManyResult>? {
        val collection = getCollection(databaseName, collectionName)

        if (list == null)
          return null

        val documents = list.map {
            Document.parse(it)
        }

        return collection?.insertMany(documents);
    }


    fun deleteDocument(databaseName: String?, collectionName: String?, filterJson: String?)
            : RealmResultTask<DeleteResult>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.deleteOne(BsonDocument())

        val filter = BsonDocument.parse(filterJson)
        return collection?.deleteOne(filter)
    }

    // TODO:  check this implementation
    fun deleteDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : RealmResultTask<DeleteResult>? {
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
    ): FindIterable<Document>? {
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
            : RealmResultTask<Document>? {
        val collection = getCollection(databaseName, collectionName)


//        if (filterJson == null)
//            return collection?.findOne()
//
//        val filter = BsonDocument.parse(filterJson)
//
//        return collection?.findOne(filter)

        var filter = BsonDocument()
        val options = FindOptions()

        if (filterJson != null)
            filter = BsonDocument.parse(filterJson)

        if (projectionJson != null)
            options.projection(BsonDocument.parse(projectionJson))

        return collection?.findOne(filter, options)
    }


    fun countDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : RealmResultTask<Long>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.count()
        
        val filter = BsonDocument.parse(filterJson)
        return collection?.count(filter)
    }

    fun updateDocument(databaseName: String?, collectionName: String?, filterJson: String?, updateJson: String)
            : RealmResultTask<UpdateResult>? {
        val collection = getCollection(databaseName, collectionName)

        val update = BsonDocument.parse(updateJson)
        if (filterJson == null)
            return collection?.updateOne(BsonDocument(), update)

        val filter = BsonDocument.parse(filterJson)
        return collection?.updateOne(filter, update)
    }

    fun updateDocuments(databaseName: String?, collectionName: String?, filterJson: String?, updateJson: String)
            : RealmResultTask<UpdateResult>? {
        val collection = getCollection(databaseName, collectionName)

        val update = BsonDocument.parse(updateJson)
        if (filterJson == null)
            return collection?.updateMany(BsonDocument(), update)


        val filter = BsonDocument.parse(filterJson)
        return collection?.updateMany(filter, update)
    }

    //?
    fun watchCollection(
            databaseName: String?, collectionName: String?, filterJson: String?, ids: List<String>?, asObjectIds: Boolean
    ): RealmEventStreamAsyncTask<Document>? {
        val collection = getCollection(databaseName, collectionName)


        if (filterJson == null) {
            if (ids == null) {
                return collection?.watchAsync()
            }

            return if(asObjectIds) {
                val idsVars = ids.map { ObjectId(it) }.toTypedArray()
                collection?.watchAsync(*idsVars)
            } else {
                val idsVars = ids.map { BsonString(it) }.toTypedArray()
                collection?.watchAsync(*idsVars)
            }
        }

        val matchFilter = BsonDocument.parse(filterJson)
        return collection?.watchWithFilterAsync(matchFilter)
    }


    fun aggregate(databaseName: String?, collectionName: String?, pipelineStrings: List<String>?)
                : AggregateIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)

        val pipeline = pipelineStrings?.map {
            BsonDocument.parse(it)
        }

        return collection?.aggregate(pipeline)
    }

    fun callFunction(name: String, args: List<Any>?, requestTimeout: Long?)
            : BsonValue? {

        val functionsManager: Functions = app.getFunctions(app.currentUser())

        return functionsManager.callFunction(
                name,
                args ?: emptyList<Any>(),
//                requestTimeout ?: 15*1000,
                BsonValue::class.java
        )
    }

    fun updateClient(user: User?) {
        if(user != null){
            this.client = user.getMongoClient("mongodb-atlas")
        }
    }


}