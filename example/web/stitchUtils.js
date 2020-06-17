
var mongoClient;
var stitchAppClient


//
//class MyStitchAuthListener extends stitch.StitchAuthListener {
////  // Call constructor of superclass to initialize superclass-derived members.
////  stitch.StitchAuthListener.call(this, auth);
//    constructor(auth){
//        super(auth)
//    }
//}

/// MyStitchAuthListener derives from 'StitchAuthListener' SDK one
//MyStitchAuthListener.prototype = Object.create(stitch.StitchAuthListener.prototype);
//MyStitchAuthListener.prototype.constructor = MyStitchAuthListener;


function Mongo() {
    Mongo.prototype.connectMongo  = function(appId) {
        stitchAppClient = stitch.Stitch.initializeDefaultAppClient(appId);

        mongoClient = stitchAppClient.getServiceClient(
            stitch.RemoteMongoClient.factory,
            "mongodb-atlas"
        );

        // add Auth Listenr
//        this.authListener();
    }

    /// -----------------------------------------------------
    Mongo.prototype.getCollection = function(databaseName, collectionName){
       return mongoClient.db(databaseName).collection(collectionName)
    }


    Mongo.prototype.insertDocument = async function(databaseName, collectionName, docString){
        var collection = this.getCollection(databaseName, collectionName)
        var doc = JSON.parse(docString)

        await collection.insertOne(doc)
    }


    Mongo.prototype.insertDocuments = async function(databaseName, collectionName, list){
        var collection = this.getCollection(databaseName, collectionName)

        var docs = []
        list.forEach((str) => {
            docs.push(JSON.parse(str))
        })

        await collection.insertMany(docs)
    }

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

        return new Promise((resolve, reject) => {
            resolve(JSON.stringify(userObject));
        });
    }

//    Mongo.prototype.signInWithUsernamePassword  = async function(username, password){
//        var user = await stitchAppClient.auth.loginWithCredential(
//            new stitch.UserPasswordCredential(username, password))
//
//        return new Promise((resolve, reject) => {
//            resolve(JSON.stringify({"id": user.id}));
//        });
//    }

//    Mongo.prototype.signInWithUsernamePassword  = async function(username, password){
//        var user = await stitchAppClient.auth.loginWithCredential(
//            new stitch.UserPasswordCredential(username, password))
//
//        return new Promise((resolve, reject) => {
//            resolve(JSON.stringify({"id": user.id}));
//        });
//    }

    Mongo.prototype.registerWithEmail  = async function(email, password){
        var emailPassClient = stitch.Stitch.defaultAppClient.auth
            .getProviderClient(stitch.UserPasswordAuthProviderClient.factory);


        await emailPassClient.registerWithEmail(email, password);
//        return new Promise((resolve, reject) => {
//            resolve(JSON.stringify({"id": user.id}));
//        });

        console.log('DONE!');
    }

    Mongo.prototype.logout  = async function(){
        await stitchAppClient.auth.logout();
        console.log('logged out')
    }

     Mongo.prototype.getUserId  = async function(){
         var user = await stitchAppClient.auth.user;

         return new Promise((resolve, reject) => {
            resolve(user.id);
         });
     }


     Mongo.prototype.getUser  = async function(){
         var user = await stitchAppClient.auth.user;


         var userObject = {
            "id": user.id,
            "profile": {
                'email': user.profile.email
            }
         }

         return new Promise((resolve, reject) => {
             resolve(JSON.stringify(userObject));
         });
     }

     Mongo.prototype.callFunction  = async function(name, args/*, timeout*/){
         var result = await stitchAppClient.callFunction(name, args);

         return new Promise((resolve, reject) => {
             resolve(result);
         });
     }
     // --------------------------

     Mongo.prototype.setupWatchCollection = async function(databaseName, collectionName, arg){
        var collection = this.getCollection(databaseName, collectionName)

        console.log(arg)
        console.log(typeof arg)
        if (typeof arg === 'string' || arg instanceof String){
            arg = JSON.parse(arg);
        }
        if (typeof arg === 'array' || arg instanceof Array){
            if(arg[1] == false){
                arg = arg[0]
            }
            else {
                var lst = [];
                arg[0].forEach((str) => {
                    lst.push(new stitch.BSON.ObjectId(str))
                })
                arg = lst;
            }


        }

        console.log(arg)

        var changeStream = await collection.watch(arg);//['8','22']);

        // Set the change listener. This will be called
        // when the watched documents are updated.
        changeStream.onNext((event) => {
          console.log('Watched document changed:', event)

          var results = {
            "_id": event.fullDocument['_id']
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


