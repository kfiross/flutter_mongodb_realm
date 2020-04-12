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

    // TODO:  chek this implementaion
    fun deleteDocument(databaseName: String?, collectionName: String?)
            : Task<RemoteDeleteResult>? {
        val collection = getCollection(databaseName, collectionName)

        return collection?.deleteOne(null)
    }


    // TODO:  check this implementaion
    fun findDocuments(databaseName: String?, collectionName: String?)
            : RemoteFindIterable<Document>? {
        val collection = getCollection(databaseName, collectionName)

        return collection?.find(null)
    }


    // TODO:  chek this implementaion
    fun findDocument(databaseName: String?, collectionName: String?): Task<Document>? {
        val collection = getCollection(databaseName, collectionName)

        return collection?.findOne(null)
    }
}