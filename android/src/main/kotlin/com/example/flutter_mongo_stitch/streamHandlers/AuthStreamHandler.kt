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

class AuthStreamHandler(private val appClient: StitchAppClient, val arguments: Any?)
    : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    private val listener = object : StitchAuthListener {
        override fun onActiveUserChanged(auth: StitchAuth?, currentActiveUser: StitchUser?, previousActiveUser: StitchUser?) {
            //super.onActiveUserChanged(auth, currentActiveUser, previousActiveUser)
            Handler(Looper.getMainLooper()).post {
                if (auth?.user == null){
                    eventSink!!.success(null)
                }
                else {
                    eventSink!!.success(auth.user!!.toMap())
                }
            }
        }

        override fun onAuthEvent(auth: StitchAuth?) {
            Handler(Looper.getMainLooper()).post {
                if (auth?.user == null){
                    eventSink!!.success(null)
                }
                else {
                    eventSink!!.success(auth.user!!.toMap())
                }
            }
        }
    }

    override fun onListen(o: Any, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        //runnable.run()

        val args = arguments as Map<*, *>

        this.appClient.auth.addAuthListener(listener)

//        task?.addOnCompleteListener{
//            val changeStream = it.result
//            changeStream?.addChangeEventListener { documentId: BsonValue, event: ChangeEvent<Document> ->
//                // handle change event
//
//                Handler(Looper.getMainLooper()).post {
//                    eventSink.success(event.fullDocument?.toJson())
//
//                }
//
//            }
//        }
    }

    override fun onCancel(o: Any) {
        this.appClient.auth.removeAuthListener(listener)
    }
}
