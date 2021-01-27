package com.example.flutter_mongo_stitch

//import com.mongodb.stitch.android.core.auth.StitchUser
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

//fun StitchUser.toMap(): Map<String, Any> {
//    return mapOf(
//            "id" to id,
//            "device_id" to deviceId,
//            "profile" to mapOf(
//                    "name" to profile?.name,
//                    "email" to profile?.email,
//                    "pictureUrl" to profile?.pictureUrl,
//                    "firstName" to profile?.firstName,
//                    "lastName" to profile?.lastName,
//                    "gender" to profile?.gender,
//                    "birthday" to profile?.birthday,
//                    "minAge" to profile?.minAge,
//                    "maxAge" to profile?.maxAge
//            )
//    )
//}

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