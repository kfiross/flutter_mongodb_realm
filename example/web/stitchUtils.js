
var mongoClient;
var stitchAppClient
//
//function Test() {
//    return 12+20;
//}

function connectMongo(appId) {
    stitchAppClient = stitch.Stitch.initializeDefaultAppClient(appId);

    mongoClient = stitchAppClient.getServiceClient(
        stitch.RemoteMongoClient.factory,
        "mongodb-atlas"
    );

}

async function loginAnonymously(){
    var user = await stitchAppClient.auth.loginWithCredential(new stitch.AnonymousCredential())

    return new Promise((resolve, reject) => {
        resolve(JSON.stringify({"id": user.id}));
    });
}

function getCollection(databaseName, collectionName){
   return mongoClient.db(databaseName).collection(collectionName)
}


function insertDocument(databaseName, collectionName, doc ){
    collection.insert(doc)
}

async function findDocuments(databaseName, collectionName) {
    var collection = getCollection(databaseName, collectionName)

    // Find documents and log them to console.
    var results = await collection.find({}, {}).toArray()
  //  console.log('Results:', results)

    var strings = [];
    results.forEach((doc) => {
        strings.push(JSON.stringify(doc))
    })

    console.log('Results:', strings)
    return new Promise((resolve, reject) => {
        resolve(strings);
    });
}
