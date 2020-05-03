//
//  MyMongoStitchClient.swift
//  fluttermongostitch
//
//  Created by kfir Matityahu on 16/04/2020.
//

import Foundation
import MongoSwift
import StitchCore
import StitchRemoteMongoDBService

extension AnyBSONValue{
    func toSimpleType() -> Any{
        
        if let value = self.value as? Double{
            return value
        }
        
        if let value = self.value as? String{
            return value
        }
        
        if let value = self.value as? Document{
            return value.extendedJSON
        }
        
        if let value = self.value as? Array<Any>{
            return value
        }
        
        if let value = self.value as? ObjectId{
            return value.hex
        }
        
        if let value = self.value as? Bool{
            return value
        }
        
        if let value = self.value as? NSDate{
            return value.timeIntervalSince1970
        }
        
        if let value = self.value as? Int32{
            return value
        }
        
        if let value = self.value as? Int64{
            return value
        }
        
        if let value = self.value as? Decimal128{
            return value.doubleValue ?? 0.0
        }
        
//        switch(self.value.bsonType){
//        case BSONNumber:
//            return (self.value as BSONNumber).;
//        default:
//            return ""
//        }
        return self.value as? String ?? "";
    }
}

// cumbersome workaround solution
// TODO: convert any (possible) value into 'BSONValue'
class BsonExtractor {    
    static func getValue(of: Any) -> BSONValue?{
        let value = of
        
        if let bsonValue = value as? Double {
            return bsonValue
        }
        
        else if let bsonValue = value as? Int64 {
            return bsonValue
        }
        
        else if let bsonValue = value as? String {
            return bsonValue
        }
        
        else if let bsonValue = value as? Int {
            return bsonValue
        }
        
        
        else if let bsonValue = value as? Double {
            return bsonValue
        }
        
        
        // TODO: check this conversion
        if let bsonValue = value as? Array<Any> {
            return bsonValue
        }
        
        return nil
    }
}


enum MyError : Error {
    case nilError
}


class MyMongoStitchClient {
    var client: RemoteMongoClient
    var appClient: StitchAppClient
    lazy var auth = appClient.auth
    
    init(client: RemoteMongoClient, appClient: StitchAppClient) {
        self.client = client
        self.appClient = appClient
    }
    
    
    func signInAnonymously(
        onCompleted: @escaping (StitchUser)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.login(withCredential: AnonymousCredential()) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user)
                break
                
            case .failure(let error):
                onError("\(error)")
                break
            }
        }
    }
    
    func signInWithUsernamePassword(
        username: String,
        password: String,
        onCompleted: @escaping (StitchUser)->Void,
        onError: @escaping (String?)->Void
    ) {

        self.auth.login(
            withCredential: UserPasswordCredential(withUsername: username, withPassword: password)
        ) { authResult in
            switch authResult {
            case .success(let user):
                onCompleted(user)
                break
                
            case .failure(let error):
                onError("UsernamePassword Provider Login failed \(error)")
                break
            }
        }
    }
    
    func registerWithEmail(
        email: String,
        password: String,
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        
        let emailPassClient = self.auth.providerClient(
            fromFactory: userPasswordClientFactory
        )
        
        emailPassClient.register(withEmail: email, withPassword: password) { result in
            switch result {
            case .success( _):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("Error registering new user: \(error)")
                break
            }
        }
    }
    
    func logout(
        onCompleted: @escaping (Bool)->Void,
        onError: @escaping (String?)->Void
    ) {
        self.auth.logout { result in
            switch result {
            case .success(_):
                onCompleted(true)
                break
                
            case .failure(let error):
                onError("Cannot logout user: \(error)")
                break
            }
        }
        
    }
    
    func getUserId() -> String? {
        return self.auth.currentUser?.id
    }
    
    /// ========================== Database related ========================================== ///
    /*private*/ func getCollection(databaseName: String?, collectionName: String?) throws
        -> RemoteMongoCollection<Document>? {
        if(databaseName == nil || collectionName == nil) {
            throw MyError.nilError
        }
    
        return client.db(databaseName!).collection(collectionName!)
    }
    
    func insertDocument(
        databaseName: String?,
        collectionName: String?,
        data: Dictionary<String, Any>?,
        onCompleted: @escaping ()->Void,
        onError: @escaping (String?)->Void
     ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
        
            var document = Document()
            for (key) in data!.keys{
                let value = data![key]
                
                if (value != nil){
                    document[key] = BsonExtractor.getValue(of: value!)
                }
            }
            
            
            collection?.insertOne(document) { result in
                switch result {
                case .success(let result):
                    print("Successfully inserted item with _id: \(result.insertedId))");
                    onCompleted()
                case .failure(let error):
                    onError("Failed to insert a document: \(error)")
                }
            }
        }
        catch {
            onError("Failed to insert a document")
        }
    }
    
    func insertDocuments(
        databaseName: String?,
        collectionName: String?,
        list: Array<String>?,
        onCompleted: @escaping ()->Void,
        onError: @escaping (String?)->Void
    ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            if(list == nil){
               onError("Insertion failed. No document")
            }
            
            let documents = try list!.map({ try Document.init(fromJSON: $0) })
            
            collection?.insertMany(documents) { result in
                switch result {
                case .success(let result):
                    print("Successfully inserted docs with the ids: \(result.insertedIds))");
                    onCompleted()
                case .failure(let error):
                    onError("Failed to insert documents: \(error)")
                }
            }
        }
        catch {
            onError("Failed to insert a document")
        }
    }
    
    ///////////////////////////
 
    func deleteDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
        
            
            collection?.deleteOne(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to delete a document : \(error)")
                }
            }
        }
        catch {
            onError("Failed to delete a document")
        }
    }
    
    // CHECK
    func deleteDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            collection?.deleteMany(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to delete documents : \(error)")
                }
            }
        
        }
        catch {
            onError("Failed to delete documents")
        }
    }
  
  
    func findDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        projectionJson: String?,
        limit: Int?,
        sortJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            // options (optional) attributes
            var projectionBson = Document()
            var docsLimit:Int64? = nil
            var sortBson:Document? = nil
            
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            if (projectionJson != nil) {
                projectionBson = try Document.init(fromJSON: projectionJson!)
            }
            
            if(limit != nil){
                docsLimit = Int64(limit!)
            }
            
            if (sortJson != nil){
                sortBson = try Document.init(fromJSON: sortJson!)
            }
            
            let options = RemoteFindOptions(
                limit: docsLimit,
                projection: projectionBson,
                sort: sortBson
            )
            
            let task = collection?.find(document, options: options)

            
            task!.toArray(){result in
                switch result {
                case .success(let results):
                    let queryResults =  results.map({ $0.extendedJSON })
                    onCompleted(queryResults)
                case .failure(let error):
                    onError("Failed to find documents: \(error)")
                }
            }
        }
        catch {
            onError("Failed to find documents")
        }
    }
    
 
    func findDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        projectionJson: String?,
        onCompleted: @escaping (Any?)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            var projectionBson = Document()
            
            if (filterJson != nil) {
                document = try Document.init(fromJSON: filterJson!)
            }
            
            if (projectionJson != nil) {
               projectionBson = try Document.init(fromJSON: projectionJson!)
            }
            
            let options = RemoteFindOptions(
                projection: projectionBson
            )
            
            collection?.findOne(document, options: options) { result in
                switch result {
                case .success(let result):
                    onCompleted(result?.extendedJSON)
                    break
                case .failure(let error):
                    onError("Failed to find item: \(error)")
                    break
                }
            }
        }
        catch {
            onError("Failed to find item")
        }
    }
    

    func countDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
        
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }

            
            collection?.count(document) { result in
                switch result {
                case .success(let result):
                    onCompleted(result)
                case .failure(let error):
                    onError("Failed to count collection: \(error)")
                }
            }
        
        }
        catch {
            onError("Failed to count collection")
        }
    }
    
    //
    func updateDocument(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        updateJson: String,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            let update = try Document.init(fromJSON: updateJson)
            
            collection?.updateOne(filter: document, update: update) { result in
                switch result {
                case .success(let result):
                    onCompleted([result.matchedCount, result.modifiedCount])
                case .failure(let error):
                    onError("Failed to update collection: \(error)")
                }
            }
            
        }
        catch {
            onError("Failed to count collection")
        }
    }
    
    func updateDocuments(
        databaseName: String?,
        collectionName: String?,
        filterJson: String?,
        updateJson: String,
        onCompleted: @escaping (Any)->Void,
        onError: @escaping (String?)->Void
        ) {
        do {
            let collection = try getCollection(databaseName: databaseName, collectionName: collectionName)
            
            var document = Document()
            
            if (filterJson != nil){
                document = try Document.init(fromJSON: filterJson!)
            }
            
            let update = try Document.init(fromJSON: updateJson)
            
            collection?.updateMany(filter: document, update: update) { result in
                switch result {
                case .success(let result):
                    onCompleted([result.matchedCount, result.modifiedCount])
                case .failure(let error):
                    onError("Failed to update collection: \(error)")
                }
            }
            
        }
        catch {
            onError("Failed to update collection")
        }
    }
    
    
    func callFunction(name: String,
                      args: Array<Any>?,
                      requestTimeout: Int64?,
                      onCompleted: @escaping (Any)->Void,
                      onError: @escaping (String?)->Void
        ){
        
        
        
        var argsBson = [BSONValue]()
        args?.forEach { value in
            argsBson.append(BsonExtractor.getValue(of: value) ?? "")
        }
        
        var timeoutInSeconds:TimeInterval = 15
        if (requestTimeout != nil){
            timeoutInSeconds = Double(requestTimeout!)/1000.0
        }
        
        self.appClient.callFunction(
            withName: name,
            withArgs: argsBson,
            withRequestTimeout: timeoutInSeconds ){ (result: StitchResult<AnyBSONValue>) in
            
                switch result {
                case .success(let data):
                    onCompleted(data.value)//toSimpleType())
                case .failure(let error):
                    onError("Failed to call function: \(error)")
            }
        }
    }
    
    
}

class MyCustomDelegate<T>: ChangeStreamDelegate
    where T: Encodable, T: Decodable
{
    var _onCompleted: (Any)->Void
    init(_ onCompleted: @escaping (Any)->Void){
        self._onCompleted = onCompleted
    }
    
    func didReceive(event: ChangeEvent<T>) {
        self._onCompleted((event.fullDocument as! Document).extendedJSON)
    }
    

    typealias DocumentT = T
    
//    func didReceive(event: ChangeEvent<T>) {
//        // react to events
//        ev
//    }
    
    func didReceive(streamError: Error) {

    }
    
    func didOpen() {
        
    }
    
    func didClose() {
        
    }
  
}
