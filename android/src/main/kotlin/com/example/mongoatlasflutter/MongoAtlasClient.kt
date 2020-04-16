package com.example.mongoatlasflutter

import com.google.android.gms.tasks.Task
import com.mongodb.client.MongoCollection
import com.mongodb.stitch.android.services.mongodb.remote.RemoteFindIterable
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoClient
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoCollection
import com.mongodb.stitch.android.services.mongodb.remote.RemoteMongoDatabase
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
    private var client: RemoteMongoClient
) {


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
    fun deleteDocument(databaseName: String?, collectionName: String?)
            : Task<RemoteDeleteResult>? {
        val collection = getCollection(databaseName, collectionName)

        var filter = BsonDocument()
        return collection?.deleteOne(filter)
    }

    // TODO:  check this implementation
    fun deleteDocuments(databaseName: String?, collectionName: String?)
            : Task<RemoteDeleteResult>? {
        val collection = getCollection(databaseName, collectionName)

        var filter = BsonDocument()
        return collection?.deleteMany(filter)
    }



    fun findDocuments(databaseName: String?, collectionName: String?)
            : RemoteFindIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)

        var filter = BsonDocument()
        return collection?.find(filter)
    }


    // TODO:  check this implementation
    fun findDocument(databaseName: String?, collectionName: String?): Task<Document>? {
        val collection = getCollection(databaseName, collectionName)

        var filter = BsonDocument()
        return collection?.findOne(filter)
    }

    // TODO:  check this implementation
    fun countDocuments(databaseName: String?, collectionName: String?): Task<Long>? {
        val collection = getCollection(databaseName, collectionName)

        return collection?.count()
    }

}