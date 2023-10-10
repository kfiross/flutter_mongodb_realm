"use strict";

var mongoClient;
var stitchAppClient;
var realmApp;

function uint8ArrayToHex(uint8Array) {
    return Array.prototype.map.call(new Uint8Array(uint8Array.buffer), x => ('00' + x.toString(16)).slice(-2)).join('');
}

function getCredFromJson(json){
    throw Exception("not implemented!!")
//    switch(json["type"]){
//        case "anon":
//            throw Exception("can't link anonymous")
//        case "email_password":
//            throw Exception("can't link anonymous")
//            // return Realm.Credentials.emailPassword(json["email"] as String, json["password"] as String)
//        case "apple":
//            return Realm.Credentials.apple(json["idToken"] as String)
//        case "facebook":
//            return Realm.Credentials.facebook(json["accessToken"] as String)
////        case "google":
////            return Credentials.google(json["authorizationCode"] as String)
//        case "jwt" :
//            return Realm.Credentials.jwt(json["jwtToken"] as String)
//    }
}

function Mongo() {
    Mongo.prototype.connectMongo  = function(appId) {
        stitchAppClient = stitch.Stitch.initializeDefaultAppClient(appId);

        mongoClient = stitchAppClient.getServiceClient(
            stitch.RemoteMongoClient.factory,
            "mongodb-atlas"
        );

        this.sendAuthListenerEvent(null);

        // Realm
        realmApp = new Realm.App({ id: appId });
    }

    /// -----------------------------------------------------
    Mongo.prototype.getCollection = function(databaseName, collectionName){
       return mongoClient.db(databaseName).collection(collectionName)
    }


    Mongo.prototype.insertDocument = async function(databaseName, collectionName, docString){
        var collection = this.getCollection(databaseName, collectionName);
        var doc = JSON.parse(docString);

        var doc = await collection.insertOne(doc);
        var id = uint8ArrayToHex(doc['insertedId']['id']);
        console.log(id);
        return new Promise((resolve, reject) => {
            resolve(id);
        });
    };


    Mongo.prototype.insertDocuments = async function(databaseName, collectionName, list){
        var collection = this.getCollection(databaseName, collectionName)

        var docs = [];
        list.forEach((str) => {
            docs.push(JSON.parse(str))
        });

        var result = await collection.insertMany(docs);
        var ids = result['insertedIds'];
        console.log(ids);

        var map = {};
        var keys = Object.keys(ids);

        for(var i=0; i<keys.length; i++){
            map[`${keys[i]}`] = uint8ArrayToHex(ids[keys[i]]['id'])
        }

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(map));
        });
    };

    Mongo.prototype.findDocument = async function (databaseName, collectionName, filter) {
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter);

        var doc = await collection.findOne(query, {})

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(doc));
        });
    }

    Mongo.prototype.findDocuments = async function (databaseName, collectionName, filter) {
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter);

        var results = await collection.find(query, {}).toArray()

        var strings = [];
        results.forEach((doc) => {

            let docId = doc['_id']
            if (typeof docId === 'object' || docId instanceof Object){
                doc['_id'] = {
                    '$oid': `${docId}`
                }
            }
            strings.push(JSON.stringify(doc))
        })

        return new Promise((resolve, reject) => {
            resolve(strings);
        });
    }

    Mongo.prototype.deleteDocument = async function(databaseName, collectionName, filter){
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter)

        var result = await collection.deleteOne(query)

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(result));
        });
    }

    Mongo.prototype.deleteDocuments = async function(databaseName, collectionName, filter){
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter)

        var result = await collection.deleteMany(query)

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(result));
        });
    }

    Mongo.prototype.countDocuments = async function(databaseName, collectionName, filter){
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter)

        var docsCount = await collection.count(query);

        return new Promise((resolve, reject) => {
            resolve(docsCount);
        });
    }


    Mongo.prototype.updateDocument = async function(databaseName, collectionName, filter, update){
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter)
        var update = JSON.parse(update)
        var options = {}

        var results = await collection.updateOne(query, update, options);

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(results));
        });
    }


    Mongo.prototype.updateDocuments = async function(databaseName, collectionName, filter, update){
        var collection = this.getCollection(databaseName, collectionName)
        var query = JSON.parse(filter)
        var update = JSON.parse(update)
        var options = {}

        var results = await collection.updateMany(query, update, options);

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(results));
        });
    }

    // -------------------------------------------------------
    Mongo.prototype.loginAnonymously  = async function(){
        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.AnonymousCredential())

        var userObject = {
            "id": user.id
        }

        this.sendAuthListenerEvent(userObject);

        await realmApp.logIn(Realm.Credentials.anonymous())

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify({"id": user.id}));
        });
    }


    Mongo.prototype.signInWithUsernamePassword  = async function(username, password){
        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.UserPasswordCredential(username, password))

         var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
         }

         this.sendAuthListenerEvent(userObject);

         await realmApp.logIn(Realm.Credentials.emailPassword(username, password));

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    }

    Mongo.prototype.signInWithGoogle = async function(authCode){
        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.GoogleCredential(authCode))

        var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
        }

        this.sendAuthListenerEvent(userObject);

        await realmApp.logIn(Realm.Credentials.google(authCode));

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    }

    Mongo.prototype.signInWithFacebook = async function(token){
        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.FacebookCredential(token))

        var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
        }

        this.sendAuthListenerEvent(userObject);

        await realmApp.logIn(Realm.Credentials.facebook(token));

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    }

    Mongo.prototype.signInWithCustomJwt = async function(jwtString){
        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.CustomCredential(jwtString));

        var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
        };

        this.sendAuthListenerEvent(userObject);

        await realmApp.logIn(Realm.Credentials.jwt(jwtString));

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    };

    Mongo.prototype.signInWithCustomFunction = async function(jsonData){
        var json = JSON.parse(jsonData);

        var user = await stitchAppClient.auth.loginWithCredential(
            new stitch.FunctionCredential(json));

        var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
        };

        this.sendAuthListenerEvent(userObject);

        await realmApp.emailPassword.function(json)

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    };

    Mongo.prototype.registerWithEmail  = async function(email, password){
        var emailPassClient = stitch.Stitch.defaultAppClient.auth
            .getProviderClient(stitch.UserPasswordAuthProviderClient.factory);


        await emailPassClient.registerWithEmail(email, password);

        console.log('DONE!');
    };

    Mongo.prototype.linkCredentials = async function(jsonData){
         var json = JSON.parse(jsonData);
        const realmUserCredentials = getCredFromJson(json)
        await realmApp.currentUser.linkCredentials(realmUserCredentials);
        return user;
    }

    Mongo.prototype.logout  = async function(){
        await stitchAppClient.auth.logout();
        await realmApp.logOut()
        this.sendAuthListenerEvent(null);
        console.log('logged out')
    };

     Mongo.prototype.getUserId = async function(){
         var user = await stitchAppClient.auth.user;

         return new Promise((resolve, reject) => {
            resolve(user.id);
         });
     };

     Mongo.prototype.getAccessToken = async function(){
         var token = realmApp.currentUser.accessToken

         return new Promise((resolve, reject) => {
             resolve(token);
         });
     };



     Mongo.prototype.getRefreshToken = async function(){
       var token = await realmApp.currentUser.refreshToken;

       return new Promise((resolve, reject) => {
          resolve(refreshToken);
       });
     };



     Mongo.prototype.getUser  = async function(){
         var user = await stitchAppClient.auth.user;


         var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
         };

         return new Promise((resolve, reject) => {
             resolve(JSON.stringify(userObject));
         });
     };

     Mongo.prototype.sendResetPasswordEmail = async function(email){
        var emailPassClient = stitch.Stitch.defaultAppClient.auth
                .getProviderClient(stitch.UserPasswordAuthProviderClient.factory);

        await emailPassClient.sendResetPasswordEmail(email);
     };

     Mongo.prototype.callFunction  = async function(name, args/*, timeout*/){
         var result = await stitchAppClient.callFunction(name, args);

         return new Promise((resolve, reject) => {
             resolve(result);
         });
     };
     // --------------------------

    Mongo.prototype.sendAuthListenerEvent = async function(arg){

         var authEvent = new CustomEvent("authChange", {
                detail: arg
         });

         document.dispatchEvent(authEvent);
    };

     Mongo.prototype.setupWatchCollection = async function(databaseName, collectionName, arg){
        var collection = this.getCollection(databaseName, collectionName)


        console.log(typeof arg)
        let asObjectIDs = false;
        if (arg == null){
            asObjectIDs = true;
        }
        else if (typeof arg === 'string' || arg instanceof String){
            arg = JSON.parse(arg);
        }
        else if (typeof arg === 'array' || arg instanceof Array){
            if(arg[1] == false){
                arg = arg[0]
            }
            else {
                asObjectIDs = true
                if(arg[0] == null){
                    arg = null
                }
                else{
                    var lst = [];
                    arg[0].forEach((str) => {
                        lst.push(new stitch.BSON.ObjectId(str))
                    })
                    arg = lst;
                }
            }
        }

        var changeStream = await collection.watch(arg);

        console.log(`asObjectIDs=${asObjectIDs}`)
        // Set the change listener. This will be called
        // when the watched documents are updated.
        changeStream.onNext((event) => {

          let docId = event.fullDocument['_id']
          var results = {
            "_id": asObjectIDs
                ? {'$oid': docId} //new stitch.BSON.ObjectId(docId)
                : docId
          }
          var watchEvent = new CustomEvent("watchEvent."+databaseName+"."+collectionName, {
               detail: JSON.stringify(results)
          });

          document.dispatchEvent(watchEvent);

//          // Be sure to close the stream when finished(?).
//          changeStream.close()
        })
     }
}