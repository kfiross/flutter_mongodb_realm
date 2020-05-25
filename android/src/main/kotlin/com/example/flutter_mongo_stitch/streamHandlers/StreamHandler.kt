package com.example.flutter_mongo_stitch.streamHandlers

import android.os.Handler
import com.mongodb.stitch.core.services.mongodb.remote.ChangeEvent

import io.flutter.plugin.common.EventChannel
import org.bson.BsonValue
import org.bson.Document
import android.os.Looper
import com.example.flutter_mongo_stitch.MyMongoStitchClient
import com.example.flutter_mongo_stitch.toMap
import com.mongodb.stitch.android.core.StitchAppClient
import com.mongodb.stitch.android.core.auth.StitchAuth
import com.mongodb.stitch.android.core.auth.StitchAuthListener
import com.mongodb.stitch.android.core.auth.StitchUser


class StreamHandler(val client: MyMongoStitchClient, val arguments: Any?)
    : EventChannel.StreamHandler {

    private lateinit var handler: Handler
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(o: Any, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        //runnable.run()

        val args = arguments as Map<*, *>
        val dbName = args["db"] as String?
        val collectionName = args["collection"] as String?
        val filter = args["filter"] as String?

        val task = this.client.watchCollection(dbName,collectionName, filter)

        task?.addOnCompleteListener{
            val changeStream = it.result
            changeStream?.addChangeEventListener { documentId: BsonValue, event: ChangeEvent<Document> ->
                // handle change event

                handler = Handler(Looper.getMainLooper())
                handler.post {
//                  eventSink.success(mapOf(
//                      "id" to event.fullDocument?.get("_id"),
//                      "fullDocumentJson" to event.fullDocument?.toJson()
//                  ))
                    eventSink.success(event.fullDocument?.toJson())

                }

            }
        }
    }

    override fun onCancel(o: Any) {
        handler.removeCallbacks {  }
    }
}
