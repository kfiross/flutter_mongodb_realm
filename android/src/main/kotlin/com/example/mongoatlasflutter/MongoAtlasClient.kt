package com.example.mongoatlasflutter

import com.google.android.gms.tasks.Task
import com.mongodb.client.MongoCollection
import com.mongodb.stitch.android.core.auth.StitchAuth
import com.mongodb.stitch.android.core.auth.StitchUser
import com.mongodb.stitch.android.services.mongodb.remote.RemoteFindIterable
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoCollection
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoDatabase
import com.mongodb.stitch.core.auth.providers.anonymous.AnonymousCredential
import com.mongodb.stitch.core.auth.providers.custom.CustomCredential
import com.mongodb.stitch.core.auth.providers.userpassword.UserPasswordCredential
import com.mongodb.stitch.core.services.mongodb.remote.RemoteDeleteResult
import com.mongodb.stitch.core.services.mongodb.remote.RemoteInsertOneResult
import io.flutter.plugin.common.StandardMessageCodec
import org.bson.BsonDocument
import org.bson.Document
import org.bson.conversions.Bson
import java.lang.Exception
import java.util.*
import kotlin.collections.HashMap



// Basic CRUD..

class MongoAtlasClient(
    private var client: RemoteMongoClient,
    private var auth: StitchAuth
) {


    /** ========================== Auth-related function  ========================= **/
    fun signInWithCustomJWT(jwtString: String): Task<StitchUser>? {
        return auth.loginWithCredential(CustomCredential(jwtString))
    }

    fun signInWithEmailPassword(username: String, password: String ): Task<StitchUser>? {
        return auth.loginWithCredential(UserPasswordCredential(username, password))
    }

    fun signInAnonymously(): Task<StitchUser>?
            = auth.loginWithCredential(AnonymousCredential())

    fun logout(): Task<Void> = auth.logout()

    fun isUserLoggedIn(): Boolean{
        return auth.user?.isLoggedIn ?: false
    }

    fun getUserId(): String?{
        return auth.user?.id
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

//    fun insertDocuments(databaseName: String?, collectionName: String?, data: HashMap<String, Any>?)
//            : Task<RemoteInsertOneResult>? {
//        val collection = getCollection(databaseName, collectionName)
//
//        //Document.parse(json)
//        val document = Document()
//
//        if(data == null)
//            return null
//
//        for (item in data.entries){
//            document[item.key] = item.value
//        }
//
//        return collection?.insertOne(document)
//    }

    // TODO:  check this implementation
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

    fun findDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : RemoteFindIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.find()

        val filter = BsonDocument.parse(filterJson)
        return collection?.find(filter)
    }



    fun findDocument(databaseName: String?, collectionName: String?, filterJson: String?)
            : Task<Document>? {
        val collection = getCollection(databaseName, collectionName)
        
        if (filterJson == null)
            return collection?.findOne()

        val filter = BsonDocument.parse(filterJson)
        return collection?.findOne(filter)
    }


    fun countDocuments(databaseName: String?, collectionName: String?, filterJson: String?)
            : Task<Long>? {
        val collection = getCollection(databaseName, collectionName)

        if (filterJson == null)
            return collection?.count()
        
        val filter = BsonDocument.parse(filterJson)
        return collection?.count(filter)
    }

}