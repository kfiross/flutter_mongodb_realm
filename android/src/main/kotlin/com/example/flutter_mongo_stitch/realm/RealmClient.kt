package com.example.flutter_mongo_stitch.realm

import com.example.flutter_mongo_stitch.deleteAllTyped
import com.example.flutter_mongo_stitch.deleteFirstTyped
import com.example.flutter_mongo_stitch.whereTyped
import com.google.gson.Gson
import io.flutter.plugin.common.MethodChannel
import io.realm.Realm
import io.realm.RealmResults
import io.realm.mongodb.App
import io.realm.mongodb.sync.SyncConfiguration
import java.lang.Exception

class RealmClient(
        private var app: App
) {
    private fun getRealm(partitionValue: String): Realm {
        val config = SyncConfiguration.Builder(app.currentUser(), partitionValue)
                .allowQueriesOnUiThread(true)
                .allowWritesOnUiThread(true) //??????
                .build()

        return Realm.getInstance(config);
    }

    @Suppress("unchecked_cast")
    fun insertOne(
            partitionValue: String,
            typeName: String,
            jsonData: String,
            upsert :Boolean,
            jsonScheme: String?,
            result: MethodChannel.Result)
    {

        val mapData = Gson().fromJson(jsonData, Map::class.java)
        val backgroundThreadRealm = getRealm(partitionValue);
        val customRealmObject = CustomRealmObject(mapData["_id"] as String, typeName, "{}", jsonData)

        backgroundThreadRealm.executeTransaction {
//            it.createObjectFromJson(myObject::class.java, "{'name': 'kfir'}")
            try {
                if(upsert) {
                    it.insertOrUpdate(customRealmObject)
                }
                else {
                    it.insert(customRealmObject)
                }
                result.success(true)
                return@executeTransaction
            }
            catch (e: Exception){
                result.error("Error", e.message, "null")
            }
        }
    }

    @Suppress("unchecked_cast")
    fun insert(
            partitionValue: String,
            typeName: String,
            jsonListData: String,
            upsert :Boolean,
            jsonScheme: String?,
            result: MethodChannel.Result)
    {

        val mapListData = Gson().fromJson(jsonListData, List::class.java) as List<Map<*, *>>
        val backgroundThreadRealm = getRealm(partitionValue);

        val customRealmObjectList = emptyList<CustomRealmObject>().toMutableList()

        for (mapData in mapListData){
            val jsonData = Gson().toJson(mapData);
            val customRealmObject =
                    CustomRealmObject(mapData["_id"] as String, typeName, "{}", jsonData)
            customRealmObjectList.add(customRealmObject)
        }

        backgroundThreadRealm.executeTransaction {
//            it.createObjectFromJson(myObject::class.java, "{'name': 'kfir'}")
            try {
                if(upsert) {
                    it.insertOrUpdate(customRealmObjectList)
                }
                else {
                    it.insert(customRealmObjectList)
                }
                result.success(true)
                return@executeTransaction
            }
            catch (e: Exception){
                result.error("Error", e.message, "null")
            }
        }
    }

    fun delete(partitionValue: String, typeName: String, actionType: Boolean, result: MethodChannel.Result){
        val backgroundThreadRealm = getRealm(partitionValue);

        backgroundThreadRealm.executeTransaction {
            try {
                if (actionType) {
                    it.deleteAllTyped(typeName)
                } else {
                    it.deleteFirstTyped(typeName)
                }
                result.success(true)
            }
            catch (e: Exception){
                result.error("Error", e.message, "null")
            }
        }

    }

    fun findFirst(partitionValue: String, typeName: String) : String{
        val backgroundThreadRealm = getRealm(partitionValue);

        val realmQuery = backgroundThreadRealm.whereTyped(typeName)
        val `object` = realmQuery.findFirst();

        return Gson().toJson(`object`)
    }

    fun findAll(partitionValue: String, typeName: String) : String{
        val backgroundThreadRealm = getRealm(partitionValue);

        val realmQuery = backgroundThreadRealm.whereTyped(typeName)
        val  objects : RealmResults<CustomRealmObject> = realmQuery.findAll();

        return objects.asJSON()
    }
}