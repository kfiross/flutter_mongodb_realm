package com.example.flutter_mongo_stitch.realm

import com.google.gson.Gson
import io.realm.RealmModel
import io.realm.RealmObject
import io.realm.annotations.PrimaryKey
import io.realm.annotations.RealmClass

@RealmClass
open class CustomRealmObject() : RealmModel {

    @PrimaryKey var _id:String = ""
    var type: String = ""
    var scheme: String = ""
    var data: String = ""

    constructor(id: String, type: String, scheme: String, data: String) : this() {
        this.type = type
        this.scheme = scheme
        this.data = data
        this._id = id
    }


    val getDataMap: Map<*, *>?
        get() = Gson().fromJson(this.data, Map::class.java)
}

