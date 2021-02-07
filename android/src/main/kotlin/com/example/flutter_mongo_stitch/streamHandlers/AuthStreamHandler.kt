package com.example.flutter_mongo_stitch.streamHandlers

import android.os.Handler
//import com.mongodb.stitch.core.services.mongodb.remote.ChangeEvent

import io.flutter.plugin.common.EventChannel
import org.bson.BsonValue
import org.bson.Document
import android.os.Looper
import com.example.flutter_mongo_stitch.MyMongoStitchClient
import com.example.flutter_mongo_stitch.toMap
import io.realm.mongodb.App
//import com.mongodb.stitch.android.core.StitchAppClient
//import com.mongodb.stitch.android.core.auth.StitchAuth
//import com.mongodb.stitch.android.core.auth.StitchAuthListener
//import com.mongodb.stitch.android.core.auth.StitchUser
import io.realm.mongodb.AuthenticationListener
import io.realm.mongodb.User

class AuthStreamHandler(private val client: MyMongoStitchClient, private val app: App, val arguments: Any?)
    : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    private val listener = object : AuthenticationListener {

//        override fun onActiveUserChanged(auth: StitchAuth?, currentActiveUser: StitchUser?, previousActiveUser: StitchUser?) {
//            //super.onActiveUserChanged(auth, currentActiveUser, previousActiveUser)
//            Handler(Looper.getMainLooper()).post {
//                if (auth?.user == null){
//                    eventSink!!.success(null)
//                }
//                else {
//                    eventSink!!.success(auth.user!!.toMap())
//                }
//            }
//        }
//
//        override fun onAuthEvent(auth: StitchAuth?) {
//            Handler(Looper.getMainLooper()).post {
//                if (auth?.user == null){
//                    eventSink!!.success(null)
//                }
//                else {
//                    eventSink!!.success(auth.user!!.toMap())
//                }
//            }
//        }

        override fun loggedIn(user: User?) {
            Handler(Looper.getMainLooper()).post {
                if (user == null){
                    eventSink!!.success(null)
                }
                else {
                    client.updateClient(user)
                    eventSink!!.success(user.toMap())
                }
            }
        }

        override fun loggedOut(user: User?) {
            Handler(Looper.getMainLooper()).post {
                eventSink!!.success(null)
            }
        }
    }

    override fun onListen(o: Any, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        //runnable.run()

        val args = arguments as Map<*, *>

        this.app.addAuthenticationListener(listener)

        val user = this.app.currentUser()
        if (user == null){
            eventSink.success(null)
        }
        else {
            eventSink.success(user.toMap())
        }

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
        this.app.removeAuthenticationListener(listener)
    }
}
