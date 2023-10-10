package com.example.flutter_mongo_stitch

import io.realm.mongodb.Credentials
import io.realm.mongodb.User
import org.bson.BsonType
import org.bson.BsonValue

fun BsonValue.toJavaValue(): Any {
    return when (this.bsonType) {
//        BsonType.END_OF_DOCUMENT -> null
        BsonType.DOUBLE -> this.asDouble().value
        BsonType.STRING -> this.asString().value
        BsonType.DOCUMENT -> this.asDocument().toJson()
        BsonType.ARRAY -> this.asArray().toArray()
        BsonType.BINARY -> this.asBinary()
//        BsonType.UNDEFINED -> null
        BsonType.OBJECT_ID -> this.asObjectId().value.toHexString()
        BsonType.BOOLEAN -> this.asBoolean().value
        BsonType.DATE_TIME -> this.asDateTime().value
//        BsonType.NULL -> null
//        BsonType.REGULAR_EXPRESSION -> TODO()
//        BsonType.DB_POINTER -> TODO()
//        BsonType.JAVASCRIPT -> TODO()
//        BsonType.SYMBOL -> TODO()
//        BsonType.JAVASCRIPT_WITH_SCOPE -> TODO()
        BsonType.INT32 -> this.asInt32().value
        BsonType.TIMESTAMP -> TODO()
        BsonType.INT64 -> this.asInt64().value
        BsonType.DECIMAL128 -> this.asDecimal128().value
//        BsonType.MIN_KEY -> this.as
//        BsonType.MAX_KEY -> TODO()

        else -> this.asString().value //??
    }
}

fun User.toMap(): Map<String, Any> {
    return mapOf(
            "id" to id,
            "device_id" to deviceId,
            "profile" to mapOf(
                    "name" to profile?.name,
                    "email" to profile?.email,
                    "pictureUrl" to profile?.pictureUrl,
                    "firstName" to profile?.firstName,
                    "lastName" to profile?.lastName,
                    "gender" to profile?.gender,
                    "birthday" to profile?.birthday,
                    "minAge" to profile?.minAge,
                    "maxAge" to profile?.maxAge
            )
    )
}

object CredentialsExtensions{
    fun fromMap(json: Map<String, Any>): Credentials?{
        return when(json["type"]){
            "anon" -> throw Exception("can't link anonymous")
            "email_password" -> Credentials.emailPassword(json["email"] as String, json["password"] as String)
            "apple" -> Credentials.apple(json["idToken"] as String)
            "facebook" -> Credentials.facebook(json["accessToken"] as String)
            //"google" -> Credentials.google(json["authorizationCode"] as String)
            "jwt" -> Credentials.jwt(json["jwtToken"] as String)
            else -> null
        }
    }
}
